resource "aws_ecs_cluster" "main" {
  name = coalesce(var.cluster_name, local.cluster_name)
  tags = {
    Name = coalesce(var.cluster_name, local.cluster_name)
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.project}-app",
    "image": "${var.app_image}",
    "cpu": ${var.fargate_cpu},
    "memory": ${var.fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${var.project}-app",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      },
      {
        "containerPort": 22,
        "hostPort": 22
      },
      {
        "containerPort": ${var.smtp_port},
        "hostPort": ${var.smtp_port}
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "main" {
  name             = "${var.project}-service"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.app.arn
  desired_count    = var.app_count
  platform_version = "1.4.0"
  launch_type      = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnets_public
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.id
    container_name   = "${var.project}-app"
    container_port   = var.app_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.smtp.id
    container_name   = "${var.project}-app"
    container_port   = var.smtp_port
  }

  depends_on = [aws_lb_listener.front_end_https, aws_lb_listener.smtp, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Name = "${var.project}-service"
  }
}
