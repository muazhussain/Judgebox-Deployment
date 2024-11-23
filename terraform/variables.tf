variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "judgebox"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-047126e50991d067b"
}

variable "ssh_key_name" {
  description = "Name of AWS key pair for SSH access"
  type        = string
}