#!/bin/bash

# Check Directory Structure Script
# Run this in your /home/ksingh/Desktop/solarch-portfolio-docker-package-localimage-main directory

echo "🔍 Checking Directory Structure"
echo "==============================="

# Show current directory
echo "📁 Current directory: $(pwd)"
echo ""

# Show all contents
echo "📋 Directory contents:"
ls -la
echo ""

# Check for frontend directory
if [ -d "frontend" ]; then
    echo "✅ frontend/ directory found"
    echo ""
    echo "📁 Contents of frontend/:"
    ls -la frontend/
    echo ""
    
    # Check key files
    if [ -f "frontend/package.json" ]; then
        echo "✅ frontend/package.json exists"
    else
        echo "❌ frontend/package.json missing"
    fi
    
    if [ -f "frontend/yarn.lock" ]; then
        echo "✅ frontend/yarn.lock exists"
    else
        echo "❌ frontend/yarn.lock missing"
    fi
    
    if [ -d "frontend/src" ]; then
        echo "✅ frontend/src/ directory exists"
    else
        echo "❌ frontend/src/ directory missing"
    fi
    
    if [ -d "frontend/public" ]; then
        echo "✅ frontend/public/ directory exists"
    else
        echo "❌ frontend/public/ directory missing"
    fi
    
else
    echo "❌ frontend/ directory NOT FOUND"
    echo ""
    echo "🔍 Looking for package.json files anywhere:"
    find . -name "package.json" -type f 2>/dev/null || echo "No package.json files found"
    echo ""
    echo "🔍 Looking for src directories:"
    find . -name "src" -type d 2>/dev/null || echo "No src directories found"
    echo ""
    echo "🔍 Looking for any React/Node.js related files:"
    find . -name "*.json" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | head -10
fi

echo ""
echo "🔍 Checking for .dockerignore:"
if [ -f ".dockerignore" ]; then
    echo "✅ .dockerignore exists"
    echo "Contents:"
    cat .dockerignore
else
    echo "❌ .dockerignore not found"
fi

echo ""
echo "🔍 Looking for any Dockerfile:"
find . -name "Dockerfile*" -type f 2>/dev/null || echo "No Dockerfile found"

echo ""
echo "📊 Summary complete!"
echo "Run this script to see your actual directory structure,"
echo "then I can create the correct Dockerfile for your setup."