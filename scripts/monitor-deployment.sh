#!/bin/bash

# =============================================================================
# Monitor Deployment Status
# =============================================================================

echo "🚀 RiderHub Deployment Monitor"
echo "================================"
echo ""

# Check GitHub Actions status
echo "📊 GitHub Actions:"
echo "https://github.com/scale600/aws-flarum-devops/actions"
echo ""

# Wait for deployment to start
echo "⏳ Waiting for deployment to complete..."
echo ""
echo "This will take approximately 5-7 minutes."
echo ""

# Function to check EC2 status
check_site() {
    echo "🔍 Checking for EC2 instance..."
    
    # Get EC2 public IP from Terraform output
    cd "$(dirname "$0")/../terraform" || exit 1
    
    PUBLIC_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)
    
    if [ -z "$PUBLIC_IP" ]; then
        echo "❌ EC2 instance not yet deployed"
        return 1
    fi
    
    echo "✅ EC2 instance found: $PUBLIC_IP"
    echo ""
    
    # Test the site
    echo "🌐 Testing site: http://$PUBLIC_IP"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$PUBLIC_IP" --max-time 5)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Site is LIVE! HTTP $HTTP_CODE"
        echo ""
        echo "🎉 Your site is ready!"
        echo ""
        echo "Access your forum at:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "   🌐 http://$PUBLIC_IP"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📚 Architecture: All-in-One EC2 Instance"
        echo "💰 Cost: ~\$8/month (AWS Free Tier eligible)"
        echo ""
        return 0
    elif [ "$HTTP_CODE" = "503" ]; then
        echo "⏳ Site starting... HTTP $HTTP_CODE (Apache loading)"
        echo "   Wait 30 seconds and try again"
        return 1
    else
        echo "❌ Site not responding: HTTP $HTTP_CODE"
        echo "   Deployment may still be in progress"
        return 1
    fi
}

# Main monitoring loop
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for i in {1..30}; do
    if check_site; then
        exit 0
    fi
    
    if [ $i -lt 30 ]; then
        echo ""
        echo "Retry $i/30 - Checking again in 30 seconds..."
        sleep 30
    fi
done

echo ""
echo "⏰ Deployment taking longer than expected."
echo ""
echo "Please check:"
echo "1. GitHub Actions: https://github.com/scale600/aws-flarum-devops/actions"
echo "2. AWS Console EC2: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:"
echo ""

