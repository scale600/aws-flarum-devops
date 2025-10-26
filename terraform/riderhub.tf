# RiderHub Infrastructure Configuration

# DynamoDB Tables
resource "aws_dynamodb_table" "posts" {
  name           = "${var.project_name}-posts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "postId"
  
  attribute {
    name = "postId"
    type = "S"
  }
  
  attribute {
    name = "userId"
    type = "S"
  }
  
  global_secondary_index {
    name               = "userId-index"
    hash_key           = "userId"
    projection_type    = "ALL"
  }
  
  tags = {
    Name = "${var.project_name}-posts"
  }
}

resource "aws_dynamodb_table" "comments" {
  name           = "${var.project_name}-comments"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "commentId"
  
  attribute {
    name = "commentId"
    type = "S"
  }
  
  attribute {
    name = "postId"
    type = "S"
  }
  
  global_secondary_index {
    name               = "postId-index"
    hash_key           = "postId"
    projection_type    = "ALL"
  }
  
  tags = {
    Name = "${var.project_name}-comments"
  }
}

# S3 Bucket for Media Storage
resource "aws_s3_bucket" "media" {
  bucket = "${var.project_name}-media-${random_string.bucket_suffix.result}"
  
  tags = {
    Name = "${var.project_name}-media"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lambda Function
resource "aws_lambda_function" "riderhub" {
  function_name = "${var.project_name}-api"
  role         = aws_iam_role.lambda_role.arn
  package_type = "Image"
  image_uri    = "${aws_ecr_repository.riderhub.repository_url}:latest"
  
  timeout     = 30
  memory_size = 512
  
  environment {
    variables = {
      DYNAMODB_POSTS_TABLE    = aws_dynamodb_table.posts.name
      DYNAMODB_COMMENTS_TABLE = aws_dynamodb_table.comments.name
      S3_MEDIA_BUCKET         = aws_s3_bucket.media.bucket
    }
  }
  
  tags = {
    Name = "${var.project_name}-api"
  }
}

# ECR Repository
resource "aws_ecr_repository" "riderhub" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name = "${var.project_name}-ecr"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  
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
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.posts.arn,
          aws_dynamodb_table.comments.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.media.arn}/*"
      }
    ]
  })
}

# API Gateway
resource "aws_api_gateway_rest_api" "riderhub" {
  name        = "${var.project_name}-api"
  description = "RiderHub API Gateway"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "posts" {
  rest_api_id = aws_api_gateway_rest_api.riderhub.id
  parent_id   = aws_api_gateway_rest_api.riderhub.root_resource_id
  path_part   = "posts"
}

resource "aws_api_gateway_method" "posts" {
  rest_api_id   = aws_api_gateway_rest_api.riderhub.id
  resource_id   = aws_api_gateway_resource.posts.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "posts" {
  rest_api_id = aws_api_gateway_rest_api.riderhub.id
  resource_id = aws_api_gateway_resource.posts.id
  http_method = aws_api_gateway_method.posts.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.riderhub.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.riderhub.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.riderhub.execution_arn}/*/*"
}

resource "aws_api_gateway_stage" "riderhub" {
  deployment_id = aws_api_gateway_deployment.riderhub.id
  rest_api_id   = aws_api_gateway_rest_api.riderhub.id
  stage_name    = var.environment
}

resource "aws_api_gateway_deployment" "riderhub" {
  depends_on = [
    aws_api_gateway_integration.posts
  ]
  
  rest_api_id = aws_api_gateway_rest_api.riderhub.id
}

# SNS Topic for Notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-notifications"
  
  tags = {
    Name = "${var.project_name}-notifications"
  }
}

# Outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_api_gateway_stage.riderhub.invoke_url
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.riderhub.repository_url
}

output "s3_bucket_name" {
  description = "S3 Media Bucket Name"
  value       = aws_s3_bucket.media.bucket
}

output "dynamodb_posts_table" {
  description = "DynamoDB Posts Table Name"
  value       = aws_dynamodb_table.posts.name
}

output "dynamodb_comments_table" {
  description = "DynamoDB Comments Table Name"
  value       = aws_dynamodb_table.comments.name
}

output "lambda_function_name" {
  description = "Lambda Function Name"
  value       = aws_lambda_function.riderhub.function_name
}
