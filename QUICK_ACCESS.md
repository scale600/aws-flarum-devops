# 🎯 Quick Access Guide

## Your RiderHub Forum

### Get Your Site URL (2 Minutes)

#### 1. Open AWS Console
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```

#### 2. Find Instance
- **Name:** `riderhub-flarum-core`
- **Or filter by:** Project = RiderHub

#### 3. Check Status
- **If Stopped:** Select → Actions → Instance State → Start
- **If Running:** Continue to step 4

#### 4. Get Public IP
- Click on the instance
- Copy **Public IPv4 address**
- Example: `54.123.45.67`

#### 5. Visit Your Site
```
http://YOUR_EC2_PUBLIC_IP
```

---

## 🎨 What You'll See

### Beautiful Welcome Page:
- 🏍️ Motorcycle emoji animation
- 🎨 Purple gradient background
- ✅ Status indicators for all services
- 📊 Architecture information
- 💰 Cost breakdown

### Page Content:
```
RiderHub
Motorcycle Community Forum

✓ EC2 Instance Running
✓ Apache Web Server Active
✓ MySQL Database Ready
✓ Flarum Forum Installed

Architecture:
All-in-One EC2 Instance
• Local MySQL Database
• Apache Web Server
• Flarum Forum Software
• File Storage on EC2

Cost: ~$8/month (AWS Free Tier eligible)
```

---

## 🔧 If Site Doesn't Load

### Problem: Connection Timeout

**Wait 2-3 minutes after starting instance**
- Apache needs time to start
- MySQL needs to initialize
- Flarum needs to load

### Problem: HTTP 503

**Flarum is still installing**
- Wait 1-2 more minutes
- Refresh the page

### Problem: HTTP 404

**Apache is serving, but config issue**
- SSH into instance and check logs
```bash
ssh -i terraform/riderhub-flarum-key.pem ec2-user@YOUR_EC2_IP
sudo tail -f /var/log/flarum-install.log
```

---

## 💡 Pro Tips

### Save Your URL
Bookmark the IP address in your browser

### Stop Instance When Not Using
Save money by stopping the instance:
- AWS Console → Select instance → Actions → Stop
- Costs $0 when stopped
- Start anytime you need it

### Get SSH Access
```bash
cd /Users/richardlee/Dev/project/aws-flarum-devops/terraform
ssh -i riderhub-flarum-key.pem ec2-user@YOUR_EC2_IP
```

---

## 📊 Your Deployment

**Architecture:** All-in-One EC2
**Components:**
- ✅ MySQL Database (local)
- ✅ Apache + PHP 8.1
- ✅ Flarum Forum
- ✅ File Storage (local)

**Cost:** ~$8/month
**Free Tier:** Yes (first 12 months)

**Deployed via:**
- 🏗️ Terraform (Infrastructure as Code)
- 🔄 GitHub Actions (CI/CD)
- 🐳 Docker Ready

---

## ✅ Success Checklist

- [ ] Found instance in AWS Console
- [ ] Instance is Running
- [ ] Got Public IP address
- [ ] Can access http://YOUR_IP
- [ ] See beautiful RiderHub welcome page

---

**Need help?** Check the main README.md or GitHub Issues.

