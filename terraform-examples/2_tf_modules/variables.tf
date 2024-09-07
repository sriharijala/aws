variable "vpc_cidr" {
  description = "CIDR for vpc"
  type        = string
}

variable "vpc_tags" {
  description = "VPC tags"
  type        = map(any)
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "Web Project"
}