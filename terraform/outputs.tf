output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.forum.id
}

output "instance_public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.forum.public_ip
}

output "thread_url" {
  description = "URL for Thread service (port 80)"
  value       = "http://${aws_eip.forum.public_ip}"
}

output "sender_url" {
  description = "URL for Sender service (port 8080)"
  value       = "http://${aws_eip.forum.public_ip}:8080"
}

output "api_url" {
  description = "URL for API service (port 3000)"
  value       = "http://${aws_eip.forum.public_ip}:3000"
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i keys/${var.project_name}-key.pem ec2-user@${aws_eip.forum.public_ip}"
}

output "ssh_key_path" {
  description = "Path to the SSH private key"
  value       = "${path.module}/keys/${var.project_name}-key.pem"
}
