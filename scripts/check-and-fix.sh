#!/bin/bash

# =============================================================================
# Check and Fix AWS Infrastructure
# =============================================================================

echo "🔍 Checking AWS Infrastructure Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")/../terraform" || exit 1

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured locally"
    echo ""
    echo "Options:"
    echo "1. Check GitHub Actions deployment: https://github.com/scale600/aws-flarum-devops/actions"
    echo "2. Or configure AWS CLI: aws configure"
    echo ""
    exit 1
fi

echo "✅ AWS credentials configured"
echo ""

# Check for EC2 instances
echo "🔍 Checking for EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances \
    --region us-east-1 \
    --filters "Name=tag:Project,Values=RiderHub" \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" \
    --output text 2>/dev/null)

if [ -z "$INSTANCE_IDS" ]; then
    echo "❌ No EC2 instances found"
    echo ""
    echo "The infrastructure needs to be deployed."
    echo ""
    read -p "Would you like to deploy now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "🚀 Deploying infrastructure..."
        terraform init
        terraform plan -out=tfplan
        echo ""
        read -p "Apply these changes? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply tfplan
            rm -f tfplan
            echo ""
            echo "✅ Deployment complete!"
            echo ""
            # Get the new IP
            NEW_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
            if [ -n "$NEW_IP" ]; then
                echo "🌐 Your site: http://$NEW_IP"
                echo ""
                echo "⏳ Waiting for site to come online (may take 2-3 minutes)..."
                sleep 30
                curl -I "http://$NEW_IP" --max-time 5
            fi
        fi
    fi
    exit 0
fi

echo "Found EC2 instance(s):"
echo "$INSTANCE_IDS"
echo ""

# Parse the instance details
INSTANCE_ID=$(echo "$INSTANCE_IDS" | awk '{print $1}' | head -1)
INSTANCE_STATE=$(echo "$INSTANCE_IDS" | awk '{print $2}' | head -1)
INSTANCE_IP=$(echo "$INSTANCE_IDS" | awk '{print $3}' | head -1)

echo "Instance ID: $INSTANCE_ID"
echo "State: $INSTANCE_STATE"
echo "Public IP: $INSTANCE_IP"
echo ""

# Handle different states
case "$INSTANCE_STATE" in
    "running")
        echo "✅ Instance is running!"
        echo ""
        if [ "$INSTANCE_IP" != "None" ] && [ -n "$INSTANCE_IP" ]; then
            echo "🌐 Testing site: http://$INSTANCE_IP"
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$INSTANCE_IP" --max-time 5)
            if [ "$HTTP_CODE" = "200" ]; then
                echo "✅ Site is LIVE! HTTP $HTTP_CODE"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "   🎉 Your site is ready!"
                echo ""
                echo "   🌐 http://$INSTANCE_IP"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
            else
                echo "⏳ Site not responding yet (HTTP $HTTP_CODE)"
                echo "   Flarum installation may still be in progress"
                echo "   Try again in 1-2 minutes"
            fi
        fi
        ;;
    "stopped")
        echo "⚠️  Instance is STOPPED"
        echo ""
        read -p "Would you like to START it? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 Starting instance..."
            aws ec2 start-instances --region us-east-1 --instance-ids "$INSTANCE_ID"
            echo ""
            echo "⏳ Waiting for instance to start (30 seconds)..."
            sleep 30
            # Get new IP
            NEW_IP=$(aws ec2 describe-instances \
                --region us-east-1 \
                --instance-ids "$INSTANCE_ID" \
                --query "Reservations[0].Instances[0].PublicIpAddress" \
                --output text)
            echo ""
            echo "✅ Instance started!"
            echo "🌐 Your site: http://$NEW_IP"
        fi
        ;;
    "stopping"|"pending")
        echo "⏳ Instance is $INSTANCE_STATE"
        echo "   Wait a moment and run this script again"
        ;;
    "terminated"|"terminating")
        echo "❌ Instance is being terminated or already terminated"
        echo ""
        echo "You need to deploy a new instance."
        echo ""
        read -p "Deploy new infrastructure? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 Deploying new infrastructure..."
            terraform init
            terraform plan -out=tfplan
            echo ""
            read -p "Apply these changes? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                terraform apply tfplan
                rm -f tfplan
                echo ""
                echo "✅ Deployment complete!"
                NEW_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
                if [ -n "$NEW_IP" ]; then
                    echo "🌐 Your site: http://$NEW_IP"
                fi
            fi
        fi
        ;;
esac

echo ""

