provider "aws" {
  region = var.region
}

# VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "adarsh_cluster" {
  name = "adarsh-strapi-cluster"
}

# Security Group
resource "aws_security_group" "adarsh_sg" {
  name        = "adarsh-strapi-sg-v2"
  description = "Allow all traffic for debugging"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "adarsh_alb" {
  name               = "adarsh-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.adarsh_sg.id]
}

resource "aws_lb_target_group" "adarsh_tg" {
  name        = "adarsh-strapi-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/admin"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_lb_listener" "adarsh_listener" {
  load_balancer_arn = aws_lb.adarsh_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adarsh_tg.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "adarsh_task_v2" {
  family                   = "adarsh-strapi-task-v2"
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
        {
          name  = "API_TOKEN_SALT"
          value = "j4rqpdb/U8JdU+aubTSBmQ=="
        },
        {
          name  = "ADMIN_JWT_SECRET"
          value = "rGNuU8jxCYxmVxQrTcPPFrNg7ue/1L4mNc8wzVXEyiQ="
        },
        {
          name  = "TRANSFER_TOKEN_SALT"
          value = "RqkOPXvmnN+3ONyuc78XsxetlLSsMilqi93HA1U/GHE="
        },
        {
          name  = "ENCRYPTION_KEY"
          value = "joKNsWCuXj0DgjRfSm6TCjGQp8vCnIylKK4k9g97x5Q="
        },
        {
          name  = "HOST"
          value = "0.0.0.0"
        },
        {
          name  = "PORT"
          value = tostring(var.container_port)
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/adarsh-strapi"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "adarsh_service_v2" {
  name            = "adarsh-strapi-service-v2"
  cluster         = aws_ecs_cluster.adarsh_cluster.id
  task_definition = aws_ecs_task_definition.adarsh_task_v2.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.adarsh_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.adarsh_tg.arn
    container_name   = "strapi"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 120

  depends_on = [aws_lb_listener.adarsh_listener]
}
