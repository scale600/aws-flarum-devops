#!/bin/bash

# =============================================================================
# AWS Resources Cleanup Script for RiderHub Project
# =============================================================================
# This script automatically deletes all AWS resources related to the RiderHub
# project to ensure a clean state for fresh deployments.
#
# Usage: ./scripts/cleanup-aws-resources.sh [profile_name]
# Example: ./scripts/cleanup-aws-resources.sh riderhub
#
# Author: Richard Lee
# Version: 1.0.0
# =============================================================================

set -e  # Exit on any error

# =============================================================================
# Configuration
# =============================================================================
PROJECT_NAME="riderhub"
AWS_REGION="us-east-1"
PROFILE_NAME="${1:-riderhub}"  # Use first argument or default to 'riderhub'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Utility Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
}

check_profile() {
    if ! aws sts get-caller-identity --profile "$PROFILE_NAME" &> /dev/null; then
        log_error "AWS profile '$PROFILE_NAME' not found or invalid."
        exit 1
    fi
}

wait_for_deletion() {
    local resource_type="$1"
    local resource_name="$2"
    local max_attempts=30
    local attempt=0
    
    log_info "Waiting for $resource_type '$resource_name' to be deleted..."
    
    while [ $attempt -lt $max_attempts ]; do
        if ! aws "$resource_type" describe-table --table-name "$resource_name" --profile "$PROFILE_NAME" --region "$AWS_REGION" &> /dev/null 2>&1; then
            log_success "$resource_type '$resource_name' deleted successfully"
            return 0
        fi
        
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_warning "$resource_type '$resource_name' deletion may still be in progress"
}

# =============================================================================
# Resource Deletion Functions
# =============================================================================

delete_lambda_functions() {
    log_info "Deleting Lambda functions..."
    
    local functions=$(aws lambda list-functions --profile "$PROFILE_NAME" --region "$AWS_REGION" \
        --query "Functions[?contains(FunctionName, '$PROJECT_NAME')].FunctionName" --output text)
    
    if [ -z "$functions" ]; then
        log_info "No Lambda functions found"
        return 0
    fi
    
    for function in $functions; do
        log_info "Deleting Lambda function: $function"
        aws lambda delete-function --profile "$PROFILE_NAME" --region "$AWS_REGION" --function-name "$function" || true
    done
    
    log_success "Lambda functions deletion completed"
}

delete_dynamodb_tables() {
    log_info "Deleting DynamoDB tables..."
    
    local tables=$(aws dynamodb list-tables --profile "$PROFILE_NAME" --region "$AWS_REGION" \
        --query "TableNames[?contains(@, '$PROJECT_NAME')]" --output text)
    
    if [ -z "$tables" ]; then
        log_info "No DynamoDB tables found"
        return 0
    fi
    
    for table in $tables; do
        log_info "Deleting DynamoDB table: $table"
        aws dynamodb delete-table --profile "$PROFILE_NAME" --region "$AWS_REGION" --table-name "$table" || true
        wait_for_deletion "dynamodb" "$table"
    done
    
    log_success "DynamoDB tables deletion completed"
}

delete_s3_buckets() {
    log_info "Deleting S3 buckets..."
    
    local buckets=$(aws s3 ls --profile "$PROFILE_NAME" --region "$AWS_REGION" | grep "$PROJECT_NAME" | awk '{print $3}')
    
    if [ -z "$buckets" ]; then
        log_info "No S3 buckets found"
        return 0
    fi
    
    for bucket in $buckets; do
        log_info "Deleting S3 bucket: $bucket"
        
        # Empty bucket first
        aws s3 rm s3://"$bucket" --recursive --profile "$PROFILE_NAME" --region "$AWS_REGION" || true
        
        # Delete bucket
        aws s3 rb s3://"$bucket" --profile "$PROFILE_NAME" --region "$AWS_REGION" --force || true
    done
    
    log_success "S3 buckets deletion completed"
}

delete_ecr_repositories() {
    log_info "Deleting ECR repositories..."
    
    local repositories=$(aws ecr describe-repositories --profile "$PROFILE_NAME" --region "$AWS_REGION" \
        --query "repositories[?contains(repositoryName, '$PROJECT_NAME')].repositoryName" --output text)
    
    if [ -z "$repositories" ]; then
        log_info "No ECR repositories found"
        return 0
    fi
    
    for repo in $repositories; do
        log_info "Deleting ECR repository: $repo"
        aws ecr delete-repository --profile "$PROFILE_NAME" --region "$AWS_REGION" --repository-name "$repo" --force || true
    done
    
    log_success "ECR repositories deletion completed"
}

delete_api_gateways() {
    log_info "Deleting API Gateway instances..."
    
    local apis=$(aws apigateway get-rest-apis --profile "$PROFILE_NAME" --region "$AWS_REGION" \
        --query "items[?contains(name, '$PROJECT_NAME')].id" --output text)
    
    if [ -z "$apis" ]; then
        log_info "No API Gateway instances found"
        return 0
    fi
    
    for api_id in $apis; do
        log_info "Deleting API Gateway: $api_id"
        aws apigateway delete-rest-api --profile "$PROFILE_NAME" --region "$AWS_REGION" --rest-api-id "$api_id" || true
        
        # Add delay to avoid rate limiting
        sleep 1
    done
    
    log_success "API Gateway instances deletion completed"
}

delete_iam_resources() {
    log_info "Deleting IAM roles and policies..."
    
    # List roles with project name
    local roles=$(aws iam list-roles --profile "$PROFILE_NAME" \
        --query "Roles[?contains(RoleName, '$PROJECT_NAME')].RoleName" --output text)
    
    if [ -z "$roles" ]; then
        log_info "No IAM roles found"
        return 0
    fi
    
    for role in $roles; do
        log_info "Deleting IAM role: $role"
        
        # Delete inline policies first
        local policies=$(aws iam list-role-policies --profile "$PROFILE_NAME" --role-name "$role" \
            --query "PolicyNames" --output text)
        
        for policy in $policies; do
            log_info "Deleting inline policy: $policy"
            aws iam delete-role-policy --profile "$PROFILE_NAME" --role-name "$role" --policy-name "$policy" || true
        done
        
        # Detach managed policies
        local attached_policies=$(aws iam list-attached-role-policies --profile "$PROFILE_NAME" --role-name "$role" \
            --query "AttachedPolicies[].PolicyArn" --output text)
        
        for policy_arn in $attached_policies; do
            log_info "Detaching managed policy: $policy_arn"
            aws iam detach-role-policy --profile "$PROFILE_NAME" --role-name "$role" --policy-arn "$policy_arn" || true
        done
        
        # Delete the role
        aws iam delete-role --profile "$PROFILE_NAME" --role-name "$role" || true
    done
    
    log_success "IAM resources deletion completed"
}

delete_sns_topics() {
    log_info "Deleting SNS topics..."
    
    local topics=$(aws sns list-topics --profile "$PROFILE_NAME" --region "$AWS_REGION" \
        --query "Topics[?contains(TopicArn, '$PROJECT_NAME')].TopicArn" --output text)
    
    if [ -z "$topics" ]; then
        log_info "No SNS topics found"
        return 0
    fi
    
    for topic_arn in $topics; do
        log_info "Deleting SNS topic: $topic_arn"
        aws sns delete-topic --profile "$PROFILE_NAME" --region "$AWS_REGION" --topic-arn "$topic_arn" || true
    done
    
    log_success "SNS topics deletion completed"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    log_info "Starting AWS resources cleanup for RiderHub project"
    log_info "Using AWS profile: $PROFILE_NAME"
    log_info "Using AWS region: $AWS_REGION"
    echo
    
    # Pre-flight checks
    check_aws_cli
    check_profile
    
    # Confirm deletion (auto-confirm for DevOps hands-on project)
    echo -e "${YELLOW}This will delete ALL AWS resources related to the '$PROJECT_NAME' project.${NC}"
    echo -e "${YELLOW}This action cannot be undone.${NC}"
    echo -e "${GREEN}Auto-confirming for DevOps hands-on project...${NC}"
    echo
    
    # Delete resources in order (dependencies first)
    delete_lambda_functions
    delete_api_gateways
    delete_dynamodb_tables
    delete_s3_buckets
    delete_ecr_repositories
    delete_sns_topics
    delete_iam_resources
    
    echo
    log_success "AWS resources cleanup completed successfully!"
    log_info "You can now run a fresh deployment using GitHub Actions"
}

# Run main function
main "$@"
