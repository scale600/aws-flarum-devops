#!/bin/bash

# =============================================================================
# RiderHub Project Validation Script
# =============================================================================
# This script validates your development environment and project setup
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Print functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Version comparison
version_ge() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Main validation
main() {
    print_header "RiderHub Project Validation"
    
    # ==========================================================================
    # Check Required Tools
    # ==========================================================================
    print_header "Required Tools"
    
    # Terraform
    if command_exists terraform; then
        TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
        if version_ge "$TERRAFORM_VERSION" "1.5.0"; then
            print_success "Terraform ${TERRAFORM_VERSION} (>= 1.5.0)"
        else
            print_error "Terraform ${TERRAFORM_VERSION} found, but >= 1.5.0 required"
        fi
    else
        print_error "Terraform not found (required >= 1.5.0)"
    fi
    
    # AWS CLI
    if command_exists aws; then
        AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
        print_success "AWS CLI ${AWS_VERSION}"
    else
        print_error "AWS CLI not found"
    fi
    
    # Docker
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
        print_success "Docker ${DOCKER_VERSION}"
    else
        print_warning "Docker not found (optional for local development)"
    fi
    
    # PHP
    if command_exists php; then
        PHP_VERSION=$(php -v | head -n 1 | cut -d' ' -f2)
        if [[ "$PHP_VERSION" =~ ^8\.[1-9] ]]; then
            print_success "PHP ${PHP_VERSION}"
        else
            print_warning "PHP ${PHP_VERSION} found, but 8.1+ recommended"
        fi
    else
        print_warning "PHP not found (optional for local development)"
    fi
    
    # Composer
    if command_exists composer; then
        COMPOSER_VERSION=$(composer --version 2>/dev/null | cut -d' ' -f3)
        print_success "Composer ${COMPOSER_VERSION}"
    else
        print_warning "Composer not found (optional for local development)"
    fi
    
    # Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version | tr -d 'v')
        if version_ge "$NODE_VERSION" "18.0.0"; then
            print_success "Node.js ${NODE_VERSION} (>= 18.0.0)"
        else
            print_warning "Node.js ${NODE_VERSION} found, but >= 18.0.0 recommended"
        fi
    else
        print_warning "Node.js not found (required for frontend development)"
    fi
    
    # npm
    if command_exists npm; then
        NPM_VERSION=$(npm --version)
        print_success "npm ${NPM_VERSION}"
    else
        print_warning "npm not found (required for frontend development)"
    fi
    
    # ==========================================================================
    # Check AWS Configuration
    # ==========================================================================
    print_header "AWS Configuration"
    
    if aws sts get-caller-identity &>/dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        CURRENT_REGION=$(aws configure get region)
        print_success "AWS credentials configured (Account: ${ACCOUNT_ID})"
        print_info "Current region: ${CURRENT_REGION}"
    else
        print_error "AWS credentials not configured or invalid"
        print_info "Run 'aws configure' to set up credentials"
    fi
    
    # ==========================================================================
    # Check Project Structure
    # ==========================================================================
    print_header "Project Structure"
    
    # Required directories
    for dir in terraform src/flarum frontend docker ansible scripts; do
        if [ -d "$dir" ]; then
            print_success "Directory: $dir"
        else
            print_error "Missing directory: $dir"
        fi
    done
    
    # Required files
    declare -a files=(
        "terraform/main.tf"
        "terraform/flarum-core.tf"
        "terraform/flarum-clean.tf"
        "src/flarum/lambda.php"
        "src/flarum/composer.json"
        "docker/flarum/Dockerfile"
        "frontend/package.json"
        ".env.example"
        "README.md"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            print_success "File: $file"
        else
            print_error "Missing file: $file"
        fi
    done
    
    # ==========================================================================
    # Check Terraform Configuration
    # ==========================================================================
    print_header "Terraform Configuration"
    
    cd terraform
    
    # Format check
    if terraform fmt -check -recursive &>/dev/null; then
        print_success "Terraform files properly formatted"
    else
        print_warning "Terraform files need formatting (run 'terraform fmt')"
    fi
    
    # Init check
    if [ -d ".terraform" ]; then
        print_success "Terraform initialized"
    else
        print_warning "Terraform not initialized (run 'terraform init')"
    fi
    
    cd ..
    
    # ==========================================================================
    # Check Environment Configuration
    # ==========================================================================
    print_header "Environment Configuration"
    
    if [ -f ".env.example" ]; then
        print_success ".env.example file exists"
        
        if [ -f ".env" ]; then
            print_warning ".env file found (should be in .gitignore)"
        else
            print_info "No .env file (copy from .env.example if needed)"
        fi
    else
        print_error ".env.example file missing"
    fi
    
    # ==========================================================================
    # Check Git Status
    # ==========================================================================
    print_header "Git Status"
    
    if [ -d ".git" ]; then
        print_success "Git repository initialized"
        
        BRANCH=$(git branch --show-current)
        print_info "Current branch: ${BRANCH}"
        
        REMOTE=$(git remote -v | head -n 1 | awk '{print $2}')
        if [ -n "$REMOTE" ]; then
            print_success "Remote configured: ${REMOTE}"
        else
            print_warning "No remote configured"
        fi
    else
        print_error "Not a git repository"
    fi
    
    # ==========================================================================
    # Check Frontend Dependencies
    # ==========================================================================
    print_header "Frontend Dependencies"
    
    cd frontend
    
    if [ -f "package.json" ]; then
        print_success "package.json found"
        
        if [ -d "node_modules" ]; then
            print_success "Node modules installed"
        else
            print_warning "Node modules not installed (run 'npm install')"
        fi
    else
        print_error "package.json missing"
    fi
    
    cd ..
    
    # ==========================================================================
    # Check Backend Dependencies
    # ==========================================================================
    print_header "Backend Dependencies"
    
    cd src/flarum
    
    if [ -f "composer.json" ]; then
        print_success "composer.json found"
        
        if [ -d "vendor" ]; then
            print_success "Composer dependencies installed"
        else
            print_warning "Composer dependencies not installed (run 'composer install')"
        fi
    else
        print_error "composer.json missing"
    fi
    
    cd ../..
    
    # ==========================================================================
    # Summary
    # ==========================================================================
    print_header "Validation Summary"
    
    echo -e "${GREEN}Passed:   ${PASSED}${NC}"
    echo -e "${YELLOW}Warnings: ${WARNINGS}${NC}"
    echo -e "${RED}Failed:   ${FAILED}${NC}"
    
    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ Project validation completed successfully!${NC}"
        echo -e "${GREEN}You're ready to deploy RiderHub!${NC}\n"
        exit 0
    else
        echo -e "\n${RED}✗ Project validation found ${FAILED} issue(s).${NC}"
        echo -e "${RED}Please fix the errors before deploying.${NC}\n"
        exit 1
    fi
}

# Run main function
main

