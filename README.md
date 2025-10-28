# 🏍️ RiderHub - AWS Flarum Forum with Full DevOps Automation

> **Production-ready forum deployment with complete CI/CD automation using AWS EC2, Terraform, Docker, and GitHub Actions**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange.svg)](https://aws.amazon.com/)

A motorcycle community forum built with Flarum, showcasing modern DevOps practices with Infrastructure as Code, automated CI/CD pipelines, and cloud-native architecture.

---

## 🎯 What is This?

This project demonstrates **enterprise-level DevOps automation** by deploying a complete forum application with:

- ✅ **Infrastructure as Code** (Terraform)
- ✅ **CI/CD Pipeline** (GitHub Actions)
- ✅ **Cloud Architecture** (AWS EC2)
- ✅ **Containerization** (Docker-ready)
- ✅ **Configuration Management** (Ansible)
- ✅ **Automated Testing** (PHPUnit)

**Perfect for:** Learning DevOps, Portfolio projects, Production forums, Team collaboration platforms

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│    Internet Users                   │
└─────────────┬───────────────────────┘
              │ HTTP/HTTPS
              ▼
┌─────────────────────────────────────┐
│  AWS EC2 Instance (All-in-One)      │
│  ┌───────────────────────────────┐  │
│  │ Apache Web Server             │  │
│  │ PHP 8.1 + Flarum Forum        │  │
│  │ MySQL Database (local)        │  │
│  │ File Storage (local)          │  │
│  └───────────────────────────────┘  │
│  Cost: $8/month (Free Tier eligible)│
└─────────────────────────────────────┘
```

**Simple, cost-effective, and fully automated!**

---

## 🚀 Quick Deploy (10 Minutes)

### Prerequisites
- AWS Account ([Sign up free](https://aws.amazon.com/free/))
- GitHub Account

### Steps

**1. Fork this repository**

**2. Add AWS credentials to GitHub Secrets:**
- Go to: `Settings` → `Secrets and variables` → `Actions`
- Add `AWS_ACCESS_KEY_ID`
- Add `AWS_SECRET_ACCESS_KEY`

**3. Push to main branch:**
```bash
git clone https://github.com/YOUR_USERNAME/aws-flarum-devops.git
cd aws-flarum-devops
git commit --allow-empty -m "Deploy to AWS"
git push origin main
```

**4. Get your site URL:**
- Go to [AWS EC2 Console](https://console.aws.amazon.com/ec2)
- Find instance: `riderhub-flarum`
- Copy **Public IP**
- Visit: `http://YOUR_EC2_IP`

**Done! Your forum is live! 🎉**

---

## 📦 Technology Stack

### DevOps & Infrastructure
- **Cloud:** AWS EC2, VPC, Security Groups
- **IaC:** Terraform (Infrastructure as Code)
- **CI/CD:** GitHub Actions (automated deployment)
- **Config:** Ansible (server configuration)
- **Containers:** Docker (optional deployment)

### Application
- **Framework:** Flarum (modern PHP forum)
- **Language:** PHP 8.1
- **Web Server:** Apache HTTP Server
- **Database:** MySQL 8.0 (MariaDB)
- **Storage:** Local filesystem (30GB encrypted EBS)

---

## 📁 Project Structure

```
aws-flarum-devops/
├── .github/workflows/     # CI/CD pipeline
│   └── flarum.yml        # GitHub Actions workflow
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # AWS provider config
│   ├── flarum-core.tf    # EC2 instance definition
│   ├── variables.tf      # Configuration variables
│   └── outputs.tf        # Deployment outputs
├── src/flarum/           # PHP application code
├── docker/               # Docker configuration
├── ansible/              # Configuration management
└── scripts/              # Utility scripts
```

---

## ⚙️ What Gets Deployed?

### AWS Resources
- **EC2 Instance:** t3.micro (1 vCPU, 1GB RAM)
- **EBS Volume:** 30GB encrypted storage
- **VPC:** Isolated network with public subnet
- **Security Group:** HTTP, HTTPS, SSH access
- **SSH Key:** Automatic generation for access

### Software Stack
- **Apache 2.4** - Web server
- **PHP 8.1** - Application runtime
- **MySQL 8.0** - Database (local)
- **Flarum** - Forum software
- **Composer** - PHP dependency manager

---

## 🔄 CI/CD Pipeline

**Automated workflow on every push to main:**

```
1. Run Tests          → PHPUnit tests
2. Terraform Init     → Initialize providers
3. Terraform Plan     → Preview changes
4. Terraform Apply    → Deploy infrastructure
5. Configure Server   → Install software
6. Deploy Application → Install Flarum
7. Output URL         → Site is live!
```

**Total time:** 5-7 minutes from push to live site

---

## 💰 Cost

### AWS Free Tier (First 12 months)
- **$0/month** - Everything included in Free Tier

### After Free Tier
- **EC2 t3.micro:** $8/month
- **EBS 30GB:** $2/month
- **Data transfer:** ~$0.50/month
- **Total:** ~$10/month

**Savings vs RDS + S3 architecture:** $144/year!

---

## 🛠️ Local Development

### Deploy with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Run with Docker
```bash
cd docker/flarum
docker build -t flarum .
docker run -p 8080:8080 flarum
```

### Test Application
```bash
cd src/flarum
composer install
vendor/bin/phpunit
```

---

## 🔒 Security Features

- ✅ Encrypted EBS volumes (AES-256)
- ✅ Security group firewall rules
- ✅ SSH key-based authentication
- ✅ Secrets management via GitHub Secrets
- ✅ HTTPS-ready (SSL certificate supported)
- ✅ Automated security updates

---

## 📊 DevOps Best Practices

### Infrastructure as Code
- All infrastructure defined in Terraform
- Version controlled
- Reproducible deployments
- Easy rollbacks

### CI/CD Automation
- Automated testing on every commit
- Infrastructure validation
- Automated deployment
- Deployment verification

### Configuration Management
- Idempotent Ansible playbooks
- Automated server configuration
- Consistent environments

---

## 🎓 What You'll Learn

- ✅ Infrastructure as Code with Terraform
- ✅ CI/CD pipeline design with GitHub Actions
- ✅ AWS cloud architecture and services
- ✅ Container orchestration basics
- ✅ Configuration management with Ansible
- ✅ Security best practices in the cloud
- ✅ Cost optimization strategies
- ✅ Production deployment workflows

---

## 🔧 Customization

### Change Instance Size
```hcl
# terraform/variables.tf
variable "instance_type" {
  default = "t3.small"  # Upgrade from t3.micro
}
```

### Modify Forum Settings
```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@YOUR_EC2_IP
cd /var/www/flarum
sudo vim config.php
```

### Add Custom Domain
1. Point domain A record to EC2 IP
2. Update Apache virtual host
3. Install SSL certificate with Certbot

---

## 🐛 Troubleshooting

### Site shows 503 error
**Cause:** Installation still in progress  
**Solution:** Wait 5 more minutes, EC2 is installing software

### GitHub Actions fails
**Cause:** AWS credentials incorrect  
**Solution:** Verify GitHub Secrets are set correctly

### Can't access EC2 via SSH
**Cause:** Security group blocking  
**Solution:** Check security group allows port 22 from your IP

### Site not loading at all
**Cause:** EC2 instance not running  
**Solution:** Check EC2 status in AWS Console

---

## 📈 Scaling Options

### Vertical Scaling
Increase instance size in `terraform/variables.tf`:
- `t3.micro` → `t3.small` (2GB RAM)
- `t3.small` → `t3.medium` (4GB RAM)

### Horizontal Scaling
Add load balancer and multiple instances:
- Application Load Balancer
- Auto Scaling Group
- RDS for shared database
- EFS for shared storage

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- **Flarum** - Modern forum software
- **Terraform** - Infrastructure as Code
- **AWS** - Cloud infrastructure
- **GitHub Actions** - CI/CD platform

---

## 📞 Support

- 🐛 **Issues:** [GitHub Issues](https://github.com/scale600/aws-flarum-devops/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/scale600/aws-flarum-devops/discussions)
- 📖 **Documentation:** See repository files

---

## ⭐ Show Your Support

If this project helped you learn DevOps or deploy your forum, please give it a ⭐️!

---

## 📊 Project Stats

- **Infrastructure Files:** 15+
- **Deployment Time:** 5-7 minutes
- **Lines of Code:** 5,000+
- **Cost:** $0-10/month
- **Automation:** 100%

---

**Built with ❤️ for the DevOps Community**

**🏍️ Happy Deploying!**
