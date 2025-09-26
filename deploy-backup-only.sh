#!/bin/bash
# Deploy only backup container - no changes to MongoDB or Mongo Express

set -e

echo "📦 BACKUP CONTAINER DEPLOYMENT ONLY"
echo "===================================="

# Set environment variables
export MONGO_PORT=37037
export MONGO_USERNAME=admin
export MONGO_PASSWORD=securepass123
export BACKUP_RETENTION_DAYS=30

echo "📋 Deploying backup container only..."
echo "  MongoDB and Mongo Express: UNTOUCHED"
echo "  Backup Retention: $BACKUP_RETENTION_DAYS days"

# Create backup directory
mkdir -p ./backups

# Deploy only backup container
docker-compose -f docker-compose.production.yml up -d backup

echo "⏳ Waiting for backup container to initialize..."
sleep 10

echo ""
echo "📊 Backup container status:"
docker ps --filter "name=portfolio-backup" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📜 Backup container logs:"
docker logs --tail 10 portfolio-backup 2>/dev/null || echo "❌ Backup container not found"

echo ""
echo "✅ Backup deployment completed!"
echo "📂 Backup location: ./backups/"
echo "🔄 Backup schedule: Daily"