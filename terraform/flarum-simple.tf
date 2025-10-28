# =============================================================================
# Simplified Flarum Infrastructure - EC2 ONLY
# No RDS, No S3 - Everything on one EC2 instance
# =============================================================================

# This file contains only the essential resources for a simple EC2-based deployment
# MySQL database runs locally on EC2
# Files stored locally on EC2
# Simplest possible architecture

# Note: Main resources (VPC, subnets, EC2) are in flarum-core.tf
# This file just removes RDS and S3 dependencies

