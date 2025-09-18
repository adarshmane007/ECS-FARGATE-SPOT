output "strapi_ec2_public_ip" {
  value = aws_instance.strapi_ec2_2.public_ip
}
