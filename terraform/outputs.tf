# API Instance
output "api_instance_id" {
  description = "ID of the API EC2 instance"
  value       = aws_instance.api.id
}

output "api_public_ip" {
  description = "Public IP of the API instance"
  value       = aws_instance.api.public_ip
}

output "api_url" {
  description = "URL for API service"
  value       = "http://${aws_instance.api.public_ip}:3000"
}

# Thread Instance
output "thread_instance_id" {
  description = "ID of the Thread EC2 instance"
  value       = aws_instance.thread.id
}

output "thread_public_ip" {
  description = "Public IP of the Thread instance"
  value       = aws_instance.thread.public_ip
}

output "thread_url" {
  description = "URL for Thread service"
  value       = "http://${aws_instance.thread.public_ip}"
}

# Sender Instance
output "sender_instance_id" {
  description = "ID of the Sender EC2 instance"
  value       = aws_instance.sender.id
}

output "sender_public_ip" {
  description = "Public IP of the Sender instance"
  value       = aws_instance.sender.public_ip
}

output "sender_url" {
  description = "URL for Sender service"
  value       = "http://${aws_instance.sender.public_ip}"
}

# Database Instance
output "db_instance_id" {
  description = "ID of the Database EC2 instance"
  value       = aws_instance.db.id
}

output "db_public_ip" {
  description = "Public IP of the Database instance"
  value       = aws_instance.db.public_ip
}

output "db_connection" {
  description = "Database connection string"
  value       = "postgresql://forum:${var.db_password}@${aws_instance.db.public_ip}:5432/forumdb"
  sensitive   = true
}

# SSH Access
output "ssh_key_path" {
  description = "Path to the SSH private key"
  value       = "${path.module}/keys/floquet-louis-${var.project_name}-key.pem"
}

output "ssh_api" {
  description = "SSH to API instance"
  value       = "ssh -i keys/floquet-louis-${var.project_name}-key.pem ec2-user@${aws_instance.api.public_ip}"
}

output "ssh_thread" {
  description = "SSH to Thread instance"
  value       = "ssh -i keys/floquet-louis-${var.project_name}-key.pem ec2-user@${aws_instance.thread.public_ip}"
}

output "ssh_sender" {
  description = "SSH to Sender instance"
  value       = "ssh -i keys/floquet-louis-${var.project_name}-key.pem ec2-user@${aws_instance.sender.public_ip}"
}

output "ssh_db" {
  description = "SSH to Database instance"
  value       = "ssh -i keys/floquet-louis-${var.project_name}-key.pem ec2-user@${aws_instance.db.public_ip}"
}
