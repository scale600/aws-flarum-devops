#!/bin/bash

# RiderHub AWS Resources Cleanup Script
# This script deletes all AWS resources related to the RiderHub project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="riderhub"
AWS_REGION="us-east-1"

echo -e "${GREEN}Starting AWS resources cleanup for $PROJECT_NAME...${NC}"

# Function to delete Lambda functions
delete_lambda_functions() {
    echo -e "${YELLOW}Deleting Lambda functions...${NC}"
    
    # List and delete Lambda functions
    aws lambda list-functions --region $AWS_REGION --query 'Functions[?contains(FunctionName, `'$PROJECT_NAME'`)].FunctionName' --output text | while read function; do
        if [ ! -z "$function" ]; then
            echo "Deleting Lambda function: $function"
            aws lambda delete-function --function-name "$function" --region $AWS_REGION || echo "Failed to delete $function"
        fi
    done
}

# Function to delete API Gateways
delete_api_gateways() {
    echo -e "${YELLOW}Deleting API Gateways...${NC}"
    
    # List and delete API Gateways
    aws apigateway get-rest-apis --region $AWS_REGION --query 'items[?contains(name, `'$PROJECT_NAME'`) || contains(name, `RiderHub`)].id' --output text | while read api_id; do
        if [ ! -z "$api_id" ]; then
            echo "Deleting API Gateway: $api_id"
            aws apigateway delete-rest-api --rest-api-id "$api_id" --region $AWS_REGION || echo "Failed to delete API Gateway $api_id"
        fi
    done
}

# Function to delete DynamoDB tables
delete_dynamodb_tables() {
    echo -e "${YELLOW}Deleting DynamoDB tables...${NC}"
    
    # List and delete DynamoDB tables
    aws dynamodb list-tables --region $AWS_REGION --query 'TableNames[?contains(@, `'$PROJECT_NAME'`)]' --output text | while read table; do
        if [ ! -z "$table" ]; then
            echo "Deleting DynamoDB table: $table"
            aws dynamodb delete-table --table-name "$table" --region $AWS_REGION || echo "Failed to delete table $table"
        fi
    done
}

# Function to delete S3 buckets
delete_s3_buckets() {
    echo -e "${YELLOW}Deleting S3 buckets...${NC}"
    
    # List and delete S3 buckets
    aws s3api list-buckets --region $AWS_REGION --query 'Buckets[?contains(Name, `'$PROJECT_NAME'`)].Name' --output text | while read bucket; do
        if [ ! -z "$bucket" ]; then
            echo "Deleting S3 bucket: $bucket"
            # Empty bucket first
            aws s3 rm s3://$bucket --recursive --region $AWS_REGION || echo "Failed to empty bucket $bucket"
            # Delete bucket
            aws s3api delete-bucket --bucket "$bucket" --region $AWS_REGION || echo "Failed to delete bucket $bucket"
        fi
    done
}

# Function to delete ECR repositories
delete_ecr_repositories() {
    echo -e "${YELLOW}Deleting ECR repositories...${NC}"
    
    # List and delete ECR repositories
    aws ecr describe-repositories --region $AWS_REGION --query 'repositories[?contains(repositoryName, `'$PROJECT_NAME'`)].repositoryName' --output text | while read repo; do
        if [ ! -z "$repo" ]; then
            echo "Deleting ECR repository: $repo"
            aws ecr delete-repository --repository-name "$repo" --force --region $AWS_REGION || echo "Failed to delete repository $repo"
        fi
    done
}

# Function to delete IAM roles
delete_iam_roles() {
    echo -e "${YELLOW}Deleting IAM roles...${NC}"
    
    # List and delete IAM roles
    aws iam list-roles --query 'Roles[?contains(RoleName, `'$PROJECT_NAME'`)].RoleName' --output text | while read role; do
        if [ ! -z "$role" ]; then
            echo "Deleting IAM role: $role"
            # Detach policies first
            aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[].PolicyArn' --output text | while read policy; do
                if [ ! -z "$policy" ]; then
                    aws iam detach-role-policy --role-name "$role" --policy-arn "$policy" || echo "Failed to detach policy $policy"
                fi
            done
            # Delete role
            aws iam delete-role --role-name "$role" || echo "Failed to delete role $role"
        fi
    done
}

# Function to delete SNS topics
delete_sns_topics() {
    echo -e "${YELLOW}Deleting SNS topics...${NC}"
    
    # List and delete SNS topics
    aws sns list-topics --region $AWS_REGION --query 'Topics[?contains(TopicArn, `'$PROJECT_NAME'`)].TopicArn' --output text | while read topic; do
        if [ ! -z "$topic" ]; then
            echo "Deleting SNS topic: $topic"
            aws sns delete-topic --topic-arn "$topic" --region $AWS_REGION || echo "Failed to delete topic $topic"
        fi
    done
}

# Function to delete RDS instances
delete_rds_instances() {
    echo -e "${YELLOW}Deleting RDS instances...${NC}"
    
    # List and delete RDS instances
    aws rds describe-db-instances --region $AWS_REGION --query 'DBInstances[?contains(DBInstanceIdentifier, `'$PROJECT_NAME'`)].DBInstanceIdentifier' --output text | while read instance; do
        if [ ! -z "$instance" ]; then
            echo "Deleting RDS instance: $instance"
            aws rds delete-db-instance --db-instance-identifier "$instance" --skip-final-snapshot --region $AWS_REGION || echo "Failed to delete RDS instance $instance"
        fi
    done
}

# Main cleanup process
echo -e "${GREEN}Starting cleanup process...${NC}"

# Delete resources in order (dependencies first)
delete_lambda_functions
delete_api_gateways
delete_dynamodb_tables
delete_s3_buckets
delete_ecr_repositories
delete_sns_topics
delete_rds_instances
delete_iam_roles

echo -e "${GREEN}Cleanup completed!${NC}"
echo -e "${YELLOW}Note: Some resources may take a few minutes to fully delete.${NC}"