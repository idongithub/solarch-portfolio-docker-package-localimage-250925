#!/bin/bash
# Debug script to show all Docker images and their patterns

echo "🔍 DEBUGGING DOCKER IMAGES"
echo "=========================="

echo ""
echo "📋 ALL DOCKER IMAGES:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "🎯 SEARCHING FOR PROJECT IMAGES:"

echo ""
echo "Pattern 1 - app_* images:"
docker images --filter "reference=app_*" --format "{{.Repository}}:{{.Tag}}" || echo "No app_* images found"

echo ""
echo "Pattern 2 - *portfolio* images:"
docker images --filter "reference=*portfolio*" --format "{{.Repository}}:{{.Tag}}" || echo "No portfolio images found"

echo ""
echo "Pattern 3 - *kamal* images:"
docker images --filter "reference=*kamal*" --format "{{.Repository}}:{{.Tag}}" || echo "No kamal images found"

echo ""
echo "🏗️ IMAGES BUILT BY DOCKER-COMPOSE:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^app[_-]" || echo "No docker-compose project images found"

echo ""
echo "🐋 ALL IMAGE IDs:"
docker images -q

echo ""
echo "📊 TOTAL IMAGES: $(docker images -q | wc -l)"