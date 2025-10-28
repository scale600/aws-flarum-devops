# =============================================================================
# Terraform Outputs - Simplified EC2-Only Deployment
# =============================================================================

# =============================================================================
# Application Access
# =============================================================================

output "flarum_url" {
  description = "Public URL to access the Flarum forum (EC2 public IP)"
  value       = "http://${aws_instance.flarum.public_ip}"
}

# =============================================================================
# EC2 Instance Information
# =============================================================================

output "ec2_instance_id" {
  description = "ID of the Flarum EC2 instance"
  value       = aws_instance.flarum.id
}

output "ec2_public_ip" {
  description = "Public IP address of the Flarum EC2 instance"
  value       = aws_instance.flarum.public_ip
}

output "ec2_private_ip" {
  description = "Private IP address of the Flarum EC2 instance"
  value       = aws_instance.flarum.private_ip
}

# =============================================================================
# SSH Access
# =============================================================================

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${path.module}/${var.project_name}-flarum-key.pem ec2-user@${aws_instance.flarum.public_ip}"
}

output "ssh_key_path" {
  description = "Path to the private SSH key"
  value       = "${path.module}/${var.project_name}-flarum-key.pem"
}

# =============================================================================
# Architecture Information
# =============================================================================

output "architecture" {
  description = "Deployment architecture"
  value       = "Standalone EC2 - All-in-One (MySQL + Apache + Flarum + Storage)"
}

output "database_location" {
  description = "Database location"
  value       = "Local MySQL on EC2 (localhost:3306)"
}

output "storage_location" {
  description = "File storage location"
  value       = "Local filesystem on EC2 (/var/www/flarum/storage)"
}

# =============================================================================
# Cost Information
# =============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (USD)"
  value       = "$8/month (EC2 t3.micro) - AWS Free Tier eligible"
}

