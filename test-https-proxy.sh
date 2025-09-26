#!/bin/bash
# Test HTTPS Frontend Proxy Configuration

echo "🧪 Testing HTTPS Frontend → HTTP Backend Proxy"
echo "=================================================="

# Get the current host IP
HOST_IP=$(hostname -I | awk '{print $1}')

echo "🔍 Environment Info:"
echo "   Host IP: $HOST_IP"
echo "   HTTPS Frontend: https://$HOST_IP:3443"
echo "   HTTP Backend: http://$HOST_IP:3001"

echo ""
echo "📁 Checking nginx.conf proxy configuration..."

if grep -q "location /api/" /app/frontend/nginx.conf; then
    echo "✅ nginx proxy location configured"
else
    echo "❌ nginx proxy location NOT found"
fi

PROXY_PASS=$(grep "proxy_pass" /app/frontend/nginx.conf | head -1)
echo "🔧 Proxy pass: $PROXY_PASS"

if echo "$PROXY_PASS" | grep -q "BACKEND_URL_PLACEHOLDER"; then
    echo "⚠️  BACKEND_URL_PLACEHOLDER not replaced in nginx.conf"
    echo "🔧 Current nginx proxy configuration:"
    grep -A 10 "location /api/" /app/frontend/nginx.conf
else
    echo "✅ BACKEND_URL_PLACEHOLDER replaced in nginx.conf"
fi

echo ""
echo "🌐 Testing frontend service backend URL detection..."

# Check if frontend container is running
if docker ps | grep -q frontend-https; then
    echo "✅ HTTPS frontend container is running"
    
    # Test the nginx proxy configuration inside the container
    echo ""
    echo "📋 Testing nginx proxy inside container:"
    docker exec portfolio-frontend-https cat /etc/nginx/conf.d/default.conf | grep -A 5 "location /api"
    
    echo ""
    echo "🧪 Testing direct nginx proxy request:"
    # Test a simple request through the proxy
    curl -s -I "https://$HOST_IP:3443/api/health" -k | head -5
    
else
    echo "❌ HTTPS frontend container not running"
fi

echo ""
echo "🔍 Checking frontend environment variables:"
if docker ps | grep -q frontend-https; then
    echo "Environment variables inside frontend container:"
    docker exec portfolio-frontend-https env | grep REACT_APP || echo "No REACT_APP variables found"
else
    echo "❌ Cannot check - frontend container not running"
fi

echo ""
echo "🔧 Current backend service status:"
if docker ps | grep -q backend; then
    echo "✅ Backend container is running"
    echo "🧪 Testing direct backend request:"
    curl -s "http://$HOST_IP:3001/api/health" | head -3
else
    echo "❌ Backend container not running"
fi

echo ""
echo "📋 Summary:"
echo "   - HTTPS Frontend should proxy /api requests to HTTP backend"  
echo "   - Request flow: https://$HOST_IP:3443/api/health → http://$HOST_IP:3001/api/health"
echo "   - This avoids mixed content violations by keeping frontend requests on HTTPS"