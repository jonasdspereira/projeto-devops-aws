resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = "ami-0a0e5d9c7acc336f1"  # AMI Ubuntu
  instance_type = "t2.micro"
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.instance.id]
    delete_on_termination      = true
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Atualiza o sistema
    sudo apt-get update
    sudo apt-get upgrade -y
    
    # Instala o Apache
    sudo apt-get install -y apache2
    
    # Configura o Apache para iniciar na inicialização
    sudo systemctl enable apache2
    
    # Cria a página inicial
    echo "<html><body><h1>Hello DevOps Bootcamp!</h1><p>Instance is running!</p></body></html>" | sudo tee /var/www/html/index.html
    
    # Configura permissões corretas
    sudo chown -R www-data:www-data /var/www/html
    sudo chmod -R 755 /var/www/html
    
    # Inicia o Apache
    sudo systemctl start apache2
    
    # Verifica se o Apache está rodando
    if ! sudo systemctl is-active apache2; then
      echo "Apache failed to start. Checking logs..."
      sudo journalctl -u apache2
      exit 1
    fi
    
    # Instala ferramentas úteis para debug
    sudo apt-get install -y curl net-tools
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer"
    }
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "web-server"
  vpc_id      = var.vpc_id

  # Permite tráfego SSH de qualquer lugar
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Permite tráfego HTTP de qualquer lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity          = 2
  max_size                 = 4
  min_size                 = 1
  vpc_zone_identifier      = var.public_subnets
  target_group_arns        = [var.target_group_arn]
  health_check_type        = "ELB"
  health_check_grace_period = 300
  
  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServer-ASG"
    propagate_at_launch = true
  }

  # Adiciona dependência explícita das subnets
  depends_on = [var.public_subnets]
}