output "vpc_id" {
  value = module.webVPC.vpc_id
}

output "child_load_balancer_dns_name" {
  description = "Load Balancer DNS Name"
  value       = module.webServers.load_balancer_dns_name
}

output "web_public_webserver1_ip" {
  value = module.webServers.web_public_webserver1_ip
}

output "web_public_webserver2_ip" {
  value = module.webServers.web_public_webserver2_ip
}
