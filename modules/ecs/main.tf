resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.project_name}-api"
}


resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

data "template_file" "api_container_definitions" {
  template = file("${path.module}/tasks-templates/container-definitions.json.tpl")
  vars = {
    app_image         = var.api_image_url
    proxy_image       = var.proxy_image_url
    frontend_image    = var.client_image_url
    db_host           = var.db_host
    db_name           = var.db_name
    db_user           = var.db_user
    db_pass           = var.db_pass
    port              = var.port
    log_group_name    = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region  = var.aws_region
    allowed_hosts     = var.dns_name
  }
}


resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.api.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
        var.private_a_subnet_id,
        var.private_b_subnet_id
    ]
    security_groups = [var.ecs_service_security_group_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn 
    container_name   = "proxy"
    container_port   = 8000
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  container_definitions    = data.template_file.api_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.task_role_arn

  lifecycle {
    ignore_changes = all
  }

}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = var.ecs_auto_scaling_role_arn
}

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 37.3
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name               = "application-scaling-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 7.83
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}
