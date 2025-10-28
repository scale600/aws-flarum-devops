# AWS Flarum Forum - DevOps Automation

> Forum deployment with Terraform, GitHub Actions, and AWS EC2

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange.svg)](https://aws.amazon.com/)

Automated forum deployment demonstrating Infrastructure as Code and CI/CD best practices.

---

## Tech Stack

- **Infrastructure:** Terraform, AWS EC2
- **CI/CD:** GitHub Actions
- **Application:** PHP 8.1, Flarum, MySQL, Apache

---

## Quick Deploy

1. **Fork this repository**

2. **Add GitHub Secrets** (`Settings` → `Secrets` → `Actions`):

   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

3. **Deploy:**

```bash
git clone https://github.com/YOUR_USERNAME/aws-flarum-devops.git
cd aws-flarum-devops
git commit --allow-empty -m "Deploy"
git push origin main
```

4. **Access:** Find EC2 public IP in [AWS Console](https://console.aws.amazon.com/ec2) → Visit `http://YOUR_IP`

---

## Project Structure

```
aws-flarum-devops/
├── .github/workflows/  # CI/CD automation
├── terraform/          # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── flarum-core.tf
│   └── user-data-*.sh
├── src/flarum/        # PHP application
└── scripts/           # Deployment scripts
```

---

## CI/CD Pipeline

On push to `main`:

1. Run tests (PHPUnit)
2. Provision infrastructure (Terraform)
3. Configure server (Apache, PHP, MySQL)
4. Deploy Flarum
5. Output URL

**Time:** 5-7 minutes

---

## Cost

| Tier                  | Monthly |
| --------------------- | ------- |
| Free Tier (12 months) | $0      |
| After                 | ~$10    |

---

## Local Development

```bash
# Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Tests
cd src/flarum
composer install
vendor/bin/phpunit
```

---

## Troubleshooting

| Issue        | Solution                     |
| ------------ | ---------------------------- |
| 503 error    | Wait 5 min - installing      |
| Actions fail | Check AWS credentials        |
| Can't SSH    | Check security group port 22 |

---

## Skills Demonstrated

- Infrastructure as Code (Terraform)
- CI/CD Pipeline (GitHub Actions)
- Cloud Architecture (AWS)
- Automated Testing (PHPUnit)
- Shell Scripting (Bash)

---

## License

MIT - see [LICENSE](LICENSE)

---

**Built for DevOps learning and portfolio projects**
