#!/bin/bash
# Verify MongoDB cleanup was successful

echo "🔍 MONGODB CLEANUP VERIFICATION"
echo "==============================="

echo ""
echo "📋 Current containers:"
docker ps -a | grep -E "(mongodb|mongo-express)" || echo "✅ No MongoDB containers found"

echo ""
echo "📦 Current volumes:"
docker volume ls | grep -i mongo || echo "✅ No MongoDB volumes found"

echo ""
echo "🖼️  Current images:"
docker images | grep -E "(mongo)" || echo "✅ No MongoDB images found"

echo ""
echo "🌐 Networks:"
docker network ls | grep portfolio || echo "Network still exists (this is OK)"

echo ""
if [ "$(docker volume ls -q | grep -i mongo)" ]; then
    echo "❌ MONGODB VOLUMES STILL EXIST!"
    echo "Run: docker volume rm -f \$(docker volume ls -q | grep -i mongo)"
    exit 1
else
    echo "✅ CLEANUP SUCCESSFUL - Ready for fresh deployment!"
fi