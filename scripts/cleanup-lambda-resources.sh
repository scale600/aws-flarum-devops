#!/bin/bash

# =============================================================================
# Cleanup Lambda and API Gateway Resources
# =============================================================================

set -e

echo "🧹 Starting cleanup of Lambda and API Gateway resources..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "AWS credentials verified"

# Get the current AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

print_status "Cleaning up resources in account: $ACCOUNT_ID, region: $REGION"

# List of resources to delete
LAMBDA_FUNCTION="riderhub-flarum"
API_GATEWAY_NAME="riderhub-flarum-api"
ECR_REPOSITORY="riderhub-flarum"

# 1. Delete Lambda Function
print_status "Deleting Lambda function: $LAMBDA_FUNCTION"
if aws lambda get-function --function-name "$LAMBDA_FUNCTION" > /dev/null 2>&1; then
    aws lambda delete-function --function-name "$LAMBDA_FUNCTION"
    print_status "✅ Lambda function deleted"
else
    print_warning "Lambda function $LAMBDA_FUNCTION not found"
fi

# 2. Delete API Gateway
print_status "Deleting API Gateway: $API_GATEWAY_NAME"
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_GATEWAY_NAME'].id" --output text)
if [ "$API_ID" != "None" ] && [ -n "$API_ID" ]; then
    aws apigateway delete-rest-api --rest-api-id "$API_ID"
    print_status "✅ API Gateway deleted (ID: $API_ID)"
else
    print_warning "API Gateway $API_GATEWAY_NAME not found"
fi

# 3. Delete ECR Repository (optional - keep if you want to reuse)
print_warning "ECR Repository $ECR_REPOSITORY will be kept for potential reuse"
print_status "To delete ECR repository manually, run:"
echo "aws ecr delete-repository --repository-name $ECR_REPOSITORY --force"

# 4. Clean up old Docker images locally
print_status "Cleaning up local Docker images..."
docker images | grep -E "(riderhub|flarum)" | awk '{print $3}' | xargs -r docker rmi -f
print_status "✅ Local Docker images cleaned up"

# 5. List remaining resources
print_status "Remaining resources:"
echo "✅ RDS MySQL Database (kept for Flarum)"
echo "✅ S3 Bucket (kept for Flarum)"  
echo "✅ VPC and Subnets (kept for Flarum)"
echo "✅ Security Groups (kept for Flarum)"
echo "✅ IAM Roles (kept for Flarum)"

print_status "🎉 Cleanup completed successfully!"
print_status "Next step: Deploy Flarum core infrastructure with 'terraform apply'"

