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


}
