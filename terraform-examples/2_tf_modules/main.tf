terraform {
  required_version = "~>1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "webVPC" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_tags             = var.vpc_tags
  project              = var.project
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
}

module "webServers" {
  source = "./modules/webservers"

  project             = var.project
  vpc_cidr            = var.vpc_cidr
  web_vpc_id          = module.webVPC.vpc_id
  web_public_subnets  = [module.webVPC.web_public_subnets_1, module.webVPC.web_public_subnets_2]
  web_private_subnets = [module.webVPC.web_private_subnets_1, module.webVPC.web_private_subnets_2]
}

module "cloudWatch" {
  source = "./modules/cloudwatch"
}