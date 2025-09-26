#!/bin/bash

# Quick test script to verify the Docker fix
echo "Testing Docker build fix..."

# Test that npm build still works
echo "1. Testing npm build in development..."
cd frontend
if npm run build; then
    echo "✅ npm build works"
    cd ..
else
    echo "❌ npm build failed"
    cd ..
    exit 1
fi

# Check that nginx config has correct path  
echo "2. Checking nginx configuration..."
if grep -q "/usr/share/nginx/html" nginx-simple.conf; then
    echo "✅ nginx config has correct path"
else
    echo "❌ nginx config path issue"
    exit 1
fi

# Check that main location block is clean (no nested locations)
echo "3. Checking for nginx nested location block issue..."
MAIN_LOCATION=$(grep -A 3 "location / {" nginx-simple.conf | grep -v "location / {")
if echo "$MAIN_LOCATION" | grep -q "location ="; then
    echo "❌ nginx still has nested location block issue"
    exit 1
else
    echo "✅ nginx nested location blocks fixed"
fi

# Check that Dockerfile uses correct copy destination
echo "4. Checking Dockerfile copy destination..."
if grep -q "COPY --from=build-stage /app/frontend/build /usr/share/nginx/html" Dockerfile.npm; then
    echo "✅ Dockerfile copy destination correct"
else
    echo "❌ Dockerfile copy destination issue"
    exit 1
fi

echo ""
echo "✅ All checks passed! The infinite redirect loop fix should work."
echo "Run ./build-docker-npm.sh to test the full Docker build."