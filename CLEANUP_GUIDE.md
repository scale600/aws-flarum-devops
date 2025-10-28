# 🗑️ Complete AWS Resource Cleanup Guide

## ⚠️ WARNING
This will DELETE ALL AWS resources for the RiderHub project and CANNOT be undone!

---

## 📋 Resources to Delete

Your project currently has these AWS resources:

1. **EC2 Instance** (riderhub-flarum-core) - ~$8/month
2. **VPC, Subnets, Internet Gateway** - Free
3. **Security Groups** - Free
4. **SSH Key Pair** - Free
5. **IAM Roles & Instance Profiles** - Free
6. **Possibly: RDS, S3, ALB** (if old resources still exist)

**Total Current Cost:** ~$8/month (if EC2 is running)

---

## 🎯 Choose Your Cleanup Method

### **Option 1: AWS Console (Easiest - No CLI needed)** ⭐

### **Option 2: Terraform Destroy (Recommended)**

### **Option 3: Automated Script (Requires AWS CLI)**

---

## Option 1: AWS Console Manual Cleanup

### Step 1: Terminate EC2 Instance

1. **Go to EC2 Console:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
   ```

2. **Find instance:** `riderhub-flarum-core`

3. **Terminate:**
   - Select the instance (checkbox)
   - Click **Actions** → **Instance State** → **Terminate Instance**
   - Confirm termination

4. **Wait 2-3 minutes** for termination to complete

---

### Step 2: Delete Load Balancer (if exists)

1. **Go to Load Balancers:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
   ```

2. **Find ALB:** `riderhub-flarum-alb`

3. **Delete:**
   - Select it
   - Actions → **Delete**
   - Type "confirm" and delete

---

### Step 3: Delete Target Groups (if exists)

1. **Go to Target Groups:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:
   ```

2. **Find:** `riderhub-flarum-tg`

3. **Delete:**
   - Select → Actions → Delete

---

### Step 4: Delete RDS Database (if exists)

1. **Go to RDS Console:**
   ```
   https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
   ```

2. **Find database:** `riderhub-flarum-db`

3. **Delete:**
   - Select → Actions → **Delete**
   - **Uncheck** "Create final snapshot"
   - **Check** "I acknowledge..."
   - Type "delete me"
   - Click **Delete**

---

### Step 5: Delete S3 Bucket (if exists)

1. **Go to S3 Console:**
   ```
   https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1
   ```

2. **Find bucket:** `riderhub-flarum-files-*`

3. **Empty bucket first:**
   - Select bucket
   - Click **Empty**
   - Type "permanently delete"
   - Click **Empty**

4. **Delete bucket:**
   - Select bucket again
   - Click **Delete**
   - Type bucket name
   - Click **Delete**

---

### Step 6: Delete Security Groups

1. **Go to Security Groups:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:
   ```

2. **Find:** All groups with "riderhub" or "flarum" in name

3. **Delete each:**
   - Select → Actions → **Delete security groups**
   - Confirm

**Note:** Wait until EC2 is fully terminated before deleting security groups

---

### Step 7: Delete Key Pair

1. **Go to Key Pairs:**
   ```
   https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
   ```

2. **Find:** `riderhub-flarum-key`

3. **Delete:**
   - Select → Actions → **Delete**

---

### Step 8: Delete IAM Roles

1. **Go to IAM Console:**
   ```
   https://console.aws.amazon.com/iam/home#/roles
   ```

2. **Search for:** "riderhub" or "flarum"

3. **For each role:**
   - Click on it
   - **Delete** any attached policies
   - **Remove** from instance profiles
   - Click **Delete role**

---

### Step 9: Delete VPC (Optional)

1. **Go to VPC Console:**
   ```
   https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
   ```

2. **Find VPC:** With tag `Project = RiderHub`

3. **Delete VPC:**
   - Select VPC
   - Actions → **Delete VPC**
   - This will delete all associated subnets, route tables, and internet gateway

---

## Option 2: Terraform Destroy (Recommended)

If you have AWS CLI configured:

```bash
cd /Users/richardlee/Dev/project/aws-flarum-devops/terraform

# Configure AWS credentials first (if not already done)
aws configure

# Initialize Terraform
terraform init

# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

**This will automatically delete:**
- ✅ EC2 Instance
- ✅ VPC, Subnets, Internet Gateway
- ✅ Route Tables
- ✅ Security Groups
- ✅ Key Pairs
- ✅ IAM Roles and Instance Profiles
- ✅ Any RDS, S3, or ALB resources (if they exist)

---

## Option 3: Automated Script

If you have AWS CLI configured:

```bash
cd /Users/richardlee/Dev/project/aws-flarum-devops

# Make script executable
chmod +x scripts/cleanup-all-resources.sh

# Run cleanup
./scripts/cleanup-all-resources.sh

# Type 'DELETE' when prompted to confirm
```

---

## ✅ Verification

After cleanup, verify all resources are gone:

### Check EC2:
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```
Should show: No instances (or only terminated ones)

### Check RDS:
```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```
Should show: No databases

### Check S3:
```
https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1
```
Should show: No riderhub/flarum buckets

### Check Billing:
```
https://console.aws.amazon.com/billing/home#/bills
```
Should show: $0.00 for current month (after cleanup)

---

## 💰 Cost Verification

After cleanup, your AWS bill should be:
- **Current month:** Small charges for time resources were running
- **Next month:** $0.00 ✅

---

## 📝 Optional: Delete GitHub Repository

If you also want to remove the code:

```bash
# Locally
cd /Users/richardlee/Dev/project
rm -rf aws-flarum-devops

# On GitHub
# Visit: https://github.com/scale600/aws-flarum-devops/settings
# Scroll to bottom → Delete this repository
# Type repository name to confirm
```

---

## 🔄 Reactivating Later

If you want to redeploy later:

1. The GitHub repository will still have all the code
2. Just run the GitHub Actions workflow again
3. Or run `terraform apply` locally
4. All resources will be recreated fresh

---

## ⚠️ Important Notes

1. **Termination Protection:** None of your resources have termination protection, so they can be deleted immediately

2. **Snapshots:** We skip final snapshots to avoid costs

3. **Billing:** It takes 24-48 hours for AWS billing to reflect the deletions

4. **Free Tier:** Even after cleanup, your Free Tier remains active for 12 months

5. **Data Loss:** All data will be permanently lost (database, uploaded files, etc.)

---

## 🎯 Recommended Order

**Easiest and Fastest:**
1. Use AWS Console (Option 1) - 10 minutes
2. Follow steps 1-9 in order
3. Verify everything is deleted

**Most Reliable:**
1. Configure AWS CLI: `aws configure`
2. Run `terraform destroy` - 5 minutes
3. Automatically cleans everything

---

## 📞 Need Help?

If you encounter errors during cleanup:
- Security Group "in use" → Wait 5 more minutes, EC2 still terminating
- VPC "has dependencies" → Delete EC2, ALB, RDS first, then try again
- IAM Role "in use" → Remove from instance profile first

---

**Ready to cleanup? Choose your method above!** 🗑️

