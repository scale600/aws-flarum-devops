# =============================================================================
# Terraform Variables
# Centralized configuration for all infrastructure resources
# =============================================================================

# =============================================================================
# Core Configuration
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "AWS region must be valid format (e.g., us-east-1)"
  }
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production"
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "riderhub"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project_name))
    error_message = "Project name must be 3-20 characters, lowercase alphanumeric and hyphens only"
  }
}

variable "aws_account_id" {
  description = "AWS Account ID for resource policies"
  type        = string
  default     = "753523452116"

  validation {
    condition     = can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be 12 digits"
  }
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "vpc_id" {
  description = "Existing VPC ID to use (leave empty to use default lookup)"
  type        = string
  default     = "vpc-0a9c03edd4a0eda4f"
}

variable "availability_zones" {
  description = "Availability zones for resource deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# =============================================================================
# EC2 Configuration
# =============================================================================

variable "ec2_instance_type" {
  description = "EC2 instance type for Flarum application"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t[2-4]\\.(nano|micro|small|medium)$", var.ec2_instance_type))
    error_message = "Instance type must be Free Tier eligible (t2-t4 nano/micro/small/medium)"
  }
}

variable "ec2_root_volume_size" {
  description = "Root volume size in GB for EC2 instance"
  type        = number
  default     = 20

  validation {
    condition     = var.ec2_root_volume_size >= 8 && var.ec2_root_volume_size <= 100
    error_message = "Root volume size must be between 8 and 100 GB"
  }
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

# =============================================================================
# RDS Configuration
# =============================================================================

variable "rds_instance_class" {
  description = "RDS instance class for MySQL database"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.t[3-4]\\.(micro|small)$", var.rds_instance_class))
    error_message = "RDS instance class must be Free Tier eligible (db.t3/t4 micro/small)"
  }
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS instance"
  type        = number
  default     = 20

  validation {
    condition     = var.rds_allocated_storage >= 20 && var.rds_allocated_storage <= 100
    error_message = "RDS storage must be between 20 and 100 GB (Free Tier limit)"
  }
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 7

  validation {
    condition     = var.rds_backup_retention_period >= 0 && var.rds_backup_retention_period <= 35
    error_message = "Backup retention must be between 0 and 35 days"
  }
}

variable "rds_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "flarum"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,63}$", var.rds_database_name))
    error_message = "Database name must start with letter, contain only alphanumerics and underscore, max 64 chars"
  }
}

variable "rds_username" {
  description = "Master username for RDS database"
  type        = string
  default     = "flarum"
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{2,15}$", var.rds_username))
    error_message = "Username must start with letter, 3-16 characters, alphanumerics and underscore only"
  }
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip final snapshot when destroying RDS instance"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Whether to enable deletion protection for RDS instance"
  type        = bool
  default     = false
}

# =============================================================================
# S3 Configuration
# =============================================================================

variable "s3_versioning_enabled" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Allow Terraform to destroy S3 bucket with objects"
  type        = bool
  default     = false
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All values must be valid CIDR blocks"
  }
}

variable "enable_https" {
  description = "Enable HTTPS listener on load balancer"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS (required if enable_https is true)"
  type        = string
  default     = ""
}

# =============================================================================
# Application Configuration
# =============================================================================

variable "flarum_version" {
  description = "Flarum version to install"
  type        = string
  default     = "latest"
}

variable "image_tag" {
  description = "Docker image tag for Lambda function"
  type        = string
  default     = "latest"
}

# =============================================================================
# Monitoring and Logging
# =============================================================================

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for application"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention period"
  }
}

# =============================================================================
# Tags
# =============================================================================

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

