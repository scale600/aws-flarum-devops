# =============================================================================
# Local Values
# Computed values and constants used across resources
# =============================================================================

locals {
  # =============================================================================
  # Naming Conventions
  # =============================================================================
  
  resource_prefix = "${var.project_name}-flarum"
  
  name_tags = {
    ec2_instance           = "${local.resource_prefix}-core"
    alb                    = "${local.resource_prefix}-alb"
    target_group           = "${local.resource_prefix}-tg"
    rds_instance           = "${local.resource_prefix}-db"
    rds_subnet_group       = "${local.resource_prefix}-db-subnet-group"
    s3_bucket              = "${local.resource_prefix}-files"
    security_group_web     = "${local.resource_prefix}-web-sg"
    security_group_rds     = "${local.resource_prefix}-rds-sg"
    iam_role               = "${local.resource_prefix}-instance-role"
    iam_instance_profile   = "${local.resource_prefix}-instance-profile"
    iam_policy_s3          = "${local.resource_prefix}-s3-policy"
    key_pair               = "${local.resource_prefix}-key"
    internet_gateway       = "${local.resource_prefix}-igw"
    route_table_public     = "${local.resource_prefix}-public-rt"
    subnet_public_1        = "${local.resource_prefix}-public-1"
    subnet_public_2        = "${local.resource_prefix}-public-2"
    subnet_private_1       = "${local.resource_prefix}-private-1"
    subnet_private_2       = "${local.resource_prefix}-private-2"
    cloudwatch_log_group   = "/aws/flarum/${var.project_name}"
  }
  
  # =============================================================================
  # Tags
  # =============================================================================
  
  common_tags = merge(
    {
      Project     = "RiderHub"
      Application = "Flarum"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
    },
    var.additional_tags
  )
  
  # =============================================================================
  # Network Configuration
  # =============================================================================
  
  availability_zones = var.availability_zones
  
  public_subnets = [
    {
      cidr_block        = var.public_subnet_cidrs[0]
      availability_zone = local.availability_zones[0]
      name              = local.name_tags.subnet_public_1
    },
    {
      cidr_block        = var.public_subnet_cidrs[1]
      availability_zone = local.availability_zones[1]
      name              = local.name_tags.subnet_public_2
    }
  ]
  
  private_subnets = [
    {
      cidr_block        = var.private_subnet_cidrs[0]
      availability_zone = local.availability_zones[0]
      name              = local.name_tags.subnet_private_1
    },
    {
      cidr_block        = var.private_subnet_cidrs[1]
      availability_zone = local.availability_zones[1]
      name              = local.name_tags.subnet_private_2
    }
  ]
  
  # =============================================================================
  # Security Group Rules
  # =============================================================================
  
  web_ingress_rules = [
    {
      description = "HTTP from Internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from Internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH from allowed IPs"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  ]
  
  # =============================================================================
  # ALB Configuration
  # =============================================================================
  
  alb_health_check = {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health.php"
    matcher             = "200,302"
    protocol            = "HTTP"
  }
  
  # =============================================================================
  # RDS Configuration
  # =============================================================================
  
  rds_config = {
    engine                = "mysql"
    engine_version        = "8.0"
    instance_class        = var.rds_instance_class
    allocated_storage     = var.rds_allocated_storage
    max_allocated_storage = 100
    storage_type          = "gp2"
    storage_encrypted     = true
    db_name               = var.rds_database_name
    username              = var.rds_username
    port                  = 3306
    backup_window         = "03:00-04:00"
    maintenance_window    = "sun:04:00-sun:05:00"
  }
  
  # =============================================================================
  # EC2 Configuration
  # =============================================================================
  
  ec2_config = {
    instance_type = var.ec2_instance_type
    volume_type   = "gp3"
    volume_size   = var.ec2_root_volume_size
    encrypted     = true
  }
  
  # =============================================================================
  # IAM Policies
  # =============================================================================
  
  s3_policy_actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:GetObjectVersion"
  ]
  
  ssm_managed_policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
  # =============================================================================
  # User Data Template Variables
  # =============================================================================
  
  user_data_vars = {
    db_host     = try(aws_db_instance.flarum.endpoint, "")
    db_port     = local.rds_config.port
    db_name     = local.rds_config.db_name
    db_username = local.rds_config.username
    db_password = try(random_password.db_password.result, "")
    s3_bucket   = try(aws_s3_bucket.flarum_files.bucket, "")
    aws_region  = var.aws_region
    environment = var.environment
    project     = var.project_name
  }
  
  # =============================================================================
  # Computed Values
  # =============================================================================
  
  # Get latest Amazon Linux 2 AMI if not specified
  use_latest_ami = var.ami_id == ""
  
  # Determine if HTTPS should be configured
  configure_https = var.enable_https && var.certificate_arn != ""
  
  # SSH key file path
  ssh_key_path = "${path.module}/${local.name_tags.key_pair}.pem"
  
  # Output URLs
  http_url  = "http://${try(aws_lb.flarum.dns_name, "")}"
  https_url = "https://${try(aws_lb.flarum.dns_name, "")}"
  forum_url = local.configure_https ? local.https_url : local.http_url
}

