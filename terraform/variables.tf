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
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a"]
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for ap-southeast-1"
  type        = string
  default     = "ami-047126e50991d067b"
}

variable "instance_types" {
  description = "Instance types for different nodes"
  type        = map(string)
  default = {
    k3s_master = "t3.micro"
    k3s_worker = "t3.micro"
  }
}

variable "worker_count" {
  description = "Number of K3s worker nodes"
  type        = number
  default     = 2
}

variable "ssh_key_name" {
  description = "Name of AWS key pair for SSH access"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "judgebox"
  }
}