# 🗑️ DELETE ALL AWS RESOURCES - Complete List

## ⚠️ COMPREHENSIVE DELETION - Every Single Resource

This guide covers **EVERY** AWS resource that might exist for this project:
- ✅ EC2 Instances
- ✅ RDS Databases
- ✅ ALB (Application Load Balancers)
- ✅ ELB (Classic Load Balancers)
- ✅ Amplify Applications
- ✅ S3 Buckets
- ✅ And everything else

---

## 🎯 METHOD 1: Terraform Destroy (RECOMMENDED - Deletes Everything)

This is the **FASTEST and MOST COMPLETE** method:

```bash
# 1. Configure AWS CLI (one-time setup)
aws configure
# Enter:
# - AWS Access Key ID: (from your GitHub secrets)
# - AWS Secret Access Key: (from your GitHub secrets)
# - Region: us-east-1
# - Output: json

# 2. Go to terraform directory
cd /Users/richardlee/Dev/project/aws-flarum-devops/terraform

# 3. Initialize Terraform
terraform init

# 4. Destroy EVERYTHING
terraform destroy --auto-approve
```

This will delete:
- ✅ All EC2 instances
- ✅ All RDS databases
- ✅ All load balancers (ALB/ELB)
- ✅ All S3 buckets
- ✅ All VPC resources
- ✅ All security groups
- ✅ All IAM roles
- ✅ Everything else

⏱️ **Time:** 5-10 minutes
💰 **Result:** $0/month

---

## 🖱️ METHOD 2: AWS Console (Manual - Delete Everything)

### Step 1: Check for Amplify Applications

```
https://console.aws.amazon.com/amplify/home?region=us-east-1#/
```

**Actions:**
- Look for any apps with "riderhub" or "flarum"
- If found:
  - Click on the app
  - Actions → **Delete app**
  - Type app name to confirm
  - Delete

**Expected:** No Amplify apps found (project doesn't use Amplify)

---

### Step 2: Delete RDS Databases ⚠️ CRITICAL

```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```

**Actions:**
- Find **ALL** databases with "riderhub" or "flarum"
- For EACH database:
  1. Select the database
  2. Actions → **Delete**
  3. **UNCHECK** "Create final snapshot" (important - saves cost)
  4. **CHECK** "I acknowledge that upon instance deletion..."
  5. Type: `delete me`
  6. Click **Delete**
  
⏳ **Wait 5-10 minutes** for deletion to complete

**Databases to look for:**
- `riderhub-flarum-db`
- `riderhub-flarum`
- `flarum-db`
- Any database with these keywords

💰 **Saves:** ~$12/month per database

---

### Step 3: Delete Application Load Balancers (ALB) ⚠️ CRITICAL

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
```

**Actions:**
- Find **ALL** load balancers (check ALL types: Application, Network, Classic)
- Look for names containing "riderhub" or "flarum"
- For EACH load balancer:
  1. Select it
  2. Actions → **Delete load balancer**
  3. Type "confirm"
  4. Delete

**Load balancers to look for:**
- `riderhub-flarum-alb`
- `flarum-alb`
- Any ALB with these keywords

⏳ **Wait 2-3 minutes** for deletion

💰 **Saves:** ~$16/month per ALB

---

### Step 4: Delete Classic Load Balancers (ELB)

Same console as Step 3:
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
```

**Actions:**
- Switch to "Classic Load Balancers" tab (if shown separately)
- Find any with "riderhub" or "flarum"
- Delete the same way as ALB

**Expected:** No Classic ELBs found (project uses ALB, not Classic ELB)

---

### Step 5: Delete Target Groups

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:
```

**Actions:**
- Find **ALL** target groups with "riderhub" or "flarum"
- For EACH:
  1. Select
  2. Actions → **Delete**
  3. Confirm

**Target groups to look for:**
- `riderhub-flarum-tg`
- `flarum-target-group`
- Any with these keywords

---

### Step 6: Terminate EC2 Instances

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```

**Actions:**
- Find **ALL** instances with "riderhub" or "flarum" in name or tags
- Check **ALL** states: running, stopped, stopping
- For EACH instance:
  1. Select (checkbox)
  2. Instance state → **Terminate instance**
  3. Confirm

**Instances to look for:**
- `riderhub-flarum-core`
- `riderhub-flarum`
- Any instance with `Project: RiderHub` tag

⏳ **Wait 3-5 minutes** for termination

💰 **Saves:** ~$8/month per instance

---

### Step 7: Delete S3 Buckets

```
https://s3.console.aws.amazon.com/s3/buckets
```

**Actions:**
- Find **ALL** buckets with "riderhub" or "flarum" in name
- For EACH bucket:

  **a) Empty the bucket first:**
  1. Select bucket
  2. Click **Empty**
  3. Type: `permanently delete`
  4. Click **Empty**
  5. Wait for completion
  
  **b) Then delete the bucket:**
  1. Select bucket (now empty)
  2. Click **Delete**
  3. Type the exact bucket name
  4. Click **Delete bucket**

**Buckets to look for:**
- `riderhub-flarum-files-*` (e.g., riderhub-flarum-files-v6sjhj0e)
- `flarum-storage-*`
- Any S3 bucket with these keywords

💰 **Saves:** ~$1/month per bucket

---

### Step 8: Delete Auto Scaling Groups (if any)

```
https://console.aws.amazon.com/ec2/home?region=us-east-1#AutoScalingGroups:
```

**Actions:**
- Find any Auto Scaling Groups with "riderhub" or "flarum"
- Delete each one

**Expected:** None found (project doesn't use Auto Scaling)

---

### Step 9: Delete Launch Templates (if any)

```
https://console.aws.amazon.com/ec2/home?region=us-east-1#LaunchTemplates:
```

**Actions:**
- Find any Launch Templates with "riderhub" or "flarum"
- Delete each one

**Expected:** None found

---

### Step 10: Delete Elastic IPs

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Addresses:
```

**Actions:**
- Look for any Elastic IPs
- Check if they're **NOT** associated with running instances
- For each unassociated IP:
  1. Select
  2. Actions → **Release Elastic IP address**
  3. Confirm

💰 **Saves:** ~$3.60/month per unassociated IP

---

### Step 11: Delete Security Groups

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:
```

⏳ **IMPORTANT:** Wait 5-10 minutes after deleting EC2, RDS, and ALB/ELB

**Actions:**
- Search for "riderhub" or "flarum"
- Find **ALL** security groups
- For EACH (except "default"):
  1. Select
  2. Actions → **Delete security groups**
  3. Confirm

**Security groups to look for:**
- `riderhub-flarum-web-sg`
- `riderhub-flarum-rds-sg`
- `riderhub-flarum-alb-sg`
- Any SG with these keywords

**Note:** Can't delete "default" security group (that's normal and OK)

---

### Step 12: Delete RDS Subnet Groups

```
https://console.aws.amazon.com/rds/home?region=us-east-1#db-subnet-groups-list:
```

**Actions:**
- Find subnet groups with "riderhub" or "flarum"
- Delete each one

---

### Step 13: Delete RDS Parameter Groups

```
https://console.aws.amazon.com/rds/home?region=us-east-1#parameter-groups:
```

**Actions:**
- Find custom parameter groups (not default) with "riderhub" or "flarum"
- Delete each one

---

### Step 14: Delete RDS Option Groups

```
https://console.aws.amazon.com/rds/home?region=us-east-1#option-groups:
```

**Actions:**
- Find custom option groups (not default) with "riderhub" or "flarum"
- Delete each one

---

### Step 15: Delete SSH Key Pairs

```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
```

**Actions:**
- Find **ALL** keys with "riderhub" or "flarum"
- For EACH:
  1. Select
  2. Actions → **Delete**
  3. Confirm

**Keys to look for:**
- `riderhub-flarum-key`
- Any key with these keywords

---

### Step 16: Delete IAM Roles

```
https://console.aws.amazon.com/iam/home#/roles
```

**Actions:**
- Search: "riderhub" or "flarum"
- For EACH role found:
  
  1. Click on the role name
  2. Go to **Permissions** tab
  3. **Detach** all attached policies
  4. Delete all inline policies
  5. Go to role summary
  6. Click **Delete role**
  7. Confirm

**Roles to look for:**
- `riderhub-flarum-instance-role`
- Any role with these keywords

---

### Step 17: Delete IAM Instance Profiles

```
https://console.aws.amazon.com/iam/home#/instance-profiles
```

**Actions:**
- Find profiles with "riderhub" or "flarum"
- Delete each one

---

### Step 18: Delete VPC Subnets

```
https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
```

⏳ **Wait:** Ensure all EC2, RDS, ALB deleted first

**Actions:**
- Filter by Tag: `Project = RiderHub`
- Find **ALL** subnets (usually 4)
- Select ALL
- Actions → **Delete subnets**
- Confirm

**Subnets to look for:**
- `riderhub-flarum-public-1`
- `riderhub-flarum-public-2`
- `riderhub-flarum-private-1`
- `riderhub-flarum-private-2`

---

### Step 19: Delete Route Tables

```
https://console.aws.amazon.com/vpc/home?region=us-east-1#RouteTables:
```

**Actions:**
- Find route tables with "riderhub" or "flarum"
- For EACH (except main route table):
  1. Select
  2. Actions → **Delete route table**
  3. Confirm

**Note:** Can't delete the main route table (that's OK)

---

### Step 20: Delete Internet Gateway

```
https://console.aws.amazon.com/vpc/home?region=us-east-1#igws:
```

**Actions:**
- Find IGW with "riderhub" or "flarum"
- For EACH:
  1. Select
  2. Actions → **Detach from VPC**
  3. Confirm
  4. Then: Actions → **Delete internet gateway**
  5. Confirm

---

### Step 21: Delete NAT Gateways (if any)

```
https://console.aws.amazon.com/vpc/home?region=us-east-1#NatGateways:
```

**Actions:**
- Find any NAT gateways with "riderhub" or "flarum"
- Delete each one

**Expected:** None found (project doesn't use NAT Gateway)

---

### Step 22: Delete VPC

```
https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
```

**Actions:**
- Find VPC with Tag: `Project = RiderHub`
- Select
- Actions → **Delete VPC**
- This will delete any remaining associated resources
- Confirm

---

### Step 23: Delete CloudWatch Log Groups

```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
```

**Actions:**
- Search for: "riderhub" or "flarum" or "/aws/flarum"
- For EACH log group:
  1. Select
  2. Actions → **Delete log group(s)**
  3. Confirm

---

### Step 24: Delete CloudWatch Alarms

```
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:
```

**Actions:**
- Find alarms with "riderhub" or "flarum"
- Delete each one

---

### Step 25: Check Lambda Functions (if any)

```
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions
```

**Actions:**
- Search for: "riderhub" or "flarum"
- Delete any found

**Expected:** None found (unless you used Lambda deployment)

---

## ✅ COMPLETE VERIFICATION CHECKLIST

After deletion, check **ALL** these consoles to confirm $0 resources:

### Compute:
- [ ] EC2 Instances: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
- [ ] Amplify: https://console.aws.amazon.com/amplify/home?region=us-east-1
- [ ] Lambda: https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

### Load Balancing:
- [ ] Load Balancers (ALB/ELB): https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
- [ ] Target Groups: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#TargetGroups:

### Database:
- [ ] RDS Databases: https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
- [ ] RDS Subnet Groups: https://console.aws.amazon.com/rds/home?region=us-east-1#db-subnet-groups-list:

### Storage:
- [ ] S3 Buckets: https://s3.console.aws.amazon.com/s3/buckets

### Networking:
- [ ] VPC: https://console.aws.amazon.com/vpc/home?region=us-east-1#vpcs:
- [ ] Subnets: https://console.aws.amazon.com/vpc/home?region=us-east-1#subnets:
- [ ] Security Groups: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:
- [ ] Elastic IPs: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Addresses:

### Access:
- [ ] Key Pairs: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
- [ ] IAM Roles: https://console.aws.amazon.com/iam/home#/roles

### Billing:
- [ ] Billing Dashboard: https://console.aws.amazon.com/billing/home#/bills
  - Should show decreasing charges
  - Next month should be $0.00

---

## 💰 Cost Savings Summary

**Before Deletion (Maximum):**
- EC2 Instance: $8/month
- RDS Database: $12/month
- ALB: $16/month
- S3 Storage: $1/month
- Elastic IP (unassociated): $3.60/month
- **Total: Up to $40.60/month**

**After Complete Deletion:**
- **$0.00/month** ✅

---

## ⏱️ Time Required

- **Method 1 (Terraform):** 5-10 minutes (automated)
- **Method 2 (Console):** 30-45 minutes (manual, but thorough)

---

## 🎯 RECOMMENDATION

**Use Terraform Destroy** - It's:
- ✅ Fastest
- ✅ Most complete
- ✅ Least error-prone
- ✅ Guaranteed to find everything

Just run:
```bash
aws configure
cd terraform
terraform destroy --auto-approve
```

---

**Ready to delete everything? Start now!** 🗑️

