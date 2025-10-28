# aws-flarum-devops

AWS - Flarum forum with full DevOps automation - EC2, RDS MySQL, ALB, S3, Terraform, Docker, GitHub Actions. Community platform with complete CI/CD pipeline.

## Project Overview

aws-flarum-devops is a hands-on DevOps project that deploys RiderHub, a Flarum-based community forum tailored for motorcycle enthusiasts, on the AWS Free Tier. Designed to engage RiderWin.com's audience—motorcycle riders, gear reviewers, and tour planners—RiderHub enables discussions on gear, tour routes, safety tips, and community events. The project leverages Terraform for infrastructure as code (IaC), Ansible for configuration management, Docker for containerized deployments, and GitHub Actions for CI/CD pipelines, ensuring a zero-cost ($0), fully automated, EC2-based architecture integrated with RiderWin.com's Blogspot platform.

## Key Features

**Motorcycle Community Forum**: RiderHub, built on Flarum, allows users to create, read, update, and delete posts/comments, upload media (e.g., bike photos), and receive notifications for new content, fostering engagement for RiderWin.com's audience.

**AWS Architecture**: Utilizes AWS Free Tier services:

- **EC2**: Runs Flarum backend (PHP 8.1) for web application hosting (t3.micro instance within Free Tier limits).
- **RDS MySQL**: Stores forum data (discussions, posts, users, settings) with 20GB storage within Free Tier limits.
- **S3**: Hosts media uploads and file storage (~2GB within 5GB limit).
- **Application Load Balancer**: Distributes traffic and provides high availability for the forum.
- **VPC**: Secure networking with public/private subnets for EC2 and RDS.

**DevOps Automation**:

- **Terraform**: Provisions AWS infrastructure (RDS MySQL, S3, Lambda, API Gateway, ECR, VPC) using HCL for reproducible deployments.
- **Ansible**: Automates Flarum PHP configuration (Composer dependencies, MySQL adapter).
- **Docker**: Packages Flarum as a Lambda-compatible container using Bref PHP runtime for consistent local testing and production deployment.
- **GitHub Actions**: Automates CI/CD pipelines for building, testing, and deploying Flarum code to Lambda and ECR.

**API Integration**: Provides RESTful API endpoints for forum functionality that can be integrated with any frontend application or embedded in RiderWin.com Blogspot.

**Zero-Cost Deployment**: Operates entirely within AWS Free Tier, making it ideal for DevOps learning and portfolio projects without financial barriers.

## Project Goals

- **Engage RiderWin.com Audience**: Provide a forum for motorcycle enthusiasts to discuss gear, tours, and safety, enhancing blog interactivity.
- **Showcase DevOps Practices**: Demonstrate IaC (Terraform), configuration management (Ansible), containerization (Docker), and CI/CD (GitHub Actions) in a serverless context.
- **Educational Value**: Serve as a portfolio project for DevOps learners, showcasing end-to-end automation for a niche community application.
- **Zero-Cost Operation**: Ensure deployment and maintenance within AWS Free Tier limits for accessibility.

## Repository Structure

```
aws-flarum-devops/
├── terraform/
│   ├── flarum.tf # Flarum infrastructure (RDS MySQL, S3, Lambda, API Gateway, ECR, VPC)
│   └── main.tf # AWS provider config
├── ansible/
│   ├── riderhub.yml # Flarum PHP and MySQL adapter setup
│   └── roles/ # Reusable Ansible roles
├── docker/
│   └── flarum/Dockerfile # Flarum container (PHP/Bref)
├── src/
│   └── flarum/ # Flarum OSS application code
├── .github/workflows/
│   └── flarum.yml # CI/CD pipeline for Flarum
├── README.md # Project overview and setup instructions
└── LICENSE # MIT License
```

## Getting Started

1. **Clone Repository**: `git clone https://github.com/scale600/aws-flarum-devops-serverless`
2. **Set Up AWS Environment**: Follow the [AWS Setup Guide](.github/docs/AWS_SETUP_GUIDE.md) for complete environment configuration
3. **Configure GitHub Secrets**: Follow the [GitHub Secrets Setup Guide](.github/docs/GITHUB_SECRETS_SETUP.md) for CI/CD pipeline configuration
4. **Account-Specific Setup**: For AWS Account `753523452116`, see the [Account-Specific Setup Guide](.github/docs/AWS_ACCOUNT_SPECIFIC_SETUP.md)

### Terraform Deployment:

```bash
# Navigate to terraform/
cd terraform
# Initialize
terraform init
# Apply
terraform apply -auto-approve
```

### Ansible Configuration:

```bash
# Run playbook
ansible-playbook ansible/riderhub.yml
```

### Docker Build:

```bash
# Build Flarum image
docker build -t flarum ./docker/flarum
# Push to AWS ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/riderhub-flarum:latest
```

### GitHub Actions CI/CD:

1. Configure secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) in GitHub.
2. Push changes to trigger flarum.yml workflow for Lambda/ECR deployment.

### API Integration:

Use the API Gateway URL to integrate forum functionality with any frontend application or embed in RiderWin.com Blogspot.

### Test:

Verify forum functionality (discussions, posts, users, media uploads) and AWS Free Tier limits.

## Prerequisites

- AWS Free Tier account
- Terraform (v1.5.0+)
- Ansible (v2.10+)
- Docker (v20.10+)
- GitHub account with Actions enabled
- Node.js (for Amplify CLI) and PHP/Composer (for Flarum)

## License

MIT License
