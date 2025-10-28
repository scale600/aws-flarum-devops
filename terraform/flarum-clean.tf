# =============================================================================
# Flarum Core Infrastructure - Clean Version (No Lambda/API Gateway)
# =============================================================================

# =============================================================================
# RDS MySQL Database (Keep - Essential for Flarum)
# =============================================================================
resource "aws_db_subnet_group" "flarum" {
  name       = "${var.project_name}-flarum-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name        = "${var.project_name}-flarum-db-subnet-group"
    Service     = "RDS"
    Environment = var.environment
  }
}

resource "aws_db_instance" "flarum" {
  identifier = "${var.project_name}-flarum-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name  = "flarum"
  username = "flarum"
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.flarum.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "${var.project_name}-flarum-db"
    Service     = "RDS"
    Environment = var.environment
  }
}

# =============================================================================
# S3 Bucket for File Storage (Keep - Essential for Flarum)
# =============================================================================
resource "aws_s3_bucket" "flarum_files" {
  bucket = "${var.project_name}-flarum-files-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-flarum-files"
    Service     = "S3"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "flarum_files" {
  bucket = aws_s3_bucket.flarum_files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flarum_files" {
  bucket = aws_s3_bucket.flarum_files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flarum_files" {
  bucket = aws_s3_bucket.flarum_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================================
# VPC and Networking (Keep - Essential for Flarum)
# =============================================================================
# VPC data source moved to data.tf to avoid duplication

# Route table moved to flarum-core.tf

# Route table associations handled in flarum-core.tf

# =============================================================================
# Security Groups (Keep - Essential for Flarum)
# =============================================================================
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-flarum-rds-"
  vpc_id      = data.aws_vpc.flarum.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.flarum.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-flarum-rds-sg"
    Service     = "RDS"
    Environment = var.environment
  }
}

# =============================================================================
# Random Resources
# =============================================================================
resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# Outputs
# =============================================================================
# All outputs moved to outputs.tf to avoid duplication
