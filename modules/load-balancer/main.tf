

resource "aws_lb" "api" {
  name               = "${var.project_name}-main"
  load_balancer_type = "application"
  subnets = [
    var.public_a_subnet_id,
    var.public_b_subnet_id
  ]

  security_groups = [var.security_groups_lb_id]

}

resource "aws_lb_target_group" "api" {
  name        = "${var.project_name}-api"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  port        = 8000

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
        type = "redirect"
        redirect {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
  }

}

