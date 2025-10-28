# 🗑️ DELETE ALL AWS RESOURCES - Complete Cleanup

## ⚠️ This Will Delete EVERYTHING
- Current EC2-only deployment
- Old deployment resources (ALB, RDS, S3)
- ALL project infrastructure

**This CANNOT be undone!**

---

## 🎯 BEST METHOD: Terraform Destroy (Recommended)

This ensures EVERYTHING is deleted, including old resources.

### Step 1: Configure AWS CLI

```bash
# Install AWS CLI if not installed
# macOS:
brew install awscli

# Or download from: https://aws.amazon.com/cli/

# Configure with your credentials
aws configure
```

**Enter when prompted:**
- AWS Access Key ID: `AKIA...` (from your GitHub secrets)
- AWS Secret Access Key: `wJa...` (from your GitHub secrets)
- Default region: `us-east-1`
- Default output format: `json`

### Step 2: Run Terraform Destroy

```bash
cd /Users/richardlee/Dev/project/aws-flarum-devops/terraform

# Initialize Terraform (if not already)
terraform init

# Preview what will be destroyed
terraform plan -destroy

# Destroy EVERYTHING
terraform destroy
```

**Type `yes` when prompted**

### What This Deletes:

✅ **Current Resources:**
- EC2 Instance (riderhub-flarum-core)
- VPC, Subnets, Internet Gateway
- Route Tables
- Security Groups
- SSH Key Pair
- IAM Roles & Instance Profiles

✅ **Old Resources (if they exist):**
- Application Load Balancer
- Target Groups
- RDS MySQL Database
- S3 Bucket (with all files)
- All associated resources

⏱️ **Time:** 5-8 minutes

💰 **Result:** $0/month AWS costs

---

## 🖱️ ALTERNATIVE: AWS Console (Manual Method)

If you can't/don't want to configure AWS CLI, delete manually:

### Part 1: Current Deployment Resources

#### 1. Terminate EC2 Instance
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```
- Find: `riderhub-flarum-core`
- Select → Actions → Instance State → **Terminate Instance**
- ✅ Confirm deletion

---

### Part 2: Old Deployment Resources ⚠️

#### 2. Delete Application Load Balancer
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
```
- Find: `riderhub-flarum-alb` or any with "riderhub"/"flarum"
- Select → Actions → **Delete**
- Type "confirm" → Delete
- ⏳ Wait 2-3 minutes

#### 3. Delete Target Groups
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:
```
- Find: `riderhub-flarum-tg` or similar
- Select → Actions → **Delete**

#### 4. Delete RDS Database ⚠️ IMPORTANT
```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```
- Find: `riderhub-flarum-db` or any with "riderhub"/"flarum"
- Select → Actions → **Delete**
- **UNCHECK** "Create final snapshot" (to avoid costs)
- **CHECK** "I acknowledge..."
- Type: `delete me`
- Click **Delete**
- ⏳ Wait 5-10 minutes for deletion

#### 5. Delete S3 Buckets
```
https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1
```
- Find: ALL buckets with "riderhub" or "flarum" in name
  - Example: `riderhub-flarum-files-*`
  
For EACH bucket:
1. **Empty the bucket first:**
   - Select bucket
   - Click **Empty**
   - Type: `permanently delete`
   - Click **Empty**
   
2. **Then delete the bucket:**
   - Select bucket (after it's empty)
   - Click **Delete**
   - Type the bucket name
   - Click **Delete**

---

### Part 3: Networking & Security

#### 6. Delete Security Groups
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:
```
- ⏳ **WAIT 5 minutes** after EC2/RDS/ALB deletion
- Search for: "riderhub" or "flarum"
- Find ALL security groups (usually 2-3):
  - `riderhub-flarum-web-sg`
  - `riderhub-flarum-rds-sg`
  - Any others with "riderhub"/"flarum"
  
For EACH security group:
- Select → Actions → **Delete security groups**
- Confirm

**Note:** Can't delete default VPC security group (that's OK)

#### 7. Delete SSH Key Pairs
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
```
- Find: `riderhub-flarum-key`
- Select → Actions → **Delete**
- Confirm

#### 8. Delete Elastic IPs (if any)
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Addresses:
```
- Look for any unassociated Elastic IPs
- Select → Actions → **Release Elastic IP address**

---

### Part 4: IAM Cleanup

#### 9. Delete IAM Roles
```
https://console.aws.amazon.com/iam/home#/roles
```
- Search: "riderhub" or "flarum"
- Find ALL roles (usually 1-2):
  - `riderhub-flarum-instance-role`
  - Any others

For EACH role:
1. Click on the role name
2. Go to **Permissions** tab
3. **Detach** all policies
4. Go to **Trust relationships**
5. If in instance profile, **Remove** from instance profile
6. Go back to role summary
7. Click **Delete role**
8. Confirm

#### 10. Delete IAM Instance Profiles
```
https://console.aws.amazon.com/iam/home#/instance-profiles
```
- Find: `riderhub-flarum-instance-profile`
- Delete it

---

### Part 5: VPC Cleanup (Final Step)

#### 11. Delete Subnets
```
https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
```
- Search for: Tag `Project = RiderHub`
- Find ALL subnets (usually 4):
  - `riderhub-flarum-public-1`
  - `riderhub-flarum-public-2`
  - `riderhub-flarum-private-1`
  - `riderhub-flarum-private-2`
- Select ALL → Actions → **Delete subnets**

#### 12. Delete Route Tables
```
https://console.aws.amazon.com/vpc/home?region=us-east-1#RouteTables:
```
- Find: `riderhub-flarum-public-rt`
- Select → Actions → **Delete route table**
- **Note:** Can't delete main route table (that's OK)

#### 13. Detach & Delete Internet Gateway
```
https://console.aws.amazon.com/vpc/home?region=us-east-1#igws:
```
- Find: `riderhub-flarum-igw`
- Select → Actions → **Detach from VPC**
- Then: Actions → **Delete internet gateway**

#### 14. Delete VPC
```
https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
```
- Find: VPC with Tag `Project = RiderHub`
- Select → Actions → **Delete VPC**
- This will delete any remaining associated resources

---

## ✅ Verification Checklist

After cleanup, verify everything is gone:

### Check EC2 Console:
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1
```
- ✅ Instances: None (or only "terminated")
- ✅ Load Balancers: None
- ✅ Target Groups: None
- ✅ Security Groups: Only "default" remains
- ✅ Key Pairs: None with "riderhub"/"flarum"
- ✅ Elastic IPs: None unassociated

### Check RDS Console:
```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```
- ✅ Databases: None with "riderhub"/"flarum"

### Check S3 Console:
```
https://s3.console.aws.amazon.com/s3/buckets
```
- ✅ Buckets: None with "riderhub"/"flarum"

### Check IAM Console:
```
https://console.aws.amazon.com/iam/home#/roles
```
- ✅ Roles: None with "riderhub"/"flarum"

### Check VPC Console:
```
https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
```
- ✅ VPC: None with Tag `Project = RiderHub`

### Check Billing:
```
https://console.aws.amazon.com/billing/home#/bills
```
- ✅ Current charges: Should stop accumulating
- ✅ Next month: Should be $0.00

---

## 💰 Cost Impact

### Before Cleanup:
- EC2 (stopped): ~$1/month (storage)
- ALB (if running): ~$16/month
- RDS (if running): ~$12/month
- S3: ~$1/month
- **Total: Up to $30/month**

### After Cleanup:
- **$0/month** ✅

---

## ⏱️ Total Time Required

- **Terraform Destroy:** 5-8 minutes (automated)
- **AWS Console Method:** 20-30 minutes (manual)

---

## 🔄 If You Want to Redeploy Later

Your code is safe:
- ✅ GitHub repo: Still there
- ✅ Local code: Still on your machine

To redeploy:
```bash
# Just push a commit to trigger GitHub Actions
cd /Users/richardlee/Dev/project/aws-flarum-devops
echo "Redeploying" >> README.md
git add README.md
git commit -m "Trigger redeployment"
git push origin main

# Or run locally:
cd terraform
terraform apply
```

---

## 🆘 Troubleshooting

### "Security group in use"
- Wait 5 more minutes
- EC2/RDS/ALB still terminating

### "VPC has dependencies"
- Delete resources in this order:
  1. EC2, ALB, RDS first
  2. Then security groups
  3. Then subnets
  4. Then route tables
  5. Then internet gateway
  6. Finally VPC

### "Cannot delete IAM role"
- Remove from instance profile first
- Detach all policies
- Then delete

### "S3 bucket not empty"
- Must empty bucket before deleting
- Use "Empty" button in console
- Or use: `aws s3 rm s3://BUCKET_NAME --recursive`

---

## 📝 Summary

**Easiest Method:**
1. Configure AWS CLI: `aws configure`
2. Run: `terraform destroy`
3. Type: `yes`
4. Done! ✅

**Manual Method:**
1. Follow all 14 steps above
2. Use verification checklist
3. Done! ✅

---

**Ready to delete everything? Choose your method and start!** 🗑️

