# 🚀 RiderHub Deployment Guide

**Get Your Site Live in 15 Minutes!**

This guide will walk you through deploying RiderHub to AWS and accessing it on the web.

---

## ✅ Pre-Deployment Checklist

Before deploying, ensure you have:

- [ ] AWS Account with Free Tier access
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (v1.5.0+)
- [ ] Valid AWS credentials configured

---

## 📋 Step-by-Step Deployment

### Step 1: Verify AWS Credentials

```bash
# Check AWS credentials
aws sts get-caller-identity

# Expected output should show your account details
```

### Step 2: Validate Environment

```bash
# Run validation script
./scripts/validate-setup.sh
```

### Step 3: Initialize Terraform

```bash
cd terraform

# Initialize Terraform (downloads providers)
terraform init
```

### Step 4: Review Deployment Plan

```bash
# See what will be created
terraform plan

# Review the resources that will be created:
# - VPC Subnets (4)
# - EC2 Instance (1)
# - RDS MySQL Database (1)
# - S3 Bucket (1)
# - Application Load Balancer (1)
# - Security Groups (2)
# - IAM Roles (1)
```

### Step 5: Deploy Infrastructure

```bash
# Deploy all infrastructure
terraform apply

# Type 'yes' when prompted
```

**⏱️ This will take approximately 8-12 minutes**

### Step 6: Get Your Site URL

```bash
# Get the ALB URL
terraform output flarum_url

# Example output:
# http://riderhub-flarum-alb-123456789.us-east-1.elb.amazonaws.com
```

### Step 7: Wait for EC2 Initialization

The EC2 instance needs time to:
- Install PHP 8.1 and Apache
- Install Flarum
- Configure the database
- Start the web server

**⏱️ Wait 5-7 minutes after terraform apply completes**

### Step 8: Access Your Site

```bash
# Get your URL
export FLARUM_URL=$(terraform output -raw flarum_url)

# Open in browser
open $FLARUM_URL
# Or manually visit the URL shown by terraform output
```

---

## 🔍 Verification Steps

### Check EC2 Instance Status

```bash
# Get instance ID
terraform output ec2_instance_id

# Check instance status
aws ec2 describe-instance-status --instance-ids $(terraform output -raw ec2_instance_id)
```

### Check ALB Health

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw alb_target_group_arn)
```

### SSH into EC2 Instance

```bash
# Get SSH command
terraform output ssh_command

# Or manually:
ssh -i terraform/riderhub-flarum-key.pem ec2-user@$(terraform output -raw ec2_instance_public_ip)

# Check Apache status
sudo systemctl status httpd

# Check Flarum installation
ls -la /var/www/flarum

# View installation logs
tail -f /var/log/flarum-install.log
```

---

## 🌐 What You Should See

### 1. Initial Load (First Visit)
- Flarum installation page
- Database configuration form

### 2. After Setup
- Beautiful Flarum forum homepage
- User registration option
- Admin panel access

---

## 🛠️ Troubleshooting

### Problem: Site Not Loading

**Solution 1: Check EC2 User Data Status**
```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@$(terraform output -raw ec2_instance_public_ip)
tail -f /var/log/cloud-init-output.log
```

**Solution 2: Check Apache Status**
```bash
sudo systemctl status httpd
sudo tail -f /var/log/httpd/error_log
```

**Solution 3: Restart Apache**
```bash
sudo systemctl restart httpd
```

### Problem: 502 Bad Gateway

**Cause**: EC2 instance not healthy in target group

**Solution**:
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names riderhub-flarum-tg --query 'TargetGroups[0].TargetGroupArn' --output text)

# If unhealthy, check Apache
ssh -i terraform/riderhub-flarum-key.pem ec2-user@INSTANCE_IP
sudo systemctl status httpd
```

### Problem: Database Connection Error

**Solution**:
```bash
# Check RDS status
aws rds describe-db-instances --db-instance-identifier riderhub-flarum-db

# Check security groups allow connection
# RDS should be in private subnet with security group allowing 3306 from VPC
```

### Problem: 503 Service Unavailable

**Cause**: Flarum not installed yet

**Solution**: Wait 5-7 more minutes for user-data script to complete

---

## 📊 Monitor Deployment

### CloudWatch Logs

```bash
# View EC2 logs in CloudWatch
aws logs tail /aws/ec2/riderhub-flarum --follow

# View RDS logs
aws rds describe-db-log-files \
  --db-instance-identifier riderhub-flarum-db
```

### Resource Status

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.flarum
```

---

## 🎨 Customize Your Site

### 1. Access Admin Panel

1. Visit: `http://YOUR-ALB-URL/admin`
2. Create admin account
3. Configure forum settings

### 2. Customize Appearance

1. Go to Administration → Appearance
2. Change colors, logo, and branding
3. Upload custom favicon

### 3. Install Extensions

```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@INSTANCE_IP
cd /var/www/flarum
composer require flarum/tags
php flarum migrate
php flarum cache:clear
```

---

## 💰 Cost Monitoring

### Check Free Tier Usage

```bash
# EC2 usage
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter file://filter.json
```

### Set Billing Alert

1. Go to AWS Billing Dashboard
2. Set up billing alert for $5
3. Monitor usage weekly

---

## 🔄 Update and Maintenance

### Update Flarum

```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@INSTANCE_IP
cd /var/www/flarum
composer update
php flarum migrate
php flarum cache:clear
```

### Backup Database

```bash
# Create RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier riderhub-flarum-db \
  --db-snapshot-identifier riderhub-backup-$(date +%Y%m%d)
```

### Update Infrastructure

```bash
cd terraform
terraform plan
terraform apply
```

---

## 🧹 Cleanup (When Done Testing)

### Destroy All Resources

```bash
cd terraform
terraform destroy

# Type 'yes' when prompted
```

**⚠️ Warning**: This will delete:
- EC2 instance
- RDS database (and all data)
- S3 bucket
- Load balancer
- All other resources

---

## 🎯 Quick Commands Reference

```bash
# Deploy
cd terraform && terraform apply

# Get URL
terraform output flarum_url

# SSH to server
ssh -i terraform/riderhub-flarum-key.pem ec2-user@$(terraform output -raw ec2_instance_public_ip)

# View logs
ssh ... "sudo tail -f /var/log/httpd/access_log"

# Restart Apache
ssh ... "sudo systemctl restart httpd"

# Destroy
terraform destroy
```

---

## 📱 Access Points

After deployment, you'll have:

1. **Forum Homepage**: `http://YOUR-ALB-URL/`
2. **Admin Panel**: `http://YOUR-ALB-URL/admin`
3. **API Status**: `http://YOUR-ALB-URL/health.php`
4. **SSH Access**: Via the generated key pair

---

## 🎉 Success!

If you can see the Flarum installation page or forum, **congratulations!** 

Your RiderHub forum is now live on the web! 🏍️

---

## 📚 Next Steps

1. **Complete Flarum Setup**: Configure admin account
2. **Customize Appearance**: Add your branding
3. **Create Content**: Add initial discussions
4. **Add Domain** (Optional): Point custom domain to ALB
5. **Enable HTTPS** (Optional): Add SSL certificate
6. **Configure Backups**: Set up automated backups

---

## 🆘 Need Help?

- Check `/var/log/flarum-install.log` on EC2
- Check `/var/log/httpd/error_log` for Apache errors
- Run `terraform output` to see all connection details
- Check CloudWatch logs for detailed diagnostics

**Happy Riding! 🏍️**

