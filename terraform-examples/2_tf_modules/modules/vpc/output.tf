output "vpc_id" {
  value = aws_vpc.webVPC.id
}

output "web_public_subnets_1" {
  value = aws_subnet.webPublicSubnet1.id
}

output "web_public_subnets_2" {
  value = aws_subnet.webPublicSubnet2.id
}

output "web_private_subnets_1" {
  value = aws_subnet.webPrivateSubnet1.id
}

output "web_private_subnets_2" {
  value = aws_subnet.webPrivateSubnet2.id
}

