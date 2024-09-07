output "load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value       = aws_alb.webLoadBalanacer.dns_name
}

output "web_public_webserver1_ip" {
  value = aws_instance.webserver1.public_ip
}

output "web_public_webserver2_ip" {
  value = aws_instance.webserver2.public_ip
}