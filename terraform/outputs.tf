# =============================================================================
# Terraform Outputs
# Exposed values for external consumption
# =============================================================================

# =============================================================================
# Application Endpoints
# =============================================================================

output "flarum_url" {
  description = "Public URL to access the Flarum forum"
  value       = local.forum_url
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.flarum.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer (for Route53)"
  value       = aws_lb.flarum.zone_id
}

# =============================================================================
# EC2 Instance Information
# =============================================================================

output "ec2_instance_id" {
  description = "ID of the Flarum EC2 instance"
  value       = aws_instance.flarum.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the Flarum EC2 instance"
  value       = aws_instance.flarum.public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the Flarum EC2 instance"
  value       = aws_instance.flarum.private_ip
}

output "ssh_key_path" {
  description = "Path to the private SSH key for EC2 access"
  value       = local.ssh_key_path
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local.ssh_key_path} ec2-user@${aws_instance.flarum.public_ip}"
}

# =============================================================================
# Database Information
# =============================================================================

output "rds_endpoint" {
  description = "Connection endpoint for the RDS MySQL database"
  value       = aws_db_instance.flarum.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Name of the created database"
  value       = aws_db_instance.flarum.db_name
}

output "rds_username" {
  description = "Master username for the database"
  value       = aws_db_instance.flarum.username
  sensitive   = true
}

output "rds_port" {
  description = "Port number for database connections"
  value       = aws_db_instance.flarum.port
}

output "rds_instance_id" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.flarum.id
}

# =============================================================================
# Storage Information
# =============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for file storage"
  value       = aws_s3_bucket.flarum_files.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.flarum_files.arn
}

output "s3_bucket_region" {
  description = "Region where the S3 bucket is located"
  value       = aws_s3_bucket.flarum_files.region
}

# =============================================================================
# Network Information
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = data.aws_vpc.flarum.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "security_group_web_id" {
  description = "ID of the web security group"
  value       = aws_security_group.flarum_web.id
}

output "security_group_rds_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

# =============================================================================
# IAM Information
# =============================================================================

output "iam_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.flarum_instance.arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.flarum.name
}

# =============================================================================
# Application Configuration
# =============================================================================

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

# =============================================================================
# Quick Access Information
# =============================================================================

output "quick_access_info" {
  description = "Quick access information for the deployment"
  value = {
    forum_url     = local.forum_url
    ssh_command   = "ssh -i ${local.ssh_key_path} ec2-user@${aws_instance.flarum.public_ip}"
    db_endpoint   = aws_db_instance.flarum.endpoint
    s3_bucket     = aws_s3_bucket.flarum_files.bucket
    environment   = var.environment
    deployed_at   = timestamp()
  }
  sensitive = true
}

# =============================================================================
# Connection Strings
# =============================================================================

output "database_connection_string" {
  description = "Database connection string (without password)"
  value       = "mysql://${aws_db_instance.flarum.username}:PASSWORD@${aws_db_instance.flarum.endpoint}/${aws_db_instance.flarum.db_name}"
  sensitive   = true
}

output "s3_connection_info" {
  description = "S3 bucket connection information"
  value = {
    bucket_name = aws_s3_bucket.flarum_files.bucket
    region      = aws_s3_bucket.flarum_files.region
    arn         = aws_s3_bucket.flarum_files.arn
  }
}

# =============================================================================
# Monitoring Information
# =============================================================================

output "cloudwatch_log_group" {
  description = "CloudWatch log group name for application logs"
  value       = local.name_tags.cloudwatch_log_group
}

output "monitoring_dashboard_url" {
  description = "URL to CloudWatch monitoring dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:"
}

# =============================================================================
# Cost Estimation
# =============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost (AWS Free Tier eligible)"
  value = {
    ec2     = "Free Tier: 750 hours/month"
    rds     = "Free Tier: 750 hours/month, 20GB storage"
    alb     = "Free Tier: 750 hours/month"
    s3      = "Free Tier: 5GB storage, 20K GET requests, 2K PUT requests"
    total   = "$0 within Free Tier limits"
    warning = "Monitor usage to stay within Free Tier limits"
  }
}

