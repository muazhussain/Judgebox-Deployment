variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "judgebox"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ssh_key_name" {
  description = "Name of AWS key pair for SSH access"
  type        = string
}

variable "instance_types" {
  description = "Instance types for different servers"
  type        = map(string)
  default = {
    bastion = "t2.micro"
    nginx   = "t2.micro"
    k3s     = "t2.medium"
  }
}

variable "ssh_allowed_ips" {
  description = "List of IPs allowed to SSH to bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}