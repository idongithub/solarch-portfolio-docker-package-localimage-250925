#!/bin/bash
# Test script to verify image detection patterns

echo "🔍 TESTING IMAGE DETECTION PATTERNS"
echo "===================================="

echo ""
echo "📋 ALL DOCKER IMAGES:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "🎯 TESTING PATTERNS:"

echo ""
echo "Pattern 1 - solarchportfolio images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep "solarchportfolio" || echo "❌ No solarchportfolio images found"

echo ""
echo "Pattern 2 - app_ project images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep "^app_" | grep -E "(backend|frontend|portfolio)" || echo "❌ No app_ project images found"

echo ""
echo "Pattern 3 - portfolio.* images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "portfolio.*(backend|frontend|https)" || echo "❌ No portfolio.* images found"

echo ""
echo "Pattern 4 - Any portfolio images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep -i "portfolio" || echo "❌ No portfolio images found"

echo ""
echo "🔍 SPECIFIC SEARCH for your images:"
docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(solarchportfoliodockerpackagelocalimagemain|backend|frontend)" || echo "❌ No matching images found"

echo ""
echo "📊 SUMMARY:"
TOTAL_PORTFOLIO=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -i "portfolio" | wc -l)
echo "Total portfolio-related images found: $TOTAL_PORTFOLIO"