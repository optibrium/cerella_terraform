#
# @author GDev
# @date November 2020
#

resource "aws_lb" "ingress" {
  internal           = false
  load_balancer_type = "application"
  name               = var.cluster-name
  security_groups    = [aws_security_group.ingress.id]
  subnets            = [aws_subnet.left.id, aws_subnet.right.id]
}

resource "aws_alb_listener" "https_to_workers" {
  certificate_arn   = aws_acm_certificate.star.arn
  load_balancer_arn = aws_lb.ingress.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_alb_target_group.workers.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "workers" {
  name     = "eks-workers"
  port     = var.cluster-ingress-port
  protocol = "HTTP"
  vpc_id   = aws_vpc.environment.id
}

resource "aws_autoscaling_attachment" "workers" {
  alb_target_group_arn   = aws_alb_target_group.workers.arn
  autoscaling_group_name = aws_autoscaling_group.workers.id
}
