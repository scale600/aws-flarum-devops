# GitHub Secrets Setup Guide

This document explains how to set up the secrets required for the RiderHub project's GitHub Actions CI/CD pipeline.

## 📋 Table of Contents

- [Required GitHub Secrets](#required-github-secrets)
- [GitHub Secrets Setup Method](#github-secrets-setup-method)
- [AWS Credentials Generation](#aws-credentials-generation)
- [AWS Amplify Setup](#aws-amplify-setup)
- [Additional Recommended Secrets](#additional-recommended-secrets)
- [Security Best Practices](#security-best-practices)
- [Post-Setup Verification](#post-setup-verification)

## 🔐 Required GitHub Secrets

The following secrets need to be configured for GitHub Actions:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AMPLIFY_APP_ID` | AWS Amplify App ID | `d1234567890` |

## 🛠️ GitHub Secrets Setup Method

### 1. Access GitHub Repository
- Navigate to: https://github.com/scale600/aws-flarum-devops-serverless

### 2. Click Settings Tab
- Click the "Settings" tab at the top of the repository.

### 3. Access Secrets Menu
- Click "Secrets and variables" → "Actions" in the left menu.

### 4. Add New Secret
- Click "New repository secret" button.
- Enter Name and Secret value, then click "Add secret".

## 🔑 AWS Credentials Generation

### Create IAM User

```bash
# 1. Create IAM user
aws iam create-user --user-name riderhub-ci-cd

# 2. Create IAM policy (create RiderHubCIPolicy.json file)
cat > RiderHubCIPolicy.json << 'EOF'
{
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
}
EOF

# 3. Attach policy to user
aws iam put-user-policy --user-name riderhub-ci-cd --policy-name RiderHubCIPolicy --policy-document file://RiderHubCIPolicy.json

# 4. Create access key
aws iam create-access-key --user-name riderhub-ci-cd
```

### Expected Output
```json
{
    "AccessKey": {
        "UserName": "riderhub-ci-cd",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "Status": "Active",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "CreateDate": "2023-01-01T00:00:00Z"
    }
}
```

### Save Credentials
- **Important**: Save the `AccessKeyId` and `SecretAccessKey` values immediately
- These values cannot be retrieved again after creation

## 🚀 AWS Amplify Setup

### 1. Create Amplify App

```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Configure Amplify
amplify configure

# Create new app
amplify init
```

### 2. Connect to GitHub Repository

1. Go to [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. Click "New app" → "Host web app"
3. Choose "GitHub" as source
4. Select the repository: `scale600/aws-flarum-devops-serverless`
5. Choose branch: `main`
6. Configure build settings (if needed)
7. Click "Save and deploy"

### 3. Get Amplify App ID

After creating the app, you'll see the App ID in the URL:
```
https://console.aws.amazon.com/amplify/home#/d1234567890
```

The App ID is: `d1234567890`

## 🔧 Additional Recommended Secrets

| Secret Name | Description | When to Use |
|-------------|-------------|-------------|
| `AWS_REGION` | AWS Region | If different from us-east-1 |
| `ECR_REPOSITORY` | ECR Repository Name | If different from riderhub |
| `S3_BUCKET` | S3 Bucket Name | For custom bucket names |
| `DYNAMODB_TABLE_PREFIX` | DynamoDB Table Prefix | For custom table naming |

## 🔒 Security Best Practices

### 1. Principle of Least Privilege
- Only grant necessary permissions
- Use specific resource ARNs instead of wildcards when possible
- Regularly review and rotate access keys

### 2. Key Rotation
```bash
# Create new access key
aws iam create-access-key --user-name riderhub-ci-cd

# Update GitHub secrets with new keys
# Delete old access key
aws iam delete-access-key --user-name riderhub-ci-cd --access-key-id OLD_ACCESS_KEY_ID
```

### 3. Monitor Usage
- Enable CloudTrail for API monitoring
- Set up billing alerts
- Review IAM access logs regularly

### 4. Environment Separation
- Use different IAM users for different environments
- Consider using AWS Organizations for multi-account setups

## ✅ Post-Setup Verification

### 1. Test AWS Credentials
```bash
# Test with AWS CLI
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "753523452116",
#     "Arn": "arn:aws:iam::753523452116:user/riderhub-ci-cd"
# }
```

### 2. Test GitHub Actions
1. Make a small change to the repository
2. Push to main branch
3. Check GitHub Actions tab for workflow execution
4. Verify all steps complete successfully

### 3. Verify Amplify Connection
1. Go to Amplify Console
2. Check if the app is connected to the repository
3. Verify build settings are correct

## 🔍 Troubleshooting

### Common Issues

#### AWS Credentials Not Working
```bash
# Check if credentials are correct
aws sts get-caller-identity

# If error occurs, verify:
# 1. Access key ID is correct
# 2. Secret access key is correct
# 3. User has necessary permissions
```

#### Amplify App Not Found
- Verify the App ID is correct
- Check if the app exists in the correct AWS region
- Ensure the app is connected to the repository

#### GitHub Actions Failing
- Check the Actions tab for error messages
- Verify all required secrets are set
- Check AWS CloudTrail for API errors

### Debug Commands

```bash
# Check IAM user policies
aws iam list-attached-user-policies --user-name riderhub-ci-cd

# Check user permissions
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::753523452116:user/riderhub-ci-cd --action-names ecr:CreateRepository --resource-arns "*"

# List Amplify apps
aws amplify list-apps
```

## 📚 Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Amplify Documentation](https://docs.amplify.aws/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review AWS CloudTrail logs
3. Check GitHub Actions logs
4. Create an issue in the repository

---

**Note**: This guide is specifically for AWS Account `753523452116`. Adjust the account ID for other AWS accounts.