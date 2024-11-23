output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "k3s_master_private_ip" {
  value       = aws_instance.k3s_master.private_ip
  description = "Private IP of K3s master"
}

output "k3s_workers_private_ips" {
  value       = aws_instance.k3s_workers[*].private_ip
  description = "Private IPs of K3s workers"
}

output "k3s_token" {
  value       = random_password.k3s_token.result
  description = "K3s cluster token"
  sensitive   = true
}