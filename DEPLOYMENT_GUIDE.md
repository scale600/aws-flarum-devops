# RiderHub Flarum Deployment Guide

## 🚀 Quick Start Deployment

This guide will help you deploy the RiderHub Flarum forum to AWS using the complete serverless architecture.

## Prerequisites

- AWS Free Tier account with programmatic access
- AWS CLI configured with credentials
- Terraform (v1.5.0+)
- Docker (v20.10+)
- Git

## Step 1: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Step 2: Deploy Infrastructure

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply

# Note the outputs (save these for later)
terraform output
```

**Expected Outputs:**

- `api_gateway_url`: Your Flarum API endpoint
- `rds_endpoint`: MySQL database endpoint
- `s3_bucket_name`: S3 bucket for file storage
- `ecr_repository_url`: ECR repository for Docker images

## Step 3: Build and Push Docker Image

```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build the Docker image
docker build -t riderhub-flarum -f docker/flarum/Dockerfile .

# Tag for ECR
docker tag riderhub-flarum:latest <ecr-repository-url>:latest

# Push to ECR
docker push <ecr-repository-url>:latest
```

## Step 4: Update Lambda Function

```bash
# Update Lambda function with new image
aws lambda update-function-code \
  --function-name riderhub-flarum \
  --image-uri <ecr-repository-url>:latest \
  --region us-east-1
```

## Step 5: Test the Deployment

```bash
# Get the API Gateway URL
API_URL=$(terraform output -raw api_gateway_url)

# Test the API
curl $API_URL/
curl $API_URL/api/discussions
curl $API_URL/api/posts
curl $API_URL/api/users
```

## Step 6: Configure GitHub Actions (Optional)

1. Go to your GitHub repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │────│  Lambda (PHP)   │────│   RDS MySQL     │
│   (REST API)    │    │   (Flarum)      │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                │
                       ┌─────────────────┐
                       │   S3 Bucket     │
                       │  (File Storage) │
                       └─────────────────┘
```

## 📊 AWS Free Tier Usage

| Service     | Usage             | Free Tier Limit   |
| ----------- | ----------------- | ----------------- |
| Lambda      | ~10K requests/day | 1M requests/month |
| RDS MySQL   | 20GB storage      | 20GB              |
| S3          | ~2GB storage      | 5GB               |
| API Gateway | ~10K calls/day    | 1M calls/month    |
| ECR         | 500MB storage     | 500MB             |

## 🔧 Troubleshooting

### Common Issues

1. **Lambda Cold Start**: First request may take 10-30 seconds
2. **RDS Connection**: Ensure Lambda is in the same VPC as RDS
3. **S3 Permissions**: Check IAM policies for S3 access
4. **API Gateway CORS**: Configure CORS if needed for frontend

### Useful Commands

```bash
# Check Lambda function status
aws lambda get-function --function-name riderhub-flarum

# View Lambda logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/riderhub-flarum

# Test RDS connection
aws rds describe-db-instances --db-instance-identifier riderhub-flarum-db

# Check S3 bucket
aws s3 ls s3://<bucket-name>
```

## 🧹 Cleanup

To remove all resources and avoid charges:

```bash
# Run cleanup script
./scripts/cleanup-aws-resources.sh

# Or use Terraform
cd terraform
terraform destroy
```

## 📈 Monitoring

- **CloudWatch Logs**: Monitor Lambda execution logs
- **CloudWatch Metrics**: Track API Gateway and Lambda metrics
- **RDS Monitoring**: Monitor database performance
- **S3 Metrics**: Track storage usage

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automatically:

1. Runs tests on PHP code
2. Builds Docker image
3. Pushes to ECR
4. Updates Lambda function
5. Tests API endpoints

## 📝 Next Steps

1. **Custom Domain**: Set up custom domain for API Gateway
2. **Frontend**: Build React/Amplify frontend
3. **Monitoring**: Set up CloudWatch alarms
4. **Backup**: Configure RDS automated backups
5. **Security**: Implement authentication and authorization

## 🆘 Support

For issues or questions:

- Check CloudWatch logs
- Review Terraform state
- Verify AWS service limits
- Consult AWS documentation

---

**Happy Deploying! 🏍️**
