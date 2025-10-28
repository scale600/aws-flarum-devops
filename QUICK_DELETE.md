# ⚡ QUICK DELETE - All AWS Resources

## 🎯 Complete Resource List (All to be Deleted)

### Current Deployment:
- ✅ EC2 Instance (riderhub-flarum-core)
- ✅ VPC + Subnets + Internet Gateway
- ✅ Security Groups
- ✅ SSH Key Pair
- ✅ IAM Roles

### Old Deployment (May Still Exist):
- ⚠️ Application Load Balancer
- ⚠️ Target Groups  
- ⚠️ RDS MySQL Database
- ⚠️ S3 Bucket(s)
- ⚠️ Additional Security Groups

**Total Cost Now:** $0-30/month
**After Deletion:** $0/month ✅

---

## ⚡ FASTEST: Terraform Destroy (5 minutes)

```bash
# 1. Configure AWS (one-time)
aws configure
# Enter your AWS Access Key and Secret Key

# 2. Destroy everything
cd /Users/richardlee/Dev/project/aws-flarum-devops/terraform
terraform init
terraform destroy

# 3. Type 'yes' when prompted
```

**This deletes EVERYTHING automatically!**

---

## 🖱️ AWS Console (No CLI - 20 minutes)

### Critical Resources (Delete These First):

**1. RDS Database** (Highest cost if running - ~$12/month)
```
https://console.aws.amazon.com/rds/home?region=us-east-1#databases:
```
→ Find any with "riderhub"/"flarum"
→ Delete (UNCHECK "create final snapshot")

**2. Application Load Balancer** (High cost if running - ~$16/month)
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:
```
→ Find any with "riderhub"/"flarum"
→ Delete

**3. EC2 Instance**
```
https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:
```
→ Find "riderhub-flarum-core"
→ Terminate

**4. S3 Buckets**
```
https://s3.console.aws.amazon.com/s3/buckets
```
→ Find any with "riderhub"/"flarum"
→ Empty each bucket first
→ Then delete

### Then Delete Supporting Resources:

5. Target Groups
6. Security Groups (wait 5 min after EC2/RDS/ALB)
7. Key Pairs
8. IAM Roles
9. VPC Resources (subnets, route tables, IGW, VPC)

**📖 Full instructions: DELETE_EVERYTHING.md**

---

## ✅ Quick Verification

After deletion, check these are $0:

```
Billing Dashboard:
https://console.aws.amazon.com/billing/home#/bills
```

Should show no active resources and $0 for next month.

---

## 🎯 Recommendation

**Best:** Use `terraform destroy` - Fast, complete, guaranteed
**Alternative:** Follow DELETE_EVERYTHING.md step-by-step

---

**Start now to stop AWS charges immediately!** 🚀

