# 🐋 Docker Image Management Guide - Efficient Development Workflow

## **THE PROBLEM YOU DESCRIBED** 
During development cycles, `docker-compose down` only removes containers but keeps images, making it slow to update images with new changes.

## **✅ SOLUTION 1: Enhanced Stop Script** (RECOMMENDED)

I've created `/app/stop-and-cleanup.sh` for you:

### **Basic Usage:**
```bash
# Stop containers and remove project images (keeps volumes/data on host)
./stop-and-cleanup.sh

# Stop containers, remove images AND volumes (⚠️ deletes database data)
./stop-and-cleanup.sh --remove-volumes

# Stop containers and remove ALL Docker images (nuclear option)
./stop-and-cleanup.sh --remove-all-images

# Preview what would be removed without actually removing
./stop-and-cleanup.sh --safe-mode
```

### **What it does:**
- ✅ Stops all containers
- ✅ Removes containers and networks  
- ✅ Removes project-specific images (portfolio-*, app-*)
- ✅ **🆕 MongoDB WiredTiger conflict detection** - automatically detects and offers to fix version conflicts
- ✅ **🆕 Smart image detection** - finds portfolio images with various naming patterns
- ✅ Cleans up dangling images and build cache
- ✅ Shows current Docker status after cleanup
- ✅ Optionally removes volumes (with confirmation)
- ✅ **🆕 Safe mode** - preview removals without executing

## **✅ SOLUTION 2: Enhanced Deploy Script with Force Rebuild**

I've enhanced your `deploy-with-params.sh` script:

### **New Option Added:**
```bash
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --backend-port 3001 \
  [... all your other parameters ...] \
  --force-rebuild    # 🔨 NEW: Forces rebuild of all images
```

### **What --force-rebuild does:**
- ✅ Ignores Docker build cache
- ✅ Forces recreation of all containers
- ✅ Rebuilds all images with latest changes
- ✅ Uses Docker Compose flags: `--build --force-recreate --no-deps`
- ✅ **🆕 Pre-emptive WiredTiger cleanup** - removes problematic MongoDB images before rebuild

## **✅ SOLUTION 3: Manual Docker Compose Commands**

If you prefer manual control:

### **Stop and remove images:**
```bash
# Stop containers and remove project images
docker-compose -f docker-compose.production.yml down
docker images | grep "portfolio-\|app-" | awk '{print $3}' | xargs docker rmi -f

# Force rebuild on next deploy
docker-compose -f docker-compose.production.yml up -d --build --force-recreate
```

### **Nuclear option (removes everything):**
```bash
# Stop everything and remove all images
docker-compose -f docker-compose.production.yml down --volumes
docker system prune -a -f
```

## **🚀 RECOMMENDED DEVELOPMENT WORKFLOW**

### **For Daily Development:**
```bash
# Use the enhanced cleanup script (data persists on host)
./stop-and-cleanup.sh

# Deploy with your exact parameters (example)
./scripts/deploy-with-params.sh \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk --smtp-use-tls true \
  --ga-measurement-id G-B2W705K4SN --mongo-express-port 3081 \
  --mongo-express-username admin --mongo-express-password admin123 \
  --mongo-port 37037 --mongo-username admin --mongo-password securepass123 \
  --grafana-password adminpass123 --redis-password redispass123 \
  --grafana-port 3030 --loki-port 3300 --prometheus-port 3091 \
  --skip-backup
```

### **🆕 For WiredTiger Conflicts:**
```bash
# Script automatically detects and offers to fix WiredTiger conflicts
./stop-and-cleanup.sh
# If WiredTiger conflict detected, script will ask:
# "Remove MongoDB volumes to fix WiredTiger conflict? (y/N)"

# Or force volume removal if you know there's a conflict
./stop-and-cleanup.sh --remove-volumes
```

### **For Major Changes or Fresh Start:**
```bash
# 1. Stop and remove everything including volumes
./stop-and-cleanup.sh --remove-volumes

# 2. Force rebuild everything
./scripts/deploy-with-params.sh \
  [... your parameters ...] \
  --force-rebuild
```

### **For Quick Image Updates:**
```bash
# Just force rebuild without stopping (if containers are running)
./scripts/deploy-with-params.sh \
  [... your parameters ...] \
  --force-rebuild
```

## **⚡ PERFORMANCE OPTIMIZATION**

### **Docker Build Cache Behavior:**
- **Without changes**: Docker reuses cached layers (fast)
- **With code changes**: Docker rebuilds only changed layers (medium speed)
- **With --force-rebuild**: Docker rebuilds everything (slower but ensures fresh build)

### **When to use each option:**
- **Normal deployment**: Just run deploy script (Docker auto-detects changes)
- **Stuck with cache issues**: Use `--force-rebuild`
- **Fresh start needed**: Use `./stop-and-cleanup.sh --remove-volumes` then deploy
- **WiredTiger conflicts**: Use `./stop-and-cleanup.sh` (auto-detects and offers fix)
- **Preview changes**: Use `./stop-and-cleanup.sh --safe-mode`
- **Fast development**: Use `--skip-backup` during deployment
- **Debugging**: Use `./stop-and-cleanup.sh --remove-all-images` (nuclear option)

## **💡 BEST PRACTICES**

1. **Regular Development**: Use the basic `./stop-and-cleanup.sh` script
2. **Major Updates**: Use `--force-rebuild` option
3. **Database Testing**: Use `--remove-volumes` when you need fresh database
4. **WiredTiger Issues**: Let script auto-detect and fix conflicts
5. **Fast Development**: Use `--skip-backup` for quicker deployments
6. **Preview Mode**: Use `--safe-mode` to see what would be removed
7. **Disk Space**: Regularly clean up with `docker system prune -f`
8. **Production**: Never use `--remove-volumes` in production!

## **📊 SCRIPT COMPARISON**

| Method | Speed | Use Case | Database Data | Warnings | WiredTiger Fix |
|--------|-------|----------|---------------|----------|----------------|
| `docker-compose down` | Fast | Stop only | Preserved | ⚠️ Shows env warnings | ❌ |
| `docker-compose down --env-file .env.cleanup` | Fast | Stop only | Preserved | ✅ No warnings | ❌ |
| `./stop-and-cleanup.sh` | Medium | Development | Preserved | ✅ No warnings (fixed) | ✅ Auto-detects |
| `./stop-and-cleanup.sh --remove-volumes` | Medium | Fresh start | **DELETED** | ✅ No warnings (fixed) | ✅ Full cleanup |
| `./stop-and-cleanup.sh --safe-mode` | Fast | Preview only | Preserved | ✅ No warnings | ✅ Shows what would fix |
| `--force-rebuild` | Slower | Force updates | Preserved | ✅ No warnings | ✅ Pre-emptive cleanup |
| `--skip-backup` | Faster | Development | Preserved | ✅ No warnings | ❌ |
| `--remove-all-images` | Slowest | Nuclear option | Preserved | ✅ No warnings | ✅ Full cleanup |

Your development cycle is now **optimized for efficiency**! 🎉

---

## 🆕 **Recent Enhancements**

### **✅ MongoDB WiredTiger Conflict Resolution**
- **Automatic Detection**: Script detects "unsupported WiredTiger file version" errors
- **Smart Cleanup**: Offers to remove incompatible MongoDB volumes
- **Data Safety**: Preserves other application data during cleanup
- **AVX Compatibility**: Deployment uses MongoDB 4.4 for older hardware

### **✅ Enhanced Stop Script Features**
- **Smart Image Detection**: Finds portfolio images with various naming patterns
- **Safe Mode**: Preview what would be removed without actually removing
- **Comprehensive Cleanup**: Handles all portfolio-related containers and images
- **No False Warnings**: Eliminates environment variable warnings

### **✅ Deployment Optimizations**
- **Skip Backup Option**: `--skip-backup` for faster development deployments
- **Force Rebuild**: `--force-rebuild` with pre-emptive MongoDB cleanup
- **Host Volume Persistence**: All data now safely stored on host filesystem
- **Fixed Monitoring**: No more "down" targets in Prometheus

### **✅ Development Workflow Improvements**
- **Data Persistence**: Database, Grafana dashboards, and logs survive container recreation
- **Conflict Resolution**: Automatic handling of MongoDB version conflicts
- **Preview Mode**: See what would be changed before executing
- **Faster Cycles**: Skip unnecessary services during development