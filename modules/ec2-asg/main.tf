resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = "ami-0a0e5d9c7acc336f1" 
  instance_type = "t2.micro"
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.instance.id]
  }
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    echo "<h1>Hello DevOps Bootcamp!</h1>" > /var/www/html/index.html
    EOF
  )
}

resource "aws_security_group" "instance" {
  name_prefix = "web-server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  vpc_zone_identifier = var.public_subnets
  target_group_arns  = [var.target_group_arn]
  
  launch_template {
    id = aws_launch_template.web_server.id
    version = "$Latest"
  }
}