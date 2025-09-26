#!/bin/bash

# Test nginx configuration for syntax errors
echo "Testing nginx configuration syntax..."

# Test the nginx config file directly
echo "1. Testing nginx-simple.conf syntax..."
if command -v nginx &> /dev/null; then
    nginx -t -c $(pwd)/nginx-simple.conf
else
    echo "nginx not installed locally, will test inside Docker container"
fi

# If there's a running container, test inside it
if docker ps | grep -q kamal-portfolio-npm; then
    echo "2. Testing inside running container..."
    docker exec kamal-portfolio-npm nginx -t
    
    echo "3. Checking nginx processes..."
    docker exec kamal-portfolio-npm ps aux | grep nginx
    
    echo "4. Recent nginx error logs..."
    docker exec kamal-portfolio-npm tail -10 /var/log/nginx/error.log
else
    echo "2. No running container found (kamal-portfolio-npm)"
fi

echo ""
echo "Configuration check complete!"