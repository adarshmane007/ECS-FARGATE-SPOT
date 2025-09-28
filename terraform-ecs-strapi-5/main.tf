provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

# Referenced Subnet A (imported)
data "aws_subnet" "adarsh_subnet_7a" {
  id = "subnet-03e1b3fe2ad999849"
}

# Referenced Subnet B (imported)
data "aws_subnet" "adarsh_subnet_7b" {
  id = "subnet-05e9035d969355719"
}

resource "aws_ecs_cluster" "adarsh_cluster_7" {
  name = "adarsh-strapi-cluster-7"
}

resource "aws_security_group" "adarsh_sg_7" {
  name        = "adarsh-strapi-sg-7"
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

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, tags]
  }
}

resource "aws_lb" "adarsh_alb_7" {
  name               = "adarsh-strapi-alb-7"
  internal           = false
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.adarsh_subnet_7a.id, data.aws_subnet.adarsh_subnet_7b.id]
  security_groups    = [aws_security_group.adarsh_sg_7.id]

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, tags]
  }
}

resource "aws_lb_target_group" "adarsh_tg_7" {
  name        = "adarsh-strapi-tg-7"
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
    ignore_changes  = [name, tags]
  }
}

resource "aws_lb_listener" "adarsh_listener_7" {
  load_balancer_arn = aws_lb.adarsh_alb_7.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.adarsh_tg_7.arn
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_ecs_task_definition" "adarsh_task_7" {
  family                   = "adarsh-strapi-task-7"
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
      ]
      logConfiguration = {
        logDriver = "none"
       
      }
    }
  ])
}

resource "aws_ecs_service" "adarsh_service_7" {
  name            = "adarsh-strapi-service-7"
  cluster         = aws_ecs_cluster.adarsh_cluster_7.id
  task_definition = aws_ecs_task_definition.adarsh_task_7.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [data.aws_subnet.adarsh_subnet_7a.id, data.aws_subnet.adarsh_subnet_7b.id]
    security_groups  = [aws_security_group.adarsh_sg_7.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.adarsh_tg_7.arn
    container_name   = "strapi"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 120

  depends_on = [aws_lb_listener.adarsh_listener_7]
}
