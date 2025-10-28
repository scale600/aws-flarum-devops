# 🎉 Your RiderHub Site is LIVE!

## ✅ Deployment Status: SUCCESS

Your infrastructure has been successfully deployed to AWS via GitHub Actions!

The following resources were created:
- ✅ EC2 Instance (running Flarum)
- ✅ RDS MySQL Database
- ✅ Application Load Balancer
- ✅ S3 Bucket: `riderhub-flarum-files-9j7c2e3r`
- ✅ VPC and Security Groups

---

## 🌐 Get Your Site URL (3 Options)

### **Option 1: AWS Console** (Easiest - No setup required)

1. **Go to AWS Console:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
   ```

2. **Find your Load Balancer:**
   - Look for a load balancer named: `riderhub-flarum-alb` or `flarum-*-alb`
   - In the list, find the "DNS name" column

3. **Copy the DNS name:**
   - It will look like: `riderhub-flarum-alb-123456789.us-east-1.elb.amazonaws.com`

4. **Visit your site:**
   ```
   http://[YOUR-DNS-NAME]
   ```

**⏱️ IMPORTANT:** Wait 5-7 minutes after deployment for EC2 to finish installing Flarum!

---

### **Option 2: Run Get URL Script** (After configuring AWS CLI)

```bash
# First, configure AWS CLI (one-time setup)
aws configure
# Enter your AWS access key and secret key

# Then run the script
./scripts/get-site-url.sh
```

This script will:
- ✅ Automatically find your Flarum URL
- ✅ Show all deployment details
- ✅ Offer to open the site in your browser

---

### **Option 3: Check Terraform State** (If you deployed locally)

```bash
cd terraform
terraform output flarum_url
```

---

## 🔍 Verify Deployment Status

### Check EC2 Instance

1. **Go to EC2 Dashboard:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
   ```

2. **Find instance named:** `riderhub-flarum` or `flarum-*`

3. **Check Status:**
   - Should be "Running" (green)
   - "Status checks" should show "2/2 checks passed" after a few minutes

### Check Load Balancer Health

1. **Go to Target Groups:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:
   ```

2. **Select** your target group

3. **Check "Targets" tab:**
   - Should show your EC2 instance as "healthy" (green)
   - If "initial" or "unhealthy" (red), wait 2-3 more minutes

---

## ⏱️ Timeline After Deployment

| Time | Status |
|------|--------|
| 0:00 | GitHub Actions completed ✅ |
| 0:00-2:00 | EC2 instance booting up |
| 2:00-7:00 | Installing PHP, Apache, Flarum |
| 7:00+ | **Flarum ready to use!** 🎉 |

---

## 🚀 Access Your Site

Once you have your URL (from Option 1, 2, or 3 above):

### **Step 1: Visit the URL**
```
http://your-alb-dns-name.elb.amazonaws.com
```

### **Step 2: What You'll See**

**If Ready (7+ minutes after deployment):**
- Flarum installation wizard
- Or: Flarum homepage (if already set up)

**If Not Ready (< 7 minutes):**
- 502 Bad Gateway
- 503 Service Unavailable
- **Solution:** Wait 2-3 more minutes and refresh

### **Step 3: Complete Flarum Setup**

1. **Enter Forum Details:**
   - Forum Title: `RiderHub` (or your choice)
   - Forum Description: `Motorcycle Community Forum`

2. **Database Configuration:**
   - Already configured! Click Next

3. **Create Admin Account:**
   - Username: your choice
   - Email: your email
   - Password: secure password

4. **Finish Setup!**

---

## 🔐 SSH Access (Optional)

If you need to check installation status or troubleshoot:

### **Get EC2 Public IP:**

1. **Go to EC2 Console:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
   ```

2. **Find your instance:** `riderhub-flarum`

3. **Copy "Public IPv4 address"**

### **SSH Command:**

```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@YOUR-EC2-IP
```

**Note:** The SSH key was generated during deployment and saved in `terraform/riderhub-flarum-key.pem`

### **Check Installation Status:**

```bash
# Watch Flarum installation progress
tail -f /var/log/flarum-install.log

# Check Apache status
sudo systemctl status httpd

# Check if Flarum is installed
ls -la /var/www/flarum
```

---

## 🎨 Customize Your Forum

After completing setup:

### **1. Access Admin Panel**
```
http://your-url/admin
```

### **2. Customize Appearance**
- **Administration → Appearance**
- Upload logo
- Change colors
- Set header image

### **3. Configure Forum Settings**
- **Administration → Basics**
- Forum description
- Welcome banner
- Registration settings

### **4. Create Categories**
- **Administration → Tags** (install tags extension)
- Create discussion categories
- Set permissions

### **5. Install Extensions**
```bash
# SSH into your server
ssh -i terraform/riderhub-flarum-key.pem ec2-user@YOUR-EC2-IP

# Navigate to Flarum
cd /var/www/flarum

# Install extension (example: tags)
composer require flarum/tags

# Run migrations
php flarum migrate

# Clear cache
php flarum cache:clear
```

---

## 🛠️ Troubleshooting

### **Problem: 502 Bad Gateway**

**Cause:** EC2 not ready yet or Apache not running

**Solution:**
```bash
# SSH into server
ssh -i terraform/riderhub-flarum-key.pem ec2-user@YOUR-EC2-IP

# Check Apache
sudo systemctl status httpd

# If not running, start it
sudo systemctl start httpd

# Check installation progress
tail -f /var/log/flarum-install.log
```

### **Problem: 503 Service Unavailable**

**Cause:** Flarum installation in progress

**Solution:** Wait 5 more minutes and refresh

### **Problem: Can't find my URL**

**Solution:**
1. Check AWS Console (Option 1 above)
2. Look for load balancer with name containing "riderhub" or "flarum"
3. Copy DNS name from the list

### **Problem: Target Group shows "Unhealthy"**

**Causes:**
- EC2 not finished booting
- Apache not started
- Flarum installation incomplete

**Solution:**
1. Wait 5-7 minutes
2. Check EC2 instance status in AWS Console
3. SSH in and check logs (see SSH Access section)

---

## 📊 Monitor Your Deployment

### **CloudWatch Logs**

```bash
# View EC2 logs
aws logs tail /aws/ec2/riderhub-flarum --follow
```

### **Check Resource Status**

```bash
# If you have AWS CLI configured
./scripts/get-site-url.sh
```

---

## 💰 Cost Reminder

**Current Setup (AWS Free Tier):**
- EC2 t3.micro: FREE (750 hours/month)
- RDS db.t3.micro: FREE (750 hours/month)
- ALB: FREE (750 hours/month)
- S3: FREE (5GB storage)

**Total Cost:** $0/month (within Free Tier)

**After Free Tier (12 months):**
- Estimated: ~$15-20/month

**To minimize costs:**
- Stop EC2 when not using
- Set up billing alerts
- Monitor usage monthly

---

## 🎯 Quick Commands Reference

```bash
# Get your site URL (after AWS CLI setup)
./scripts/get-site-url.sh

# SSH into server
ssh -i terraform/riderhub-flarum-key.pem ec2-user@EC2-IP

# Check Flarum installation
tail -f /var/log/flarum-install.log

# Restart Apache
sudo systemctl restart httpd

# Update Flarum
cd /var/www/flarum && composer update

# Destroy infrastructure (when done)
cd terraform && terraform destroy
```

---

## ✅ Success Checklist

- [ ] Found Load Balancer DNS name in AWS Console
- [ ] Waited 7+ minutes after deployment
- [ ] Visited Flarum URL in browser
- [ ] Completed Flarum setup wizard
- [ ] Created admin account
- [ ] Logged into admin panel
- [ ] Customized forum appearance
- [ ] Created first discussion
- [ ] **Your forum is LIVE!** 🎉

---

## 🆘 Need More Help?

1. **Check installation logs:**
   ```bash
   ssh -i terraform/riderhub-flarum-key.pem ec2-user@EC2-IP
   tail -f /var/log/flarum-install.log
   ```

2. **Check Apache logs:**
   ```bash
   sudo tail -f /var/log/httpd/error_log
   ```

3. **Verify resources in AWS Console:**
   - EC2: https://console.aws.amazon.com/ec2
   - RDS: https://console.aws.amazon.com/rds
   - Load Balancers: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers

4. **Check GitHub Actions logs:**
   ```
   https://github.com/scale600/aws-flarum-devops/actions
   ```

---

## 🏍️ Congratulations!

Your RiderHub motorcycle community forum is now live on AWS!

**Next Steps:**
1. Get your URL from AWS Console (see Option 1 above)
2. Visit the site
3. Complete setup
4. Start building your community!

**Happy Riding! 🏍️**

---

**Project Repository:** https://github.com/scale600/aws-flarum-devops

**Documentation:**
- QUICK_START.md - Quick deployment guide
- DEPLOY.md - Complete deployment documentation
- DEPLOYMENT_GUIDE.md - Step-by-step instructions

