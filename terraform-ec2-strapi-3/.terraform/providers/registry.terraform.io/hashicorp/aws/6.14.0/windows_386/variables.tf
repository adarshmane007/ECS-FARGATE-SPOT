variable "region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-01b6d88af12965bb6" # Amazon Linux 2023 (us-east-1)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "adarsh-key" # Replace with your actual EC2 key pair name
}


variable "image_tag" {
  description = "Tag of the Docker image to deploy from ECR"
  type        = string
}
