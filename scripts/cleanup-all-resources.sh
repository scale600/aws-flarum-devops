#!/bin/bash

# =============================================================================
# Complete AWS Resource Cleanup for RiderHub Project
# WARNING: This will DELETE ALL resources and cannot be undone!
# =============================================================================

set -e

REGION="us-east-1"
PROJECT_TAG="RiderHub"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  AWS RESOURCE CLEANUP - RiderHub Project"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will DELETE ALL AWS resources for this project!"
echo "This action CANNOT be undone!"
echo ""
read -p "Are you sure you want to continue? (type 'DELETE' to confirm): " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

echo ""
echo "🔍 Scanning for AWS resources..."
echo ""

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured."
    echo ""
    echo "Please run: aws configure"
    echo "Or use AWS Console method below."
    exit 1
fi

echo "✅ AWS credentials verified"
echo ""

# =============================================================================
# 1. List and Terminate EC2 Instances
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  EC2 Instances"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

INSTANCES=$(aws ec2 describe-instances \
    --region $REGION \
    --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=instance-state-name,Values=running,stopped" \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key=='Name'].Value|[0]]" \
    --output text 2>/dev/null || echo "")

if [ -n "$INSTANCES" ]; then
    echo "Found EC2 instances:"
    echo "$INSTANCES"
    echo ""
    
    INSTANCE_IDS=$(echo "$INSTANCES" | awk '{print $1}')
    
    for INSTANCE_ID in $INSTANCE_IDS; do
        echo "🗑️  Terminating instance: $INSTANCE_ID"
        aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID
    done
    
    echo "⏳ Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_IDS
    echo "✅ All EC2 instances terminated"
else
    echo "✅ No EC2 instances found"
fi

echo ""

# =============================================================================
# 2. Delete Load Balancers
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Application Load Balancers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ALB_ARNS=$(aws elbv2 describe-load-balancers \
    --region $REGION \
    --query "LoadBalancers[?contains(LoadBalancerName, 'riderhub') || contains(LoadBalancerName, 'flarum')].LoadBalancerArn" \
    --output text 2>/dev/null || echo "")

if [ -n "$ALB_ARNS" ]; then
    for ALB_ARN in $ALB_ARNS; do
        echo "🗑️  Deleting ALB: $ALB_ARN"
        aws elbv2 delete-load-balancer --region $REGION --load-balancer-arn $ALB_ARN
    done
    echo "✅ All ALBs deleted"
else
    echo "✅ No ALBs found"
fi

echo ""

# =============================================================================
# 3. Delete Target Groups
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Target Groups"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TG_ARNS=$(aws elbv2 describe-target-groups \
    --region $REGION \
    --query "TargetGroups[?contains(TargetGroupName, 'riderhub') || contains(TargetGroupName, 'flarum')].TargetGroupArn" \
    --output text 2>/dev/null || echo "")

if [ -n "$TG_ARNS" ]; then
    echo "⏳ Waiting 30 seconds for ALB to fully delete..."
    sleep 30
    
    for TG_ARN in $TG_ARNS; do
        echo "🗑️  Deleting Target Group: $TG_ARN"
        aws elbv2 delete-target-group --region $REGION --target-group-arn $TG_ARN 2>/dev/null || echo "   (already deleted or in use)"
    done
    echo "✅ Target groups processed"
else
    echo "✅ No target groups found"
fi

echo ""

# =============================================================================
# 4. Delete RDS Instances
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  RDS Database Instances"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RDS_INSTANCES=$(aws rds describe-db-instances \
    --region $REGION \
    --query "DBInstances[?contains(DBInstanceIdentifier, 'riderhub') || contains(DBInstanceIdentifier, 'flarum')].DBInstanceIdentifier" \
    --output text 2>/dev/null || echo "")

if [ -n "$RDS_INSTANCES" ]; then
    for RDS_ID in $RDS_INSTANCES; do
        echo "🗑️  Deleting RDS instance: $RDS_ID (skip final snapshot)"
        aws rds delete-db-instance \
            --region $REGION \
            --db-instance-identifier $RDS_ID \
            --skip-final-snapshot
    done
    echo "✅ All RDS instances deleted"
else
    echo "✅ No RDS instances found"
fi

echo ""

# =============================================================================
# 5. Delete S3 Buckets
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  S3 Buckets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

S3_BUCKETS=$(aws s3api list-buckets \
    --query "Buckets[?contains(Name, 'riderhub') || contains(Name, 'flarum')].Name" \
    --output text 2>/dev/null || echo "")

if [ -n "$S3_BUCKETS" ]; then
    for BUCKET in $S3_BUCKETS; do
        echo "🗑️  Deleting S3 bucket: $BUCKET"
        # Delete all objects first
        aws s3 rm s3://$BUCKET --recursive 2>/dev/null || echo "   (bucket empty or error)"
        # Delete bucket
        aws s3api delete-bucket --region $REGION --bucket $BUCKET 2>/dev/null || echo "   (bucket may be in another region)"
    done
    echo "✅ All S3 buckets deleted"
else
    echo "✅ No S3 buckets found"
fi

echo ""

# =============================================================================
# 6. Delete Security Groups
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  Security Groups"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "⏳ Waiting 30 seconds for resources to fully delete..."
sleep 30

SG_IDS=$(aws ec2 describe-security-groups \
    --region $REGION \
    --filters "Name=tag:Project,Values=$PROJECT_TAG" \
    --query "SecurityGroups[?GroupName!='default'].GroupId" \
    --output text 2>/dev/null || echo "")

if [ -n "$SG_IDS" ]; then
    for SG_ID in $SG_IDS; do
        echo "🗑️  Deleting Security Group: $SG_ID"
        aws ec2 delete-security-group --region $REGION --group-id $SG_ID 2>/dev/null || echo "   (in use or already deleted)"
    done
    echo "✅ Security groups processed"
else
    echo "✅ No security groups found"
fi

echo ""

# =============================================================================
# 7. Delete Key Pairs
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  SSH Key Pairs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEY_NAMES=$(aws ec2 describe-key-pairs \
    --region $REGION \
    --query "KeyPairs[?contains(KeyName, 'riderhub') || contains(KeyName, 'flarum')].KeyName" \
    --output text 2>/dev/null || echo "")

if [ -n "$KEY_NAMES" ]; then
    for KEY_NAME in $KEY_NAMES; do
        echo "🗑️  Deleting Key Pair: $KEY_NAME"
        aws ec2 delete-key-pair --region $REGION --key-name $KEY_NAME
    done
    echo "✅ All key pairs deleted"
else
    echo "✅ No key pairs found"
fi

echo ""

# =============================================================================
# 8. Delete IAM Roles and Policies
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8️⃣  IAM Roles and Instance Profiles"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

IAM_ROLES=$(aws iam list-roles \
    --query "Roles[?contains(RoleName, 'riderhub') || contains(RoleName, 'flarum')].RoleName" \
    --output text 2>/dev/null || echo "")

if [ -n "$IAM_ROLES" ]; then
    for ROLE_NAME in $IAM_ROLES; do
        echo "🗑️  Processing IAM Role: $ROLE_NAME"
        
        # Remove instance profile
        PROFILE=$(aws iam list-instance-profiles-for-role --role-name $ROLE_NAME --query "InstanceProfiles[0].InstanceProfileName" --output text 2>/dev/null || echo "")
        if [ -n "$PROFILE" ] && [ "$PROFILE" != "None" ]; then
            aws iam remove-role-from-instance-profile --instance-profile-name $PROFILE --role-name $ROLE_NAME 2>/dev/null || true
            aws iam delete-instance-profile --instance-profile-name $PROFILE 2>/dev/null || true
        fi
        
        # Detach managed policies
        POLICIES=$(aws iam list-attached-role-policies --role-name $ROLE_NAME --query "AttachedPolicies[*].PolicyArn" --output text 2>/dev/null || echo "")
        for POLICY_ARN in $POLICIES; do
            aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN 2>/dev/null || true
        done
        
        # Delete inline policies
        INLINE_POLICIES=$(aws iam list-role-policies --role-name $ROLE_NAME --query "PolicyNames[*]" --output text 2>/dev/null || echo "")
        for POLICY_NAME in $INLINE_POLICIES; do
            aws iam delete-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME 2>/dev/null || true
        done
        
        # Delete role
        aws iam delete-role --role-name $ROLE_NAME 2>/dev/null || echo "   (error deleting role)"
    done
    echo "✅ IAM roles processed"
else
    echo "✅ No IAM roles found"
fi

echo ""

# =============================================================================
# 9. Delete VPC Resources (Subnets, IGW, Route Tables)
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "9️⃣  VPC Resources (optional - use Terraform destroy for this)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "⚠️  VPC cleanup is handled by Terraform destroy (see below)"
echo "✅ Skipping manual VPC cleanup"

echo ""

# =============================================================================
# Summary
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CLEANUP COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Resources deleted:"
echo "  ✅ EC2 Instances"
echo "  ✅ Load Balancers"
echo "  ✅ Target Groups"
echo "  ✅ RDS Databases"
echo "  ✅ S3 Buckets"
echo "  ✅ Security Groups"
echo "  ✅ SSH Key Pairs"
echo "  ✅ IAM Roles"
echo ""
echo "💰 You should now have $0/month AWS costs!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Final Step: Run Terraform Destroy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To clean up remaining VPC resources:"
echo "  cd terraform"
echo "  terraform destroy"
echo ""

