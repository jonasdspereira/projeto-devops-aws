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

    # Obtém o ID da instância e a AZ
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
 
    # Cria a página inicial com CSS
    echo "<!DOCTYPE html>
    <html lang='pt-BR'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Bootcamp DevOps - DEMODAY</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                margin: 0;
                padding: 0;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .container {
                background: white;
                padding: 2rem;
                border-radius: 10px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                max-width: 800px;
                width: 90%;
                text-align: center;
            }
            h1 {
                color: #2c3e50;
                margin-bottom: 1.5rem;
                font-size: 2.5rem;
            }
            .info-box {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 1.5rem;
                margin: 1rem 0;
                text-align: left;
            }
            .info-item {
                margin: 0.5rem 0;
                color: #34495e;
            }
            .highlight {
                color: #3498db;
                font-weight: bold;
            }
            .timestamp {
                color: #7f8c8d;
                font-size: 0.9rem;
                margin-top: 2rem;
            }
            .status {
                background: #2ecc71;
                color: white;
                padding: 0.5rem 1rem;
                border-radius: 20px;
                display: inline-block;
                margin-top: 1rem;
            }
        </style>
    </head>
    <body>
        <div class='container'>
            <h1>🚀 Bootcamp DevOps!</h1>
            <div class='info-box'>
                <div class='info-item'>
                    <strong>ID da Instância:</strong> 
                    <span class='highlight'>$INSTANCE_ID</span>
                </div>
                <div class='info-item'>
                    <strong>Zona de Disponibilidade:</strong> 
                    <span class='highlight'>$AVAILABILITY_ZONE</span>
                </div>
                <div class='info-item'>
                    <strong>IP Privado:</strong> 
                    <span class='highlight'>$PRIVATE_IP</span>
                </div>
                <div class='info-item'>
                    <strong>IP Público:</strong> 
                    <span class='highlight'>$PUBLIC_IP</span>
                </div>
            </div>
            <div class='timestamp'>
                Página gerada em: $(date)
            </div>
            <div class='status'>
                Instância em execução! ✅
            </div>
        </div>
    </body>
    </html>" | sudo tee /var/www/html/index.html
    
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
    
    # Cria um script de health check
    echo '#!/bin/bash
    # Verifica se o Apache está rodando
    if ! systemctl is-active apache2 > /dev/null; then
        echo "Apache não está rodando"
        exit 1
    fi
    
    # Verifica se a página web está respondendo
    if ! curl -s http://localhost/ > /dev/null; then
        echo "Página web não está respondendo"
        exit 1
    fi
    
    # Verifica se o arquivo index.html existe
    if [ ! -f /var/www/html/index.html ]; then
        echo "index.html não encontrado"
        exit 1
    fi
    
    # Verifica as permissões do diretório web
    if [ ! -r /var/www/html ]; then
        echo "Permissões incorretas no diretório web"
        exit 1
    fi
    
    echo "Health check passou"
    exit 0' | sudo tee /usr/local/bin/health-check.sh
    
    # Torna o script executável
    sudo chmod +x /usr/local/bin/health-check.sh
    
    # Adiciona o health check ao crontab
    echo "* * * * * /usr/local/bin/health-check.sh >> /var/log/health-check.log 2>&1" | sudo tee -a /var/spool/cron/crontabs/root
    
    # Executa o health check inicial
    /usr/local/bin/health-check.sh
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
  health_check_grace_period = 600  # Aumentado para 10 minutos
  
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

# Target Group com configurações mais tolerantes
resource "aws_lb_target_group" "web" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "web-target-group"
  }
}

# Alarme para escalar para cima (CPU > 30%)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "30"
  statistic          = "Average"
  threshold          = "30"
  alarm_description  = "Escala para cima quando a CPU ultrapassa 30%"
  alarm_actions      = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

# Política de escalar para cima
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 30
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

# Alarme para escalar para baixo (CPU < 20%)
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-utilization-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "30"
  statistic          = "Average"
  threshold          = "20"
  alarm_description  = "Escala para baixo quando a CPU fica abaixo de 20%"
  alarm_actions      = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

# Política de escalar para baixo
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 30
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

# Alarme para escalar baseado na latência do ALB
resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  alarm_name          = "alb-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period             = "30"
  statistic          = "Average"
  threshold          = "0.5"
  alarm_description  = "Escala para cima quando a latência ultrapassa 0.5 segundos"
  alarm_actions      = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Alarme para escalar baseado no número de requisições
resource "aws_cloudwatch_metric_alarm" "request_count_high" {
  alarm_name          = "request-count-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period             = "30"
  statistic          = "Sum"
  threshold          = "1000"
  alarm_description  = "Escala para cima quando o número de requisições ultrapassa 1000"
  alarm_actions      = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}