# ⚡ Quick Start - Deploy RiderHub in 3 Commands

Get your motorcycle forum live in **15 minutes**!

---

## 🎯 Three Commands to Deploy

```bash
# 1. Run automated deployment
./scripts/deploy.sh

# That's it! The script handles everything:
# ✅ Validates your AWS setup
# ✅ Initializes Terraform
# ✅ Creates deployment plan
# ✅ Deploys all infrastructure
# ✅ Gives you the URL
```

---

## 📋 Prerequisites (One-Time Setup)

### 1. Install Required Tools

**macOS:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install terraform awscli
```

**Linux (Ubuntu/Debian):**
```bash
# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
```powershell
# Using Chocolatey
choco install terraform awscli
```

### 2. Configure AWS Credentials

```bash
aws configure

# Enter your credentials:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: us-east-1
# Default output format: json
```

**Getting AWS Credentials:**
1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to IAM → Users → Your User → Security Credentials
3. Click "Create Access Key"
4. Download and save the credentials

---

## 🚀 Deploy Now!

### Option 1: Automated Deployment (Recommended)

```bash
# Clone the repository
git clone https://github.com/scale600/aws-flarum-devops.git
cd aws-flarum-devops

# Run deployment script
./scripts/deploy.sh

# Follow the prompts and wait ~10 minutes
```

### Option 2: Manual Deployment

```bash
# Navigate to terraform directory
cd terraform

# Initialize
terraform init

# Deploy
terraform apply

# Get your URL
terraform output flarum_url
```

---

## ⏱️ Deployment Timeline

| Time | What's Happening |
|------|------------------|
| 0:00 | Start deployment |
| 0:30 | Creating VPC and subnets |
| 1:00 | Creating security groups |
| 2:00 | Launching RDS database |
| 3:00 | Launching EC2 instance |
| 5:00 | Creating load balancer |
| 7:00 | Terraform complete ✅ |
| 8:00 | EC2 installing Flarum |
| 12:00 | Flarum installation complete ✅ |
| 12:30 | **SITE LIVE!** 🎉 |

---

## 🌐 Access Your Site

After deployment completes:

1. **Get your URL:**
   ```bash
   cd terraform
   terraform output flarum_url
   ```

2. **Wait 5-7 minutes** for EC2 to install Flarum

3. **Visit the URL** in your browser

4. **Complete Flarum setup:**
   - Enter forum details
   - Create admin account
   - Configure settings

5. **Start using your forum!** 🏍️

---

## 🔍 Check Status

### View Installation Progress

```bash
# SSH into your server
ssh -i terraform/riderhub-flarum-key.pem ec2-user@$(terraform output -raw ec2_instance_public_ip)

# Watch installation logs
tail -f /var/log/flarum-install.log

# Check Apache status
sudo systemctl status httpd
```

### Test Site Availability

```bash
# Get your URL
export FLARUM_URL=$(cd terraform && terraform output -raw flarum_url)

# Test the endpoint
curl -I $FLARUM_URL

# Expected: HTTP 200 or 302
```

---

## ⚠️ Troubleshooting

### Site Not Loading?

**Wait longer** - EC2 needs 5-7 minutes after Terraform completes

**Check Apache:**
```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@INSTANCE_IP
sudo systemctl status httpd
sudo systemctl restart httpd
```

**Check logs:**
```bash
tail -f /var/log/flarum-install.log
tail -f /var/log/httpd/error_log
```

### 502 Bad Gateway?

**EC2 instance not healthy yet**
- Wait 5 more minutes
- Check target group health:
  ```bash
  aws elbv2 describe-target-health --target-group-arn YOUR_TG_ARN
  ```

### AWS Errors?

**Credentials issue:**
```bash
aws sts get-caller-identity
# If this fails, run: aws configure
```

**Region issue:**
```bash
# Ensure region is set
aws configure set region us-east-1
```

---

## 💰 Cost

**Free Tier (First 12 Months):**
- EC2: 750 hours/month - ✅ FREE
- RDS: 750 hours/month - ✅ FREE
- ALB: 750 hours/month - ✅ FREE
- S3: 5GB storage - ✅ FREE

**Total Cost:** $0/month within Free Tier limits

**After Free Tier:**
- Estimated: ~$15-20/month
- Optimize by stopping EC2 when not in use

---

## 🧹 Cleanup

When you're done testing:

```bash
cd terraform
terraform destroy

# Type 'yes' to confirm
```

**This removes everything and stops all charges.**

---

## 📚 Documentation

- **Full Guide:** See [DEPLOY.md](DEPLOY.md)
- **Deployment Guide:** See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Troubleshooting:** See [COMPLETION_GUIDE.md](COMPLETION_GUIDE.md)

---

## ✅ Deployment Checklist

Before deploying:
- [ ] AWS account created
- [ ] AWS CLI installed
- [ ] Terraform installed
- [ ] AWS credentials configured
- [ ] Repository cloned

After deployment:
- [ ] URL received from terraform output
- [ ] Waited 5-7 minutes for EC2 setup
- [ ] Site accessible in browser
- [ ] Flarum setup completed
- [ ] Admin account created

---

## 🆘 Get Help

1. **Check the logs:**
   ```bash
   ssh -i terraform/riderhub-flarum-key.pem ec2-user@INSTANCE_IP
   sudo tail -f /var/log/httpd/error_log
   ```

2. **Run validation:**
   ```bash
   ./scripts/validate-setup.sh
   ```

3. **Check AWS Console:**
   - EC2 → Instances
   - RDS → Databases
   - VPC → Load Balancers

---

## 🎉 Success!

If you can see Flarum, **you're live!**

**Next Steps:**
1. Customize your forum appearance
2. Create discussion categories
3. Invite users
4. Start building your community

**Happy Riding! 🏍️**

---

## 🔗 Quick Links

- **GitHub:** https://github.com/scale600/aws-flarum-devops
- **AWS Console:** https://console.aws.amazon.com/
- **Flarum Docs:** https://docs.flarum.org/

---

**Need more details? Check [DEPLOY.md](DEPLOY.md) for the complete guide.**

