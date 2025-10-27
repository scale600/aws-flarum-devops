# AWS Account-Specific Setup Guide

**AWS Account ID**: `753523452116`  
**Region**: `us-east-1`

This document provides specific setup instructions tailored for this AWS account.

## 🔐 GitHub Secrets Configuration Values

### **Required Secrets**

| Secret Name             | Value      | Description                  |
| ----------------------- | ---------- | ---------------------------- |
| `AWS_ACCESS_KEY_ID`     | `AKIA...`  | IAM user's access key ID     |
| `AWS_SECRET_ACCESS_KEY` | `wJalr...` | IAM user's secret access key |
| `AMPLIFY_APP_ID`        | `d...`     | Amplify app ID               |

### **Additional Recommended Secrets**

| Secret Name               | Value                     | Description             |
| ------------------------- | ------------------------- | ----------------------- |
| `AWS_REGION`              | `us-east-1`               | AWS region              |
| `ECR_REPOSITORY`          | `riderhub`                | ECR repository name     |
| `LAMBDA_FUNCTION_NAME`    | `riderhub-api`            | Lambda function name    |
| `DYNAMODB_POSTS_TABLE`    | `riderhub-posts`          | DynamoDB posts table    |
| `DYNAMODB_COMMENTS_TABLE` | `riderhub-comments`       | DynamoDB comments table |
| `S3_MEDIA_BUCKET`         | `riderhub-media-xxxxxxxx` | S3 media bucket         |

## 🏗️ AWS Resource ARN Information

### **ECR Repository**

```
Repository URI: 753523452116.dkr.ecr.us-east-1.amazonaws.com/riderhub
```

### **Lambda Function**

```
Function ARN: arn:aws:lambda:us-east-1:753523452116:function:riderhub-api
```

### **DynamoDB Tables**

```
Posts Table ARN: arn:aws:dynamodb:us-east-1:753523452116:table/riderhub-posts
Comments Table ARN: arn:aws:dynamodb:us-east-1:753523452116:table/riderhub-comments
```

### **S3 Bucket**

```
Media Bucket ARN: arn:aws:s3:::riderhub-media-xxxxxxxx
```

### **API Gateway**

```
API Gateway URL: https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/production
```

### **SNS Topic**

```
Notifications Topic ARN: arn:aws:sns:us-east-1:753523452116:riderhub-notifications
```

## 🔧 Quick Setup Commands

### 1. Verify AWS Account

```bash
# Check current AWS account
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "753523452116",
#     "Arn": "arn:aws:iam::753523452116:user/YourUsername"
# }
```

### 2. Create IAM User for CI/CD

```bash
# Create IAM user
aws iam create-user --user-name riderhub-ci-cd

# Create and attach policy
aws iam put-user-policy --user-name riderhub-ci-cd --policy-name RiderHubCIPolicy --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:*",
                "lambda:*",
                "dynamodb:*",
                "s3:*",
                "apigateway:*",
                "iam:*",
                "sns:*",
                "amplify:*",
                "cloudformation:*"
            ],
            "Resource": "*"
        }
    ]
}'

# Create access key
aws iam create-access-key --user-name riderhub-ci-cd
```

### 3. Create ECR Repository

```bash
# Create ECR repository
aws ecr create-repository --repository-name riderhub --region us-east-1

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 753523452116.dkr.ecr.us-east-1.amazonaws.com
```

### 4. Create DynamoDB Tables

```bash
# Create posts table
aws dynamodb create-table \
    --table-name riderhub-posts \
    --attribute-definitions \
        AttributeName=postId,AttributeType=S \
        AttributeName=userId,AttributeType=S \
    --key-schema \
        AttributeName=postId,KeyType=HASH \
    --global-secondary-indexes \
        IndexName=userId-index,KeySchema=[{AttributeName=userId,KeyType=HASH}],Projection={ProjectionType=ALL} \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1

# Create comments table
aws dynamodb create-table \
    --table-name riderhub-comments \
    --attribute-definitions \
        AttributeName=commentId,AttributeType=S \
        AttributeName=postId,AttributeType=S \
    --key-schema \
        AttributeName=commentId,KeyType=HASH \
    --global-secondary-indexes \
        IndexName=postId-index,KeySchema=[{AttributeName=postId,KeyType=HASH}],Projection={ProjectionType=ALL} \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

### 5. Create S3 Bucket

```bash
# Create S3 bucket with unique suffix
BUCKET_NAME="riderhub-media-$(openssl rand -hex 4)"
aws s3 mb s3://$BUCKET_NAME --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

## 🌐 AWS Console Direct Links

### **Main Services**

- [AWS Console Home](https://console.aws.amazon.com/)
- [IAM Console](https://console.aws.amazon.com/iam/)
- [ECR Console](https://console.aws.amazon.com/ecr/)
- [Lambda Console](https://console.aws.amazon.com/lambda/)
- [DynamoDB Console](https://console.aws.amazon.com/dynamodb/)
- [S3 Console](https://console.aws.amazon.com/s3/)
- [API Gateway Console](https://console.aws.amazon.com/apigateway/)
- [Amplify Console](https://console.aws.amazon.com/amplify/)
- [SNS Console](https://console.aws.amazon.com/sns/)

### **Account-Specific Links**

- [Account 753523452116 IAM Users](https://console.aws.amazon.com/iam/home#/users)
- [Account 753523452116 ECR Repositories](https://console.aws.amazon.com/ecr/repositories?region=us-east-1)
- [Account 753523452116 Lambda Functions](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions)
- [Account 753523452116 DynamoDB Tables](https://console.aws.amazon.com/dynamodb/home?region=us-east-1#/tables)
- [Account 753523452116 S3 Buckets](https://console.aws.amazon.com/s3/home?region=us-east-1)

## 🔍 Resource Verification

### Check All Resources

```bash
# List all ECR repositories
aws ecr describe-repositories --region us-east-1

# List all Lambda functions
aws lambda list-functions --region us-east-1

# List all DynamoDB tables
aws dynamodb list-tables --region us-east-1

# List all S3 buckets
aws s3 ls

# List all API Gateways
aws apigateway get-rest-apis --region us-east-1

# List all Amplify apps
aws amplify list-apps --region us-east-1

# List all SNS topics
aws sns list-topics --region us-east-1
```

### Check Resource Status

```bash
# Check DynamoDB table status
aws dynamodb describe-table --table-name riderhub-posts --region us-east-1 --query 'Table.TableStatus'
aws dynamodb describe-table --table-name riderhub-comments --region us-east-1 --query 'Table.TableStatus'

# Check Lambda function status
aws lambda get-function --function-name riderhub-api --region us-east-1 --query 'Configuration.State'

# Check S3 bucket status
aws s3api head-bucket --bucket riderhub-media-xxxxxxxx
```

## 🚀 Deployment Commands

### Terraform Deployment

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply -auto-approve

# Check outputs
terraform output
```

### Ansible Configuration

```bash
# Run Ansible playbook
ansible-playbook ansible/riderhub.yml \
    -e dynamodb_posts_table=riderhub-posts \
    -e dynamodb_comments_table=riderhub-comments \
    -e s3_media_bucket=riderhub-media-xxxxxxxx \
    -e aws_region=us-east-1 \
    -e app_url=https://riderhub.amplifyapp.com \
    -e app_env=production \
    -e app_debug=false
```

### Docker Build and Push

```bash
# Build Docker image
docker build -t riderhub ./docker/riderhub

# Tag for ECR
docker tag riderhub:latest 753523452116.dkr.ecr.us-east-1.amazonaws.com/riderhub:latest

# Push to ECR
docker push 753523452116.dkr.ecr.us-east-1.amazonaws.com/riderhub:latest
```

## 🔧 Troubleshooting

### Common Issues

#### Resource Already Exists

```bash
# If resources already exist, you can either:
# 1. Import existing resources to Terraform state
terraform import aws_dynamodb_table.posts riderhub-posts

# 2. Or delete existing resources and recreate
aws dynamodb delete-table --table-name riderhub-posts --region us-east-1
```

#### Permission Denied

```bash
# Check IAM user permissions
aws iam list-attached-user-policies --user-name riderhub-ci-cd

# Check user policies
aws iam list-user-policies --user-name riderhub-ci-cd
```

#### Region Mismatch

```bash
# Ensure all commands use us-east-1 region
export AWS_DEFAULT_REGION=us-east-1

# Or add --region us-east-1 to all AWS CLI commands
```

## 📊 Cost Monitoring

### Check Free Tier Usage

1. Go to [AWS Billing Console](https://console.aws.amazon.com/billing/)
2. Click "Free Tier" in the left menu
3. Monitor usage for each service
4. Set up billing alerts if needed

### Expected Monthly Costs

- **Lambda**: $0 (within Free Tier limits)
- **DynamoDB**: $0 (within Free Tier limits)
- **S3**: $0 (within Free Tier limits)
- **API Gateway**: $0 (within Free Tier limits)
- **Amplify**: $0 (free hosting)
- **SNS**: $0 (within Free Tier limits)

## 📚 Additional Resources

- [AWS Free Tier Documentation](https://aws.amazon.com/free/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible AWS Modules](https://docs.ansible.com/ansible/latest/collections/amazon/aws/)
- [Docker ECR Integration](https://docs.aws.amazon.com/ecr/latest/userguide/docker-push-ecr-image.html)

## 🆘 Support

If you encounter issues specific to this AWS account:

1. Check the troubleshooting section above
2. Review AWS CloudTrail logs
3. Check GitHub Actions logs
4. Create an issue in the repository with account-specific details

---

**Note**: This guide is specifically for AWS Account `753523452116`. Do not use these ARNs or resource names with other AWS accounts.
