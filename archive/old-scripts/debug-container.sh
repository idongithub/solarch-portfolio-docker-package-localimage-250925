#!/bin/bash

# Debug script to examine running container
CONTAINER_NAME=${1:-kamal-portfolio-npm}

echo "Debugging container: $CONTAINER_NAME"
echo "=================================="

if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "❌ Container $CONTAINER_NAME is not running"
    echo "Available containers:"
    docker ps
    exit 1
fi

echo "1. Container status:"
docker ps | grep $CONTAINER_NAME

echo ""
echo "2. Nginx configuration test:"
docker exec $CONTAINER_NAME nginx -t

echo ""
echo "3. Files in /usr/share/nginx/html:"
docker exec $CONTAINER_NAME ls -la /usr/share/nginx/html/

echo ""
echo "4. Check if index.html exists:"
docker exec $CONTAINER_NAME test -f /usr/share/nginx/html/index.html && echo "✅ index.html exists" || echo "❌ index.html missing"

echo ""
echo "5. Nginx configuration in container:"
echo "--- /etc/nginx/conf.d/default.conf ---"
docker exec $CONTAINER_NAME cat /etc/nginx/conf.d/default.conf

echo ""
echo "6. Recent nginx error logs:"
docker exec $CONTAINER_NAME tail -10 /var/log/nginx/error.log

echo ""
echo "7. Test internal curl:"
docker exec $CONTAINER_NAME curl -s -I http://localhost:80/ || echo "Internal curl failed"