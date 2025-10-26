# AWS Setup Guide

This document explains how to set up the AWS environment for the RiderHub project.

## 📋 Table of Contents

- [AWS Account Setup](#aws-account-setup)
- [AWS CLI Installation and Configuration](#aws-cli-setup)
- [Terraform Installation](#terraform-setup)
- [Local Development Environment Setup](#local-development-environment-setup)
- [AWS Free Tier Limits Verification](#aws-free-tier-limits-verification)

## 🏗️ AWS Account Setup

### 1. Create AWS Account
- Create an [AWS Free Tier](https://aws.amazon.com/free/) account
- Complete email verification and payment information (no charges for Free Tier usage)

### 2. Verify AWS Free Tier Limits
- EC2: 750 hours/month (t2.micro instances)
- Lambda: 1M requests/month, 400,000 GB-seconds
- DynamoDB: 25GB storage, 25 read/write capacity units
- S3: 5GB storage, 20,000 GET requests, 2,000 PUT requests
- API Gateway: 1M API calls/month
- SNS: 1M requests/month

## 💻 AWS CLI Installation and Configuration

### macOS
```bash
# Install using Homebrew
brew install awscli

# Or using pip
pip3 install awscli
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install awscli

# CentOS/RHEL
sudo yum install awscli
```

### Windows
```powershell
# Using Chocolatey
choco install awscli

# Or download from AWS website
# https://aws.amazon.com/cli/
```

### AWS CLI Configuration
```bash
# Configure AWS CLI
aws configure

# Enter the following information:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### Verify AWS CLI Setup
```bash
# Test AWS CLI connection
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/YourUsername"
# }
```

## 🏗️ Terraform Setup

### Installation

#### macOS
```bash
# Using Homebrew
brew install terraform

# Or download binary
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_darwin_amd64.zip
unzip terraform_1.5.0_darwin_amd64.zip
sudo mv terraform /usr/local/bin/
```

#### Linux
```bash
# Download and install
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

#### Windows
```powershell
# Using Chocolatey
choco install terraform

# Or download from HashiCorp website
# https://www.terraform.io/downloads
```

### Verify Terraform Installation
```bash
# Check Terraform version
terraform version

# Expected output:
# Terraform v1.5.0
# on linux_amd64
```

## 🐳 Docker Setup

### Installation

#### macOS
```bash
# Install Docker Desktop
brew install --cask docker

# Or download from Docker website
# https://www.docker.com/products/docker-desktop
```

#### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER
```

#### Windows
- Download Docker Desktop from [Docker website](https://www.docker.com/products/docker-desktop)

### Verify Docker Installation
```bash
# Check Docker version
docker --version

# Test Docker
docker run hello-world
```

## 🔧 Local Development Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/scale600/aws-flarum-devops-serverless.git
cd aws-flarum-devops-serverless
```

### 2. Install PHP and Composer
```bash
# macOS
brew install php composer

# Ubuntu/Debian
sudo apt install php8.1 php8.1-cli php8.1-mysql php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip composer

# Install Flarum dependencies
cd src/riderhub
composer install
```

### 3. Install Node.js (for Amplify)
```bash
# macOS
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### 4. Install Ansible
```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt install ansible

# Or using pip
pip3 install ansible
```

## 🔍 AWS Free Tier Limits Verification

### Check Current Usage
```bash
# Check Lambda usage
aws lambda get-account-settings

# Check DynamoDB usage
aws dynamodb list-tables

# Check S3 usage
aws s3 ls

# Check API Gateway usage
aws apigateway get-rest-apis
```

### Monitor Costs
1. Log into AWS Console
2. Navigate to Billing & Cost Management
3. Check Free Tier usage dashboard
4. Set up billing alerts if needed

## 🚀 Next Steps

1. **Configure GitHub Secrets**: Follow the [GitHub Secrets Setup Guide](GITHUB_SECRETS_SETUP.md)
2. **Account-Specific Setup**: For AWS Account `753523452116`, see the [Account-Specific Setup Guide](AWS_ACCOUNT_SPECIFIC_SETUP.md)
3. **Deploy Infrastructure**: Run `terraform apply` in the `terraform/` directory
4. **Configure Application**: Run `ansible-playbook ansible/riderhub.yml`

## 🔧 Troubleshooting

### Common Issues

#### AWS CLI Authentication Error
```bash
# Reconfigure AWS CLI
aws configure

# Check credentials
aws sts get-caller-identity
```

#### Terraform State Lock Error
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>

# Or remove state file and reinitialize
rm terraform/terraform.tfstate
terraform init
```

#### Docker Permission Error
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in
# Or run: newgrp docker
```

#### PHP/Composer Issues
```bash
# Update Composer
composer self-update

# Clear Composer cache
composer clear-cache

# Reinstall dependencies
rm -rf vendor/
composer install
```

## 📚 Additional Resources

- [AWS Free Tier Documentation](https://aws.amazon.com/free/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Flarum Documentation](https://docs.flarum.org/)

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review AWS CloudTrail logs for API errors
3. Check GitHub Actions logs for CI/CD issues
4. Create an issue in the repository

---

**Note**: This guide assumes you're using AWS Account `753523452116`. For other accounts, adjust the configuration accordingly.