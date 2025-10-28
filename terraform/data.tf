# =============================================================================
# Data Sources
# External data lookups and references
# =============================================================================

# =============================================================================
# VPC Data Source
# =============================================================================

data "aws_vpc" "flarum" {
  id = var.vpc_id
}

# =============================================================================
# AMI Data Source
# Get latest Amazon Linux 2 AMI if not specified
# =============================================================================

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# =============================================================================
# Availability Zones Data Source
# =============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# Current AWS Account and Region
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# =============================================================================
# IAM Policy Document for EC2 Instance Role
# =============================================================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# =============================================================================
# IAM Policy Document for S3 Access
# =============================================================================

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"

    actions = local.s3_policy_actions

    resources = [
      aws_s3_bucket.flarum_files.arn,
      "${aws_s3_bucket.flarum_files.arn}/*"
    ]
  }
}

