resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.instance.id]
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Atualiza o sistema
    yum update -y
    
    # Instala o Apache e outras ferramentas necessárias
    yum install -y httpd ec2-instance-connect
    
    # Inicia e habilita o Apache
    systemctl start httpd
    systemctl enable httpd
    
    # Cria a página inicial
    echo "<h1>Hello DevOps Bootcamp!</h1>" > /var/www/html/index.html
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

  # Permite tráfego HTTP da internet
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "HTTP from ALB"
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
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns  = [var.target_group_arn]
  health_check_type  = "ELB"
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
}