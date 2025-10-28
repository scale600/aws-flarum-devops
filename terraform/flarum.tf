# =============================================================================
# Flarum OSS Infrastructure Configuration - Simplified Version
# =============================================================================

# =============================================================================
# RDS MySQL Database
# =============================================================================
resource "aws_db_subnet_group" "flarum" {
  name       = "${var.project_name}-flarum-db-subnet-group"
  subnet_ids = [data.aws_subnet.private_1.id, data.aws_subnet.private_2.id]

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
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  deletion_protection = false
  
  tags = {
    Name        = "${var.project_name}-flarum-db"
    Service     = "RDS"
    Environment = var.environment
  }
}

# =============================================================================
# VPC and Networking
# =============================================================================
# Use existing VPC instead of creating a new one (VPC limit reached)
data "aws_vpc" "flarum" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-flarum-vpc"]
  }
}

resource "aws_internet_gateway" "flarum" {
  vpc_id = data.aws_vpc.flarum.id

  tags = {
    Name        = "${var.project_name}-flarum-igw"
    Service     = "IGW"
    Environment = var.environment
  }
}

data "aws_subnet" "public_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-flarum-public-1"]
  }
  vpc_id = data.aws_vpc.flarum.id
}

data "aws_subnet" "public_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-flarum-public-2"]
  }
  vpc_id = data.aws_vpc.flarum.id
}

data "aws_subnet" "private_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-flarum-private-1"]
  }
  vpc_id = data.aws_vpc.flarum.id
}

data "aws_subnet" "private_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-flarum-private-2"]
  }
  vpc_id = data.aws_vpc.flarum.id
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.flarum.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flarum.id
  }

  tags = {
    Name        = "${var.project_name}-flarum-public-rt"
    Service     = "RouteTable"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = data.aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = data.aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Security Groups
# =============================================================================
resource "aws_security_group" "lambda" {
  name_prefix = "${var.project_name}-flarum-lambda-"
  vpc_id      = data.aws_vpc.flarum.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-flarum-lambda-sg"
    Service     = "SecurityGroup"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-flarum-rds-"
  vpc_id      = data.aws_vpc.flarum.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-flarum-rds-sg"
    Service     = "SecurityGroup"
    Environment = var.environment
  }
}

# =============================================================================
# S3 Bucket for Flarum Files
# =============================================================================
resource "aws_s3_bucket" "flarum_files" {
  bucket = "${var.project_name}-flarum-files-${random_string.s3_suffix.result}"

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
# ECR Repository for Flarum Docker Image
# =============================================================================
resource "aws_ecr_repository" "flarum" {
  name                 = "${var.project_name}-flarum"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-flarum-ecr"
    Service     = "ECR"
    Environment = var.environment
  }
}

# =============================================================================
# IAM Roles and Policies
# =============================================================================
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-flarum-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-flarum-lambda-execution-role"
    Service     = "IAM"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "lambda_s3_access" {
  name        = "${var.project_name}-flarum-lambda-s3-access"
  description = "Policy for Lambda to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.flarum_files.arn,
          "${aws_s3_bucket.flarum_files.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-flarum-lambda-s3-access"
    Service     = "IAM"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}

# =============================================================================
# Lambda Function
# =============================================================================
resource "aws_lambda_function" "flarum" {
  function_name = "${var.project_name}-flarum"
  role          = aws_iam_role.lambda_execution.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.flarum.repository_url}:${var.image_tag}"

  timeout     = 30
  memory_size = 512

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_1.id, data.aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      APP_ENV           = "production"
      APP_DEBUG         = "false"
      DB_CONNECTION     = "mysql"
      DB_HOST           = aws_db_instance.flarum.endpoint
      DB_PORT           = "3306"
      DB_DATABASE       = "flarum"
      DB_USERNAME       = "flarum"
      DB_PASSWORD       = random_password.db_password.result
      FILESYSTEM_DISK   = "s3"
      AWS_BUCKET        = aws_s3_bucket.flarum_files.bucket
      SESSION_DRIVER    = "array"
      CACHE_DRIVER      = "array"
      QUEUE_CONNECTION  = "sync"
    }
  }

  tags = {
    Name        = "${var.project_name}-flarum"
    Service     = "Lambda"
    Environment = var.environment
  }

  depends_on = [
    aws_ecr_repository.flarum,
    aws_db_instance.flarum
  ]
}

# =============================================================================
# API Gateway
# =============================================================================
resource "aws_api_gateway_rest_api" "flarum" {
  name        = "${var.project_name}-flarum-api"
  description = "RiderHub Flarum API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-flarum-api"
    Service     = "APIGateway"
    Environment = var.environment
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.flarum.id
  parent_id   = aws_api_gateway_rest_api.flarum.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.flarum.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.flarum.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.flarum.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.flarum.id
  resource_id   = aws_api_gateway_rest_api.flarum.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.flarum.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.flarum.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.flarum.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.flarum.execution_arn}/*/*"
}

resource "aws_api_gateway_stage" "flarum" {
  deployment_id = aws_api_gateway_deployment.flarum.id
  rest_api_id   = aws_api_gateway_rest_api.flarum.id
  stage_name    = "production"

  tags = {
    Name        = "${var.project_name}-flarum-api-stage"
    Service     = "APIGateway"
    Environment = var.environment
  }
}

resource "aws_api_gateway_deployment" "flarum" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.flarum.id

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Outputs
# =============================================================================
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_api_gateway_stage.flarum.invoke_url}"
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.flarum.endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name for Flarum files"
  value       = aws_s3_bucket.flarum_files.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.flarum.repository_url
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = "riderhub-flarum"
}
