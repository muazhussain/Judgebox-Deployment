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

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a"]
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-047126e50991d067b"
}

variable "instance_types" {
  description = "Instance types for different servers"
  type        = map(string)
  default = {
    k3s_master = "t2.micro"
    k3s_worker = "t2.micro"
  }
}

variable "worker_count" {
  description = "Number of K3s worker nodes"
  type        = number
  default     = 1
}

variable "ssh_key_name" {
  description = "Name of AWS key pair for SSH access"
  type        = string
}