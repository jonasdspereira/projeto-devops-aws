resource "aws_lb" "web" {
  name = "devops-alb"
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.public[*].id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}