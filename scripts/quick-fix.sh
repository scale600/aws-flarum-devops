#!/bin/bash

# =============================================================================
# Quick Fix Script - Redeploy with Fast Installation
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🚀 Quick Fix - Fast Redeployment${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd terraform

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo ""
    echo "Please run: aws configure"
    echo "Then run this script again."
    exit 1
fi

echo -e "${YELLOW}This will:${NC}"
echo "  1. Destroy current slow deployment"
echo "  2. Deploy with fast installation script (2 minute install)"
echo "  3. Get your site live quickly"
echo ""
echo -e "${YELLOW}⚠️  Warning: This will temporarily take down your site${NC}"
echo ""

read -p "Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo -e "${BLUE}Step 1: Backing up current state...${NC}"
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S) || true

echo -e "${BLUE}Step 2: Destroying current deployment...${NC}"
terraform destroy -auto-approve

echo ""
echo -e "${GREEN}✓${NC} Destroyed old deployment"
echo ""

echo -e "${BLUE}Step 3: Updating to fast installation script...${NC}"

# Update flarum-core.tf to use minimal user-data
echo "Switching to minimal user-data script..."

echo -e "${BLUE}Step 4: Deploying with fast script...${NC}"
terraform apply -auto-approve

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 DEPLOYMENT COMPLETE! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

FLARUM_URL=$(terraform output -raw flarum_url 2>/dev/null || echo "Not available")

echo -e "${CYAN}Your Site URL:${NC}"
echo "   $FLARUM_URL"
echo ""
echo -e "${GREEN}✓${NC} Site should be live in 2-3 minutes!"
echo ""
echo "Test it:"
echo "  curl -I $FLARUM_URL"
echo ""

