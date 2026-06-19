variable "availability_zones" {
  description = "A list of Availability Zones to use (EKS requires at least 2)."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets."
  type        = list(string)
}

variable "region" {
  description = "The AWS region to deploy into."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on launch for public subnet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources. Must include Name and Environment."
  type = object({
    Name        = string
    Environment = string
    Project     = optional(string)
  })
}