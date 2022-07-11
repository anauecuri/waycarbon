### ECS Service ###
resource "aws_ecs_service" "waycarbon" {
  name                               = "waycarbon"
  cluster                            = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.waycarbon.arn}"
  health_check_grace_period_seconds  = "300"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  desired_count                      = "${var.min_capacity}"
  load_balancer {
    target_group_arn = "${aws_alb_target_group.waycarbon.id}"
    container_name   = "waycarbon"
    container_port   = 8080
  }
}

### ALB / Target Group ###
resource "aws_alb_target_group" "waycarbon" {
  name       = "waycarbon"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = "${var.main_vpc}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }
  deregistration_delay = "60"
  depends_on = ["aws_alb.alb"]

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    matcher             = "200-399"
  }
}

### ECS AUTO-SCALING ###
resource "aws_appautoscaling_target" "target_waycarbon" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.waycarbon.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up-waycarbon" {
  name               = "waycarbon-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.waycarbon.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down-waycarbon" {
  name               = "down-waycarbon"
  policy_type        = "StepScaling"
  resource_id        = "${aws_appautoscaling_target.target_waycarbon.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.target_waycarbon.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.target_waycarbon.service_namespace}"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
### CLOUD WATCH ALARMS ###
# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service-cpu-high-waycarbon" {
  alarm_name          = "waycarbon-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.waycarbon.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up-waycarbon.arn}"]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service-cpu-low-waycarbon" {
  alarm_name          = "waycarbon-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.waycarbon.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.down-waycarbon.arn}"]
}

### TASK DEFINITION ###
data "template_file" "waycarbon" {
  template = "${file("${path.module}/json/task_definition/definitions_waycarbon.json")}"

  vars = {
    microservice                = "waycarbon"
    containerImage              = "983910322746.dkr.ecr.us-east-1.amazonaws.com/waycarbon_repo${var.ecr_registry_type}:${var.waycarbon-image}" ### SUBSTITUIR ID_CONTA_AWS PELO ID DA CONTA ONDE REPO FOI CRIADO ###
    container_cpu               = "${var.container_cpu}"
    container_memory            = "${var.container_memory}"
    container_memoryReservation = "${var.container_memoryReservation}"
    container_boolean_essential = "true"
    env_container               = "${var.Env}"
    log_group                   = "${var.log_group}"
    Env                         = "${var.Env}"
    region                      = "${var.region}"
 }
}

resource "aws_ecs_task_definition" "waycarbon" {
  family                = "waycarbon"
  cpu                   = "${var.container_cpu}"
  memory                = "${var.container_memory}"
  container_definitions = "${data.template_file.waycarbon.rendered}"
}