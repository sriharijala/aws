variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for vpc"
  type        = string
}

variable "web_public_subnets" {
  description = "CIDR for public subnets"
  type        = list(string)
}

variable "web_private_subnets" {
  description = "CIDR for private subnets"
  type        = list(string)
}

variable "web_vpc_id" {
  description = "VPC Id"
  type        = string
  validation {
    # regex(...) fails if it cannot find a match
    condition     = length(var.web_vpc_id) > 4 && can(regex("^vpc-", var.web_vpc_id))
    error_message = "VPC id can not empty and, starting with \"vpc-\"."
  }
}

variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "web_server" {
  type = map(string)

  default = {
    web_ami_id    ="ami-066784287e358dad1"
    instance_type = "t2.micro"
    key_name      = "jala_key_pair"
  }
}





