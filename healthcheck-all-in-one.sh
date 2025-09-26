#!/bin/bash

# Health check script for All-in-One Kamal Singh Portfolio Container
# Checks all services and reports overall health

set -e

# Check MongoDB
if ! nc -z localhost 27017; then
    echo "MongoDB unhealthy"
    exit 1
fi

# Check Backend
if ! curl -f --max-time 5 http://localhost:8001/api/ > /dev/null 2>&1; then
    echo "Backend API unhealthy"
    exit 1
fi

# Check Nginx
if ! curl -f --max-time 5 http://localhost:80/health > /dev/null 2>&1; then
    echo "Nginx/Frontend unhealthy"
    exit 1
fi

echo "All services healthy"
exit 0