# 🏍️ AWS Flarum Forum - DevOps Automation Project

> **Full-stack forum deployment with Terraform, Docker, GitHub Actions, and AWS**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange.svg)](https://aws.amazon.com/)

Production-ready forum application demonstrating Infrastructure as Code, CI/CD automation, and cloud deployment best practices.

---

## 🎯 Overview

DevOps hands-on project showcasing automated infrastructure provisioning and deployment.

### Tech Stack

| Category              | Technologies                               |
| --------------------- | ------------------------------------------ |
| **Infrastructure**    | Terraform, AWS (EC2, VPC, Security Groups) |
| **CI/CD**             | GitHub Actions                             |
| **Containers**        | Docker                                     |
| **Config Management** | Ansible                                    |
| **Application**       | PHP 8.1, Flarum, MySQL, Apache             |

### Key Features

- ✅ **100% Automated** - Zero manual deployment steps
- ✅ **Fast Deployment** - 5-7 minutes from code to production
- ✅ **Cost Efficient** - $0-10/month (Free Tier eligible)
- ✅ **Production Ready** - Encrypted storage, security groups, monitoring
- ✅ **Clean Code** - Modular, documented, maintainable

---

## 🚀 Quick Deploy

### Prerequisites

- AWS Account ([Free Tier](https://aws.amazon.com/free/))
- GitHub Account

### Deploy Steps

**1. Fork this repository**

**2. Add GitHub Secrets:**

Go to `Settings` → `Secrets and variables` → `Actions`:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**3. Deploy:**

```bash
git clone https://github.com/YOUR_USERNAME/aws-flarum-devops.git
cd aws-flarum-devops
git commit --allow-empty -m "Deploy"
git push origin main
```

**4. Get URL:**

- Open [AWS EC2 Console](https://console.aws.amazon.com/ec2)
- Find instance: `riderhub-flarum`
- Visit: `http://YOUR_EC2_IP`

**Done! 🎉**

---

## 🏗️ Architecture

```
Internet → EC2 (Apache + PHP + Flarum + MySQL) → Users
```

Simple all-in-one architecture optimized for cost and simplicity.

---

## 📁 Project Structure

```
aws-flarum-devops/
├── .github/workflows/     # CI/CD pipeline
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # AWS provider config
│   ├── variables.tf      # Input variables
│   ├── flarum-core.tf    # EC2, VPC, networking
│   └── user-data-*.sh    # Server initialization
├── src/flarum/           # PHP application
├── frontend/             # React TypeScript app
├── docker/               # Container config
├── ansible/              # Configuration management
└── scripts/              # Automation scripts
```

---

## 🔄 CI/CD Pipeline

Automated workflow on every push to `main`:

1. **Test** → Run PHPUnit tests
2. **Provision** → Terraform applies infrastructure
3. **Configure** → Install software stack
4. **Deploy** → Install Flarum
5. **Live** → Site accessible at EC2 IP

**Total time:** 5-7 minutes

---

## 💰 Cost

| Tier                            | Monthly Cost |
| ------------------------------- | ------------ |
| **Free Tier** (first 12 months) | $0           |
| **After Free Tier**             | ~$10         |

Breakdown: EC2 t3.micro ($8) + EBS 30GB ($2) + Data transfer ($0.50)

---

## 🛠️ Local Development

### Terraform Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Docker Build

```bash
cd docker/flarum
docker build -t flarum .
docker run -p 8080:8080 flarum
```

### Run Tests

```bash
cd src/flarum
composer install
vendor/bin/phpunit
```

---

## 🔒 Security

- ✅ Encrypted EBS volumes (AES-256)
- ✅ Security group firewall rules
- ✅ SSH key-based authentication
- ✅ GitHub Secrets for credentials
- ✅ HTTPS-ready (Certbot supported)

---

## 📊 Project Stats

| Metric                   | Value                               |
| ------------------------ | ----------------------------------- |
| **Infrastructure Files** | 15+ Terraform/Ansible files         |
| **Deployment Time**      | 5-7 minutes (automated)             |
| **Lines of Code**        | 5,000+ (HCL, PHP, TypeScript, Bash) |
| **AWS Resources**        | EC2, VPC, Security Groups, IAM, EBS |
| **Cost**                 | $0-10/month                         |
| **Automation**           | 100%                                |

---

## 🎓 Skills Demonstrated

### DevOps

- Infrastructure as Code (Terraform)
- CI/CD Pipelines (GitHub Actions)
- Configuration Management (Ansible)
- Cloud Architecture (AWS)

### Engineering

- Containerization (Docker)
- Automated Testing (PHPUnit)
- Shell Scripting (Bash)
- Version Control (Git)

---

## 🐛 Troubleshooting

| Issue                | Solution                                  |
| -------------------- | ----------------------------------------- |
| Site shows 503       | Wait 5 minutes - installation in progress |
| GitHub Actions fails | Check AWS credentials in Secrets          |
| Can't SSH to EC2     | Verify security group allows port 22      |
| Site not loading     | Check EC2 instance is running in Console  |

---

## 📈 Scaling

**Vertical:** Change instance type in `terraform/variables.tf`

```hcl
variable "instance_type" {
  default = "t3.small"  # Upgrade from t3.micro
}
```

**Horizontal:** Add ALB, Auto Scaling, RDS, EFS for multi-instance setup

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/NewFeature`)
3. Commit changes (`git commit -m 'Add NewFeature'`)
4. Push to branch (`git push origin feature/NewFeature`)
5. Open Pull Request

---

## 📝 License

MIT License - see [LICENSE](LICENSE)

---

## 🙏 Acknowledgments

- **Flarum** - Modern forum software
- **Terraform** - Infrastructure as Code
- **AWS** - Cloud infrastructure
- **GitHub Actions** - CI/CD automation

---

## 💼 Why This Project?

Demonstrates real-world DevOps skills:

- ✅ Production-ready infrastructure, not tutorials
- ✅ Multiple technologies (Terraform, Docker, AWS, Ansible)
- ✅ Best practices (security, automation, cost optimization)
- ✅ Complete documentation and clean code

Perfect for portfolios, job applications, and interviews.

---

**Built with ❤️ for the DevOps Community**

**🏍️ Happy Deploying!**
