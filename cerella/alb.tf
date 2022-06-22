#
# @author GDev
# @date November 2021
#

resource "aws_route53_record" "star" {
  name    = "*.${var.domain}"
  records = [aws_lb.ingress.dns_name]
  type    = "CNAME"
  ttl     = "5"
  zone_id = var.hosted-zone-id
}

resource "aws_lb" "ingress" {
  internal           = false
  load_balancer_type = "application"
  name               = var.cluster-name
  security_groups    = [aws_security_group.ingress.id]
  subnets            = [aws_subnet.left.id, aws_subnet.right.id]
  idle_timeout       = 300
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

  depends_on = [aws_alb_target_group.workers]
}

resource "aws_alb_target_group" "workers" {
  name     = "eks-workers-${var.cluster-name}"
  port     = var.cluster-ingress-port
  protocol = "HTTP"
  vpc_id   = aws_vpc.environment.id
  health_check {
    enabled = true
    healthy_threshold = 4
    interval = 30
    matcher = "200"
    path = "/nginx-health"
  }
}

resource "aws_autoscaling_attachment" "workers" {
  lb_target_group_arn    = aws_alb_target_group.workers.arn
  autoscaling_group_name = aws_autoscaling_group.workers.id
}
