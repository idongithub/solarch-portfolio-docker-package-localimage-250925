# Container Restart Issues Fix

## Issues Identified

### 1. **Backend Container Restarting (CRITICAL FIX APPLIED)**

**Problem**: Backend failing to start due to PATH issue
**Root Cause**: Python packages installed to `/root/.local/bin` but container runs as `appuser`

**Fix Applied**:
```dockerfile
# Before (Problematic)
COPY --from=build-stage /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
USER appuser  # Can't access /root/.local/bin

# After (Fixed)
COPY --from=build-stage /root/.local /opt/python-packages
RUN chown -R appuser:appuser /opt/python-packages
ENV PATH=/opt/python-packages/bin:$PATH
USER appuser  # Can access /opt/python-packages/bin
```

### 2. **HTTPS Container Issues**

**Expected HTTPS URL**: https://localhost:8443 (or custom port)
**Current Status**: Missing from access URLs

**Potential Issues**:
- SSL certificate generation failing
- Nginx HTTPS configuration errors
- Port mapping conflicts

### 3. **MongoDB Container Issues**

**Potential Issues**:
- Authentication configuration mismatch
- Volume mounting permissions
- Memory/resource constraints

## Troubleshooting Commands

### Check Container Status
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Check Container Logs
```bash
# Backend logs
docker logs portfolio-backend

# HTTPS frontend logs  
docker logs portfolio-frontend-https

# MongoDB logs
docker logs portfolio-mongodb

# All container logs
docker-compose -f docker-compose.production.yml logs
```

### Check Specific Issues

#### Backend Container
```bash
# Check if uvicorn is accessible
docker exec portfolio-backend which uvicorn

# Check PATH
docker exec portfolio-backend echo $PATH

# Check Python packages
docker exec portfolio-backend ls -la /opt/python-packages/bin/

# Manual start test
docker exec portfolio-backend /opt/python-packages/bin/uvicorn server:app --host 0.0.0.0 --port 8001
```

#### HTTPS Container
```bash
# Check SSL certificates
docker exec portfolio-frontend-https ls -la /etc/nginx/ssl/

# Check nginx configuration
docker exec portfolio-frontend-https nginx -t

# Check nginx processes
docker exec portfolio-frontend-https ps aux | grep nginx
```

#### MongoDB Container
```bash
# Check MongoDB status
docker exec portfolio-mongodb mongosh --eval "db.adminCommand('ping')"

# Check MongoDB logs
docker logs portfolio-mongodb 2>&1 | tail -20
```

## Expected Fix Results

### After PATH Fix:
✅ **Backend container** should start successfully  
✅ **API endpoints** should be accessible at http://localhost:3001/docs  
✅ **uvicorn** command should be found in PATH  

### Container Health Status:
```bash
# All containers should show as healthy
portfolio-frontend-http    Up (healthy)
portfolio-frontend-https   Up (healthy)  
portfolio-backend          Up (healthy)
portfolio-mongodb          Up (healthy)
```

### Complete Access URLs:
```
Portfolio HTTP:   http://localhost:3400
Portfolio HTTPS:  https://localhost:8443  # Should appear after HTTPS fix
Backend API:      http://localhost:3001/docs
Grafana:          http://localhost:3030
Prometheus:       http://localhost:3091
```

## Next Steps

### 1. Restart Deployment
```bash
# Stop current deployment
docker-compose -f docker-compose.production.yml down

# Rebuild with fixes
./scripts/deploy-with-params.sh \
  --mongo-password securepass123 --grafana-password admin123 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true --smtp-port 465
```

### 2. Monitor Container Status
```bash
# Watch container status
watch docker ps

# Follow logs in real-time
docker-compose -f docker-compose.production.yml logs -f
```

### 3. Test Services
```bash
# Test backend API
curl http://localhost:3001/api/health

# Test frontend HTTP
curl http://localhost:3400/

# Test frontend HTTPS (after fix)
curl -k https://localhost:8443/
```

## Warning Analysis

The PATH warnings during build were indicators of this issue:
```
WARNING: The script uvicorn is installed in '/root/.local/bin' which is not on PATH.
```

This warning is now resolved with the PATH fix applied.

## Success Indicators

✅ **No container restarts** in `docker ps` output  
✅ **All containers show "Up (healthy)"** status  
✅ **HTTPS URL appears** in deployment success message  
✅ **All services respond** to curl tests  
✅ **No PATH warnings** in future builds  

The critical backend PATH issue has been fixed. Please restart the deployment to see if containers stabilize.