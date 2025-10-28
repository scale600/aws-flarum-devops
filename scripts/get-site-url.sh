#!/bin/bash

# =============================================================================
# Get RiderHub Site URL from AWS
# Retrieves the deployed Flarum URL and other deployment details
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 Fetching RiderHub Deployment Information...${NC}\n"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${YELLOW}⚠️  AWS credentials not configured locally${NC}"
    echo ""
    echo "To get your site URL, you have two options:"
    echo ""
    echo "Option 1: Configure AWS CLI locally"
    echo "  aws configure"
    echo "  Then run this script again"
    echo ""
    echo "Option 2: Check AWS Console"
    echo "  1. Go to: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
    echo "  2. Look for load balancer named 'riderhub-flarum-alb'"
    echo "  3. Copy the 'DNS name' column"
    echo "  4. Visit: http://[DNS-NAME]"
    echo ""
    echo "Option 3: Check GitHub Actions Logs"
    echo "  https://github.com/scale600/aws-flarum-devops/actions"
    echo ""
    exit 1
fi

REGION="us-east-1"

# Get Application Load Balancer
echo -e "${BLUE}📡 Getting Application Load Balancer...${NC}"
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --region $REGION \
    --query 'LoadBalancers[?contains(LoadBalancerName, `riderhub`) || contains(LoadBalancerName, `flarum`)].DNSName' \
    --output text 2>/dev/null)

if [ -n "$ALB_DNS" ]; then
    FLARUM_URL="http://$ALB_DNS"
    echo -e "${GREEN}✓${NC} Found: $ALB_DNS"
else
    FLARUM_URL="Not found"
    echo -e "${YELLOW}⚠${NC} Load balancer not found"
fi

# Get EC2 Instance
echo -e "${BLUE}🖥️  Getting EC2 Instance...${NC}"
EC2_INFO=$(aws ec2 describe-instances \
    --region $REGION \
    --filters "Name=tag:Name,Values=riderhub-flarum,flarum-*" "Name=instance-state-name,Values=running" \
    --query 'Reservations[0].Instances[0].[InstanceId,PublicIpAddress,State.Name]' \
    --output text 2>/dev/null)

if [ -n "$EC2_INFO" ] && [ "$EC2_INFO" != "None	None	None" ]; then
    EC2_ID=$(echo "$EC2_INFO" | awk '{print $1}')
    EC2_IP=$(echo "$EC2_INFO" | awk '{print $2}')
    EC2_STATE=$(echo "$EC2_INFO" | awk '{print $3}')
    echo -e "${GREEN}✓${NC} Instance ID: $EC2_ID"
    echo -e "${GREEN}✓${NC} Public IP: $EC2_IP"
    echo -e "${GREEN}✓${NC} State: $EC2_STATE"
else
    EC2_ID="Not found"
    EC2_IP="Not found"
    EC2_STATE="Not found"
    echo -e "${YELLOW}⚠${NC} EC2 instance not found"
fi

# Get RDS Database
echo -e "${BLUE}🗄️  Getting RDS Database...${NC}"
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --region $REGION \
    --query 'DBInstances[?contains(DBInstanceIdentifier, `riderhub`) || contains(DBInstanceIdentifier, `flarum`)].Endpoint.Address' \
    --output text 2>/dev/null)

if [ -n "$RDS_ENDPOINT" ]; then
    echo -e "${GREEN}✓${NC} Found: $RDS_ENDPOINT"
else
    RDS_ENDPOINT="Not found"
    echo -e "${YELLOW}⚠${NC} RDS database not found"
fi

# Get S3 Bucket
echo -e "${BLUE}🪣 Getting S3 Bucket...${NC}"
S3_BUCKET=$(aws s3api list-buckets \
    --region $REGION \
    --query 'Buckets[?contains(Name, `riderhub`) || contains(Name, `flarum`)].Name' \
    --output text 2>/dev/null)

if [ -n "$S3_BUCKET" ]; then
    echo -e "${GREEN}✓${NC} Found: $S3_BUCKET"
else
    S3_BUCKET="Not found"
    echo -e "${YELLOW}⚠${NC} S3 bucket not found"
fi

# Display Results
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🏍️  RIDERHUB DEPLOYMENT INFORMATION 🏍️           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$FLARUM_URL" != "Not found" ]; then
    echo -e "${CYAN}🌐 Your Flarum Forum:${NC}"
    echo -e "   ${BLUE}$FLARUM_URL${NC}"
    echo ""
    echo -e "${YELLOW}⏱️  IMPORTANT: Wait 5-7 minutes for EC2 to complete Flarum installation!${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  Flarum URL not available yet${NC}"
    echo ""
fi

echo -e "${CYAN}📊 Resource Details:${NC}"
echo "   EC2 Instance ID:  $EC2_ID"
echo "   EC2 Public IP:    $EC2_IP"
echo "   EC2 State:        $EC2_STATE"
echo "   RDS Endpoint:     $RDS_ENDPOINT"
echo "   S3 Bucket:        $S3_BUCKET"
echo ""

if [ "$EC2_IP" != "Not found" ]; then
    echo -e "${CYAN}🔐 SSH Access:${NC}"
    echo "   ssh -i terraform/riderhub-flarum-key.pem ec2-user@$EC2_IP"
    echo ""
fi

echo -e "${CYAN}📝 Next Steps:${NC}"
if [ "$FLARUM_URL" != "Not found" ]; then
    echo "   1. Wait 5-7 minutes for Flarum installation"
    echo "   2. Visit: $FLARUM_URL"
    echo "   3. Complete Flarum setup wizard"
    echo "   4. Create admin account"
    echo "   5. Start using your forum!"
else
    echo "   1. Check AWS Console: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:"
    echo "   2. Look for 'riderhub-flarum-alb' or 'flarum-*-alb'"
    echo "   3. Copy DNS name and visit: http://[DNS-NAME]"
fi

echo ""

# Open in browser if available
if [ "$FLARUM_URL" != "Not found" ]; then
    read -p "Would you like to open the site in your browser now? (yes/no): " -r
    echo
    if [[ $REPLY =~ ^[Yy]es$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$FLARUM_URL"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$FLARUM_URL"
        else
            echo "Please visit: $FLARUM_URL"
        fi
    fi
fi

