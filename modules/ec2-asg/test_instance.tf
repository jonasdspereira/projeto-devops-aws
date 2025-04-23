resource "aws_instance" "test_instance" {
  ami           = "ami-0a0e5d9c7acc336f1"  # AMI Ubuntu
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]  # Usando a primeira subnet pública

  vpc_security_group_ids = [aws_security_group.test_instance.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Atualiza o sistema
    sudo apt-get update
    sudo apt-get upgrade -y
    
    # Instala o Apache e o Apache Benchmark
    sudo apt-get install -y apache2 apache2-utils
    
    # Configura o Apache para iniciar na inicialização
    sudo systemctl enable apache2
    sudo systemctl start apache2
    
    # Cria a página inicial com CSS
    echo "<!DOCTYPE html>
    <html lang='pt-BR'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Teste de Carga - DevOps</title>
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
            <h1>🚀 Teste de Carga DevOps</h1>
            <div class='info-box'>
                <div class='info-item'>
                    <strong>ID da Instância:</strong> 
                    <span class='highlight'>$(curl -s http://169.254.169.254/latest/meta-data/instance-id)</span>
                </div>
                <div class='info-item'>
                    <strong>Zona de Disponibilidade:</strong> 
                    <span class='highlight'>$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</span>
                </div>
                <div class='info-item'>
                    <strong>IP Privado:</strong> 
                    <span class='highlight'>$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)</span>
                </div>
                <div class='info-item'>
                    <strong>IP Público:</strong> 
                    <span class='highlight'>$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</span>
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
    EOF
  )

  tags = {
    Name = "Test-Instance"
  }
}

resource "aws_security_group" "test_instance" {
  name_prefix = "test-instance"
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
    description = "HTTP access"
  }

  # Permite todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-instance-sg"
  }
}

output "test_instance_public_ip" {
  value = aws_instance.test_instance.public_ip
} 