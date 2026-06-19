module "vpc" {
  region                  = var.region
  source                  = "../../modules/vpc"
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name        = "vpc"
    Environment = "prod"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "gitops-ecommerce-prod"
  vpc_id       = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnet_ids

  tags = var.tags
}

