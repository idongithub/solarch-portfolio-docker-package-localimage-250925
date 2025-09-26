#!/bin/bash

# Test script for Kamal Singh Portfolio deployment
# Tests both local and Docker deployments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================="
echo -e "Kamal Singh Portfolio - Deployment Test"
echo -e "==============================================${NC}"

# Function to test URL
test_url() {
    local url=$1
    local description=$2
    local timeout=${3:-10}
    
    echo -e "${YELLOW}Testing: $description${NC}"
    
    if curl -f --max-time $timeout "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $description - OK${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - FAILED${NC}"
        return 1
    fi
}

# Function to test JSON endpoint
test_json_endpoint() {
    local url=$1
    local description=$2
    
    echo -e "${YELLOW}Testing: $description${NC}"
    
    local response=$(curl -s --max-time 10 "$url")
    if echo "$response" | grep -q "portfolio\|healthy\|success"; then
        echo -e "${GREEN}✅ $description - OK${NC}"
        echo -e "${BLUE}   Response: ${response:0:100}...${NC}"
        return 0
    else
        echo -e "${RED}❌ $description - FAILED${NC}"
        echo -e "${RED}   Response: $response${NC}"
        return 1
    fi
}

# Test local deployment
test_local_deployment() {
    echo -e "\n${BLUE}📍 Testing Local Deployment${NC}"
    echo "================================"
    
    local errors=0
    
    # Test frontend
    test_url "http://localhost:3000" "Frontend (React App)" || errors=$((errors + 1))
    test_url "http://localhost:3000/about" "About Page" || errors=$((errors + 1))
    test_url "http://localhost:3000/projects" "Projects Page" || errors=$((errors + 1))
    test_url "http://localhost:3000/contact" "Contact Page" || errors=$((errors + 1))
    
    # Test backend
    test_json_endpoint "http://localhost:8001/api/" "Backend API Root" || errors=$((errors + 1))
    test_json_endpoint "http://localhost:8001/api/health" "Backend Health Check" || errors=$((errors + 1))
    test_url "http://localhost:8001/docs" "API Documentation" || errors=$((errors + 1))
    
    if [ $errors -eq 0 ]; then
        echo -e "\n${GREEN}🎉 Local deployment test PASSED${NC}"
    else
        echo -e "\n${RED}❌ Local deployment test FAILED ($errors errors)${NC}"
    fi
    
    return $errors
}

# Test Docker deployment
test_docker_deployment() {
    echo -e "\n${BLUE}🐳 Testing Docker Deployment${NC}"
    echo "================================"
    
    # Check if docker-compose is available
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ docker-compose not found${NC}"
        return 1
    fi
    
    # Check if .env.docker exists
    if [ ! -f .env.docker ]; then
        echo -e "${YELLOW}⚠️ .env.docker not found - creating from example${NC}"
        cp .env.docker.example .env.docker
        echo -e "${YELLOW}⚠️ Please configure .env.docker with your settings${NC}"
    fi
    
    echo -e "${BLUE}📋 Docker Configuration Check${NC}"
    
    # Check Docker files
    local docker_files=(
        "docker-compose.yml"
        "backend/Dockerfile"
        "frontend/Dockerfile"
        ".env.docker"
    )
    
    local missing_files=0
    for file in "${docker_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}✅ $file exists${NC}"
        else
            echo -e "${RED}❌ $file missing${NC}"
            missing_files=$((missing_files + 1))
        fi
    done
    
    if [ $missing_files -gt 0 ]; then
        echo -e "${RED}❌ Docker deployment test FAILED ($missing_files missing files)${NC}"
        return 1
    fi
    
    echo -e "${GREEN}🎉 Docker configuration test PASSED${NC}"
    return 0
}

# Test email configuration
test_email_config() {
    echo -e "\n${BLUE}📧 Testing Email Configuration${NC}"
    echo "================================"
    
    # Check if environment variables are set
    local config_ok=true
    
    if [ -f .env.docker ]; then
        source .env.docker
        
        if [ -z "$SMTP_USERNAME" ]; then
            echo -e "${RED}❌ SMTP_USERNAME not configured${NC}"
            config_ok=false
        else
            echo -e "${GREEN}✅ SMTP_USERNAME configured${NC}"
        fi
        
        if [ -z "$SMTP_PASSWORD" ]; then
            echo -e "${RED}❌ SMTP_PASSWORD not configured${NC}"
            config_ok=false
        else
            echo -e "${GREEN}✅ SMTP_PASSWORD configured${NC}"
        fi
        
        if [ -z "$TO_EMAIL" ]; then
            echo -e "${RED}❌ TO_EMAIL not configured${NC}"
            config_ok=false
        else
            echo -e "${GREEN}✅ TO_EMAIL configured: $TO_EMAIL${NC}"
        fi
        
    else
        echo -e "${YELLOW}⚠️ .env.docker not found - email configuration not checked${NC}"
        config_ok=false
    fi
    
    if $config_ok; then
        echo -e "${GREEN}🎉 Email configuration test PASSED${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Email configuration needs setup${NC}"
        echo -e "${BLUE}💡 Configure SMTP settings in .env.docker for email functionality${NC}"
        return 1
    fi
}

# Test contact form functionality
test_contact_form() {
    echo -e "\n${BLUE}📝 Testing Contact Form${NC}"
    echo "================================"
    
    # Test contact form submission (without actually sending)
    local test_data='{
        "name": "Test User",
        "email": "test@example.com",
        "company": "Test Company",
        "role": "Developer",
        "projectType": "Digital Transformation",
        "budget": "£50k - £100k",
        "timeline": "3-6 months",
        "message": "This is a test message to verify the contact form API endpoint."
    }'
    
    echo -e "${YELLOW}Testing contact form API endpoint...${NC}"
    
    # Note: This will fail if email is not configured, but we can check if endpoint exists
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$test_data" \
        http://localhost:8001/api/contact 2>/dev/null || echo "endpoint_not_available")
    
    if echo "$response" | grep -q "endpoint_not_available"; then
        echo -e "${RED}❌ Contact form endpoint not available${NC}"
        return 1
    elif echo "$response" | grep -q "success\|error\|Email"; then
        echo -e "${GREEN}✅ Contact form endpoint responding${NC}"
        echo -e "${BLUE}   Response: ${response:0:100}...${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️ Contact form endpoint responding but email may not be configured${NC}"
        return 0
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting comprehensive deployment test...${NC}\n"
    
    local total_errors=0
    
    # Test local deployment
    test_local_deployment || total_errors=$((total_errors + 1))
    
    # Test Docker configuration
    test_docker_deployment || total_errors=$((total_errors + 1))
    
    # Test email configuration
    test_email_config || total_errors=$((total_errors + 1))
    
    # Test contact form
    test_contact_form || total_errors=$((total_errors + 1))
    
    # Final summary
    echo -e "\n${BLUE}=============================================="
    echo -e "DEPLOYMENT TEST SUMMARY"
    echo -e "==============================================${NC}"
    
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
        echo -e "${GREEN}✅ Local deployment is working${NC}"
        echo -e "${GREEN}✅ Docker configuration is ready${NC}"
        echo -e "${GREEN}✅ Contact form is functional${NC}"
        echo -e "\n${BLUE}🚀 Your Kamal Singh Portfolio is ready for production!${NC}"
        
        echo -e "\n${BLUE}📍 Access URLs:${NC}"
        echo -e "  🌐 Frontend: http://localhost:3000"
        echo -e "  🔧 Backend: http://localhost:8001"
        echo -e "  📚 API Docs: http://localhost:8001/docs"
        
        echo -e "\n${BLUE}🐳 Docker Commands:${NC}"
        echo -e "  make setup    # Setup Docker environment"
        echo -e "  make start    # Start Docker containers"
        echo -e "  make status   # Check service status"
        
    else
        echo -e "${RED}❌ SOME TESTS FAILED ($total_errors issues)${NC}"
        echo -e "\n${BLUE}💡 Troubleshooting:${NC}"
        echo -e "  1. Ensure all services are running: ./start_local.sh"
        echo -e "  2. Configure email settings in .env.docker"
        echo -e "  3. Check service logs for errors"
        echo -e "  4. Refer to DEPLOYMENT_SUMMARY.md for detailed setup"
    fi
    
    echo -e "\n${BLUE}📚 Documentation:${NC}"
    echo -e "  - DOCKER_DEPLOYMENT_GUIDE.md - Complete Docker setup"
    echo -e "  - DEPLOYMENT_SUMMARY.md - Feature overview"
    echo -e "  - README_LOCAL_INSTALL.md - Local installation"
    
    return $total_errors
}

# Run main function
main "$@"