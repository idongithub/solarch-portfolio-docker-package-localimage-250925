#!/bin/bash
# MongoDB and Mongo Express Deployment Script
# Deploys only MongoDB and Mongo Express with your custom parameters

set -e

echo "🚀 MONGODB & MONGO EXPRESS DEPLOYMENT"
echo "===================================="

# Set your custom parameters (same as your deploy script)
export MONGO_PORT=37037
export MONGO_USERNAME=admin
export MONGO_PASSWORD=securepass123
export MONGO_EXPRESS_PORT=3081
export MONGO_EXPRESS_USERNAME=admin
export MONGO_EXPRESS_PASSWORD=admin123

echo "📋 Using Parameters:"
echo "  MongoDB Port: $MONGO_PORT"
echo "  MongoDB User: $MONGO_USERNAME"
echo "  Mongo Express Port: $MONGO_EXPRESS_PORT"
echo "  Mongo Express User: $MONGO_EXPRESS_USERNAME"

# Create required directories
mkdir -p ./logs/mongodb ./backups/mongodb

# Step 1: Deploy MongoDB first
echo ""
echo "🗄️  Step 1: Deploying MongoDB..."
docker-compose -f docker-compose.production.yml up -d --force-recreate mongodb

# Wait for MongoDB to initialize
echo "⏳ Waiting for MongoDB to initialize (30 seconds)..."
sleep 30

# Check MongoDB status
echo "🔍 Checking MongoDB status..."
docker logs --tail 10 portfolio-mongodb

# Step 2: Deploy Mongo Express
echo ""
echo "🌐 Step 2: Deploying Mongo Express..."
docker-compose -f docker-compose.production.yml up -d --force-recreate mongo-express

# Wait for Mongo Express to connect
echo "⏳ Waiting for Mongo Express to connect (15 seconds)..."
sleep 15

# Final status check
echo ""
echo "📊 Final Status Check:"
docker ps --filter "name=portfolio-mongo" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "Access URLs:"
echo "  MongoDB:      mongodb://localhost:$MONGO_PORT"
echo "  Mongo Express: http://localhost:$MONGO_EXPRESS_PORT"
echo "  Login:        $MONGO_EXPRESS_USERNAME / $MONGO_EXPRESS_PASSWORD"
echo ""
echo "📜 Check logs if issues persist:"
echo "  docker logs portfolio-mongodb"
echo "  docker logs portfolio-mongo-express"