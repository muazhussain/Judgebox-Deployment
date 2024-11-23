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