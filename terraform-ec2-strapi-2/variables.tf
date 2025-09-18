variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-08982f1c5bf93d976" # Amazon Linux 2023 (us-east-1)
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "mane2" # Replace with your actual EC2 key pair name
}
