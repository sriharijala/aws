variable "vpc_cidr" {
  description = "CIDR for vpc"
  type        = string
}

variable "vpc_tags" {
  description = "VPC tags"
  type        = map(any)
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR for private subnets"
  type        = list(string)
}

variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    rule_no     = number
  }))

  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      rule_no = 100
    },
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      rule_no = 200
    }
  ]
}