terraform {
  backend "s3" {
    bucket = "adarshstrapi99"
    key    = "ecs-strapi/task99/terraform.tfstate"
    region = "ap-south-1"
  }
}
