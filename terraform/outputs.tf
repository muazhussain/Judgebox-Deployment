# outputs.tf
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "k3s_master_private_ip" {
  value       = aws_instance.k3s_master.private_ip
  description = "Private IP of K3s master"
}

output "k3s_worker_private_ip" {
  value       = aws_instance.k3s_worker.private_ip
  description = "Private IP of K3s worker"
}

output "k3s_token" {
  value       = random_password.k3s_token.result
  description = "K3s cluster token"
  sensitive   = true
}

output "kubeconfig_command" {
  value       = "sudo cat /etc/rancher/k3s/k3s.yaml"
  description = "Command to get kubeconfig"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of private subnets"
}