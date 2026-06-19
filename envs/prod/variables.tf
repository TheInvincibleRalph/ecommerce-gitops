# Provider Variable
variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "aws_region" {
  description = "Region for AMI lookup and EC2 launch."
  type        = string
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR block for the public subnet."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR block for the private subnet."
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zone to use."
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC."
  type        = bool
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IPs on instance launch in the public subnet."
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}