#!/bin/bash

# Test script to verify the nginx infinite redirect fix works in Docker
echo "Testing Docker container fix..."

# Clean up any existing container
docker stop kamal-portfolio-test 2>/dev/null || true
docker rm kamal-portfolio-test 2>/dev/null || true

# Build with no cache to ensure latest nginx config
echo "Building fresh Docker image..."
docker build --no-cache -f Dockerfile.npm -t kamal-portfolio:test .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed"
    exit 1
fi

# Start container
echo "Starting test container..."
docker run -d --name kamal-portfolio-test -p 8081:80 kamal-portfolio:test

if [ $? -ne 0 ]; then
    echo "❌ Failed to start container"
    exit 1
fi

# Wait for container to initialize
echo "Waiting 15 seconds for container to start..."
sleep 15

# Test container response
echo "Testing container response..."
for i in {1..5}; do
    echo "Test attempt $i/5..."
    
    # Test with curl
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ SUCCESS: Container responding with HTTP 200"
        echo "🎉 Nginx infinite redirect loop is FIXED!"
        
        # Cleanup
        docker stop kamal-portfolio-test
        docker rm kamal-portfolio-test
        
        echo ""
        echo "The fix is verified! You can now run:"
        echo "./build-docker-npm.sh"
        echo "And access your portfolio at http://localhost:8080"
        exit 0
    elif [ "$HTTP_CODE" = "500" ]; then
        echo "❌ Still getting HTTP 500 - infinite redirect loop not fixed"
    else
        echo "⚠️  Got HTTP $HTTP_CODE, waiting..."
    fi
    
    sleep 3
done

echo "❌ Container not responding properly after 5 attempts"
echo "Checking container logs:"
echo "========================"
docker logs kamal-portfolio-test
echo "========================"

# Cleanup
docker stop kamal-portfolio-test
docker rm kamal-portfolio-test

exit 1