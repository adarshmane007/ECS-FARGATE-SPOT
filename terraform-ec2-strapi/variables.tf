variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0360c520857e3138f" # Ubuntu 22.04 LTS
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "mane2" # Replace with your actual EC2 key pair name
}
