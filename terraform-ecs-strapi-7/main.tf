provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "adarsh_subnet_99a" {
  id = "subnet-03e1b3fe2ad999849"
}

data "aws_subnet" "adarsh_subnet_99b" {
  id = "subnet-05e9035d969355719"
}

data "aws_security_group" "adarsh_sg_99" {
  id = "sg-05107eda1fad1280d"
}

resource "aws_ecs_cluster" "adarsh_cluster_99" {
  name = "adarsh-strapi-cluster-99"
}

resource "aws_lb" "adarsh_alb_spot_99" {
  name               = "adarsh-strapi-alb-spot-99"
  internal           = false
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.adarsh_subnet_99a.id, data.aws_subnet.adarsh_subnet_99b.id]
  security_groups    = [data.aws_security_group.adarsh_sg_99.id]
}

resource "aws_lb_target_group" "adarsh_tg_spot_99" {
  name        = "adarsh-strapi-tg-spot-99"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "adarsh_listener_spot_99" {
  load_balancer_arn = aws_lb.adarsh_alb_spot_99.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adarsh_tg_spot_99.arn
  }
}

resource "aws_cloudwatch_log_group" "strapi_logs_99" {
  name              = "/ecs/strapi-spot-99"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "adarsh_task_99" {
  family                   = "adarsh-strapi-task-99"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = "arn:aws:iam::145065858967:role/adarshecsrole"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = var.ecr_image_url
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "API_TOKEN_SALT", value = "j4rqpdb/U8JdU+aubTSBmQ==" },
        { name = "ADMIN_JWT_SECRET", value = "rGNuU8jxCYxmVxQrTcPPFrNg7ue/1L4mNc8wzVXEyiQ=" },
        { name = "TRANSFER_TOKEN_SALT", value = "RqkOPXvmnN+3ONyuc78XsxetlLSsMilqi93HA1U/GHE=" },
        { name = "ENCRYPTION_KEY", value = "joKNsWCuXj0DgjRfSm6TCjGQp8vCnIylKK4k9g97x5Q=" },
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = tostring(var.container_port) }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi_logs_99.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "adarsh_service_spot_99" {
  name            = "adarsh-strapi-service-spot-99"
  cluster         = aws_ecs_cluster.adarsh_cluster_99.id
  task_definition = aws_ecs_task_definition.adarsh_task_99.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = [data.aws_subnet.adarsh_subnet_99a.id, data.aws_subnet.adarsh_subnet_99b.id]
    security_groups  = [data.aws_security_group.adarsh_sg_99.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.adarsh_tg_spot_99.arn
    container_name   = "strapi"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 120

  depends_on = [aws_lb_listener.adarsh_listener_spot_99]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm_99" {
  alarm_name          = "high-cpu-usage-task-99"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU usage exceeds 80%"
  dimensions = {
    ClusterName = aws_ecs_cluster.adarsh_cluster_99.name
    ServiceName = aws_ecs_service.adarsh_service_spot_99.name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory_alarm_99" {
  alarm_name          = "high-memory-usage-task-99"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Alarm when memory usage exceeds 75%"
  dimensions = {
    ClusterName = aws_ecs_cluster.adarsh_cluster_99.name
    ServiceName = aws_ecs_service.adarsh_service_spot_99.name
  }
}

resource "aws_cloudwatch_dashboard" "ecs_dashboard_99" {
  dashboard_name = "ecs-strapi-task-99-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.adarsh_cluster_99.name, "ServiceName", aws_ecs_service.adarsh_service_spot_99.name ],
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.adarsh_cluster_99.name, "ServiceName", aws_ecs_service.adarsh_service_spot_99.name ]
          ]
          period = 60
          stat   = "Average"
          title  = "ECS CPU & Memory Usage"
        }
      }
    ]
  })
}
