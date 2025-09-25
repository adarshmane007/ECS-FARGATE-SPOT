variable "region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ecr_image_url" {
  description = "Full ECR image URL for Strapi"
  type        = string
}

variable "cpu" {
  description = "Fargate task CPU units"
  default     = "512"
}

variable "memory" {
  description = "Fargate task memory (MB)"
  default     = "1024"
}

variable "container_port" {
  description = "Port exposed by Strapi container"
  default     = 1337
}