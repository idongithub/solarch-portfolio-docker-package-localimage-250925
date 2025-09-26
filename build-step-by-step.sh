#!/bin/bash

# Step-by-step Docker build process
# Helps identify exactly where the build fails

set -e

echo "🔧 Step-by-Step Docker Build"
echo "============================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}[STEP $1]${NC} $2"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Step 1: Test minimal frontend build
print_step "1" "Testing minimal frontend build..."
if docker build -f Dockerfile.minimal -t portfolio-frontend-test . > build-step1.log 2>&1; then
    print_success "Frontend build successful"
    
    # Test the frontend container
    print_step "1a" "Testing frontend container..."
    FRONTEND_ID=$(docker run -d -p 3001:3000 --name frontend-test portfolio-frontend-test 2>/dev/null || echo "failed")
    
    if [ "$FRONTEND_ID" != "failed" ]; then
        sleep 10
        if curl -f -s http://localhost:3001 >/dev/null 2>&1; then
            print_success "Frontend container works!"
        else
            print_error "Frontend container not responding"
            docker logs frontend-test
        fi
        docker stop frontend-test >/dev/null 2>&1 || true
        docker rm frontend-test >/dev/null 2>&1 || true
    else
        print_error "Frontend container failed to start"
        exit 1
    fi
else
    print_error "Frontend build failed"
    echo "Check build-step1.log for details"
    tail -20 build-step1.log
    exit 1
fi

# Step 2: Test backend Python setup
print_step "2" "Testing backend Python environment..."
docker run --rm -v $(pwd)/backend:/app/backend -w /app ubuntu:22.04 bash -c "
    apt-get update >/dev/null 2>&1
    apt-get install -y python3.11 python3.11-venv python3-pip build-essential >/dev/null 2>&1
    cd backend
    python3.11 -m venv venv
    venv/bin/pip install --upgrade pip setuptools wheel >/dev/null 2>&1
    venv/bin/pip install -r requirements.txt >/dev/null 2>&1
    echo 'Backend Python setup successful'
" > build-step2.log 2>&1

if [ $? -eq 0 ]; then
    print_success "Backend dependencies install successfully"
else
    print_error "Backend dependencies failed"
    echo "Check build-step2.log for details"
    exit 1
fi

# Step 3: Test simple full build (simplified)
print_step "3" "Testing simple full build..."
if docker build -f Dockerfile.simple-reliable -t portfolio-simple-test . > build-step3.log 2>&1; then
    print_success "Simple full build successful"
    
    # Test the container
    print_step "3a" "Testing full container..."
    FULL_ID=$(docker run -d -p 8081:80 --name full-test portfolio-simple-test 2>/dev/null || echo "failed")
    
    if [ "$FULL_ID" != "failed" ]; then
        print_success "Full container started"
        sleep 30
        
        if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
            print_success "✅ Full application works!"
            echo ""
            echo "🎉 SUCCESS! Your Docker build is working!"
            echo "Use: docker run -d -p 80:80 --name kamal-portfolio portfolio-simple-test"
        else
            print_error "Full application not responding"
            docker logs full-test --tail 20
        fi
        
        docker stop full-test >/dev/null 2>&1 || true
        docker rm full-test >/dev/null 2>&1 || true
    else
        print_error "Full container failed to start"
        exit 1
    fi
else
    print_error "Simple full build failed"
    echo "Check build-step3.log for details"
    tail -30 build-step3.log
    exit 1
fi

print_success "All steps completed successfully!"
echo ""
echo "✅ Working Docker image: portfolio-simple-test"
echo "To run: docker run -d -p 80:80 --name kamal-portfolio portfolio-simple-test"