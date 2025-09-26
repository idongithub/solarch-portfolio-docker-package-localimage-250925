#!/bin/bash

# Test minimal Docker configuration to isolate nginx issue
echo "Testing minimal Docker configuration..."

# Clean up
docker stop kamal-portfolio-minimal 2>/dev/null || true
docker rm kamal-portfolio-minimal 2>/dev/null || true
docker rmi kamal-portfolio:minimal 2>/dev/null || true

# Build minimal version
echo "Building minimal Docker image..."
docker build --no-cache -f Dockerfile.minimal-test -t kamal-portfolio:minimal .

if [ $? -ne 0 ]; then
    echo "❌ Minimal Docker build failed"
    exit 1
fi

# Start container
echo "Starting minimal container..."
docker run -d --name kamal-portfolio-minimal -p 8083:80 kamal-portfolio:minimal

if [ $? -ne 0 ]; then
    echo "❌ Failed to start minimal container"
    exit 1
fi

# Wait and test
echo "Waiting 10 seconds for container to start..."
sleep 10

echo "Testing minimal container response..."
for i in {1..3}; do
    echo "Test $i/3..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ SUCCESS: Minimal configuration works! HTTP 200"
        echo "🎉 The issue was with the complex nginx config!"
        echo ""
        echo "You can access the working portfolio at: http://localhost:8083"
        echo ""
        echo "To use this minimal config permanently:"
        echo "1. Copy nginx-minimal.conf to nginx-simple.conf"
        echo "2. Use Dockerfile.minimal-test as your main Dockerfile"
        exit 0
    elif [ "$HTTP_CODE" = "500" ]; then
        echo "❌ Still getting HTTP 500 with minimal config"
    else
        echo "⚠️  Got HTTP $HTTP_CODE, waiting..."
    fi
    
    sleep 5
done

echo "❌ Minimal container test failed"
echo "Container logs:"
echo "==============="
docker logs kamal-portfolio-minimal
echo "==============="

# Cleanup
docker stop kamal-portfolio-minimal
docker rm kamal-portfolio-minimal

exit 1