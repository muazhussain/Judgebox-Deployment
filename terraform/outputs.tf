output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of Bastion host"
}

output "nginx_public_ip" {
  value       = aws_instance.nginx.public_ip
  description = "Public IP of Nginx load balancer"
}

output "k3s_private_ip" {
  value       = aws_instance.k3s.private_ip
  description = "Private IP of K3s server"
}

output "ssh_to_bastion" {
  value       = "ssh ubuntu@${aws_instance.bastion.public_ip}"
  description = "SSH command for bastion host"
}

output "ssh_to_k3s" {
  value       = "ssh -J ubuntu@${aws_instance.bastion.public_ip} ubuntu@${aws_instance.k3s.private_ip}"
  description = "SSH command for K3s server through bastion"
}

output "application_url" {
  value       = "http://${aws_instance.nginx.public_ip}"
  description = "Application URL"
}