resource "aws_launch_template" "web_server" {
  name_prefix = "web-server"
  image_id = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type = "t2.micro"
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    echo "<h1>Hello DevOps Bootcamp!</h1>" > /var/www/html/index.html
    EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = 2
  max_size = 4
  min_size = 1
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns = [aws_lb_target_group.web.arn]
  launch_template { id = aws_launch_template.web_server.id }
}