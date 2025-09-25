output "strapi_url" {
  description = "Public URL to access Strapi"
  value       = aws_lb.adarsh_alb.dns_name
}