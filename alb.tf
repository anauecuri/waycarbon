resource "aws_alb" "alb" {
  name            = "waycarbon-alb"
  internal        = true
  subnets         = ["${var.dmz_subnet_1}", "${var.dmz_subnet_2}"]
  security_groups = ["${aws_security_group.lb.id}"]
  enable_http2    = "true"
  idle_timeout    = 120
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

   default_action {
     target_group_arn = "${aws_alb_target_group.default-target-group.id}"
     type             = "forward"
   }
}

 resource "aws_lb_listener" "listener_https" {
   load_balancer_arn = "${aws_alb.alb.arn}"
   port              = "443"
   protocol          = "HTTPS"
   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
   default_action {
     type             = "forward"
     target_group_arn = "${aws_alb_target_group.default-target-group.id}"
   }
 }

output "alb_output" {
  value = "${aws_alb.alb.dns_name}"
}

output "alb_output_listener" {
  value = "${aws_alb_listener.listener.arn}"
}

 output "alb_output_listener_https" {
   value = "${aws_lb_listener.listener_https.arn}"
 }