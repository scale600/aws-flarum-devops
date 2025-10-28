#!/bin/bash

# =============================================================================
# RiderHub Quick Deployment Script
# Automated deployment to AWS
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}  🚀 $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Main deployment function
main() {
    print_header "RiderHub Deployment to AWS"
    
    # ==========================================================================
    # Step 1: Pre-flight Checks
    # ==========================================================================
    print_header "Step 1: Pre-flight Checks"
    
    print_step "Checking required tools..."
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Please install it first."
        exit 1
    fi
    print_success "AWS CLI found"
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found. Please install it first."
        exit 1
    fi
    print_success "Terraform found"
    
    print_step "Checking AWS credentials..."
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Run 'aws configure' first."
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region)
    print_success "AWS credentials verified"
    print_info "Account ID: $ACCOUNT_ID"
    print_info "Region: $REGION"
    
    # ==========================================================================
    # Step 2: Confirmation
    # ==========================================================================
    print_header "Step 2: Deployment Confirmation"
    
    echo -e "${YELLOW}This will deploy the following resources to AWS:${NC}"
    echo "  • EC2 t3.micro instance (Flarum application)"
    echo "  • RDS MySQL database (db.t3.micro, 20GB)"
    echo "  • Application Load Balancer"
    echo "  • S3 bucket for file storage"
    echo "  • VPC subnets and security groups"
    echo "  • IAM roles and policies"
    echo ""
    echo -e "${GREEN}Estimated cost: \$0/month (within AWS Free Tier)${NC}"
    echo -e "${YELLOW}Deployment time: ~10-15 minutes${NC}"
    echo ""
    
    read -p "Do you want to proceed? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_warning "Deployment cancelled"
        exit 0
    fi
    
    # ==========================================================================
    # Step 3: Terraform Initialization
    # ==========================================================================
    print_header "Step 3: Initializing Terraform"
    
    cd terraform
    
    print_step "Running terraform init..."
    if terraform init; then
        print_success "Terraform initialized successfully"
    else
        print_error "Terraform initialization failed"
        exit 1
    fi
    
    # ==========================================================================
    # Step 4: Terraform Plan
    # ==========================================================================
    print_header "Step 4: Creating Deployment Plan"
    
    print_step "Running terraform plan..."
    if terraform plan -out=tfplan; then
        print_success "Deployment plan created"
    else
        print_error "Failed to create deployment plan"
        exit 1
    fi
    
    echo ""
    read -p "Review the plan above. Continue with deployment? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_warning "Deployment cancelled"
        rm -f tfplan
        exit 0
    fi
    
    # ==========================================================================
    # Step 5: Deploy Infrastructure
    # ==========================================================================
    print_header "Step 5: Deploying Infrastructure"
    
    print_step "Deploying with terraform apply..."
    print_info "This will take 8-12 minutes. Please wait..."
    
    if terraform apply tfplan; then
        print_success "Infrastructure deployed successfully!"
    else
        print_error "Deployment failed"
        rm -f tfplan
        exit 1
    fi
    
    rm -f tfplan
    
    # ==========================================================================
    # Step 6: Get Deployment Information
    # ==========================================================================
    print_header "Step 6: Deployment Complete!"
    
    FLARUM_URL=$(terraform output -raw flarum_url 2>/dev/null || echo "Not available")
    EC2_IP=$(terraform output -raw ec2_instance_public_ip 2>/dev/null || echo "Not available")
    RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null || echo "Not available")
    S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "Not available")
    SSH_KEY="terraform/riderhub-flarum-key.pem"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   🎉 DEPLOYMENT SUCCESSFUL! 🎉             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📍 Your Flarum Forum:${NC}"
    echo -e "   ${BLUE}$FLARUM_URL${NC}"
    echo ""
    echo -e "${YELLOW}⏱️  IMPORTANT: Wait 5-7 minutes for EC2 to complete setup!${NC}"
    echo ""
    echo -e "${CYAN}📊 Resource Details:${NC}"
    echo "   EC2 Public IP:  $EC2_IP"
    echo "   RDS Endpoint:   ${RDS_ENDPOINT:0:50}..."
    echo "   S3 Bucket:      $S3_BUCKET"
    echo "   SSH Key:        $SSH_KEY"
    echo ""
    echo -e "${CYAN}🔐 SSH Access:${NC}"
    echo "   ssh -i $SSH_KEY ec2-user@$EC2_IP"
    echo ""
    echo -e "${CYAN}📝 Next Steps:${NC}"
    echo "   1. Wait 5-7 minutes for Flarum installation"
    echo "   2. Visit: $FLARUM_URL"
    echo "   3. Complete Flarum setup wizard"
    echo "   4. Create admin account"
    echo "   5. Start using your forum!"
    echo ""
    echo -e "${CYAN}🔍 Check Status:${NC}"
    echo "   ssh -i $SSH_KEY ec2-user@$EC2_IP"
    echo "   sudo tail -f /var/log/flarum-install.log"
    echo ""
    echo -e "${CYAN}📚 Documentation:${NC}"
    echo "   See DEPLOY.md for detailed instructions"
    echo "   See DEPLOYMENT_GUIDE.md for troubleshooting"
    echo ""
    
    # ==========================================================================
    # Step 7: Wait and Test
    # ==========================================================================
    print_header "Step 7: Waiting for EC2 Initialization"
    
    print_info "EC2 instance is installing and configuring Flarum..."
    print_info "This process takes approximately 5-7 minutes"
    echo ""
    
    read -p "Would you like to wait and auto-test the site? (yes/no): " -r
    echo
    if [[ $REPLY =~ ^[Yy]es$ ]]; then
        print_step "Waiting for 7 minutes..."
        
        # Countdown timer
        for i in {420..1}; do
            printf "\rTime remaining: %d seconds " $i
            sleep 1
        done
        echo ""
        
        print_step "Testing site availability..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FLARUM_URL" || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            print_success "Site is responding! HTTP $HTTP_CODE"
            print_success "Opening in browser..."
            
            # Open in default browser based on OS
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open "$FLARUM_URL"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                xdg-open "$FLARUM_URL"
            else
                print_info "Please visit: $FLARUM_URL"
            fi
        else
            print_warning "Site not ready yet (HTTP $HTTP_CODE)"
            print_info "Please wait a few more minutes and visit: $FLARUM_URL"
        fi
    fi
    
    echo ""
    print_header "🏍️  Happy Riding with RiderHub! 🏍️"
    
    cd ..
}

# Run main function
main

