#!/bin/bash
# Deploy backup container and fix Mongo Express health check

set -e

echo "🔧 BACKUP DEPLOYMENT & HEALTH CHECK FIX"
echo "========================================"

# Set environment variables
export MONGO_PORT=37037
export MONGO_USERNAME=admin
export MONGO_PASSWORD=securepass123
export BACKUP_RETENTION_DAYS=30

echo "📋 Using Parameters:"
echo "  MongoDB Port: $MONGO_PORT"
echo "  MongoDB User: $MONGO_USERNAME"
echo "  Backup Retention: $BACKUP_RETENTION_DAYS days"

# Create backup directory
mkdir -p ./backups

# Step 1: Fix Mongo Express health check
echo ""
echo "🏥 Step 1: Fixing Mongo Express health check..."
docker-compose -f docker-compose.production.yml up -d --force-recreate mongo-express

echo "⏳ Waiting for Mongo Express to restart with new health check..."
sleep 15

# Step 2: Deploy backup container
echo ""
echo "📦 Step 2: Deploying backup container..."
docker-compose -f docker-compose.production.yml up -d backup

echo "⏳ Waiting for backup container to initialize..."
sleep 10

# Step 3: Check status
echo ""
echo "📊 Current MongoDB ecosystem status:"
docker ps --filter "name=portfolio-mongo" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 
docker ps --filter "name=portfolio-backup" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🏥 Health Check Status:"
echo "MongoDB: $(docker inspect portfolio-mongodb --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Mongo Express: $(docker inspect portfolio-mongo-express --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"

echo ""
echo "📜 Recent backup container logs:"
docker logs --tail 10 portfolio-backup 2>/dev/null || echo "❌ Backup container not found"

echo ""
echo "✅ Deployment completed!"
echo ""
echo "MongoDB Ecosystem Status:"
echo "  MongoDB:      http://localhost:$MONGO_PORT"
echo "  Mongo Express: http://localhost:3081 (admin/admin123)"
echo "  Backup:       Runs daily, retention: $BACKUP_RETENTION_DAYS days"
echo ""
echo "📂 Backup location: ./backups/"