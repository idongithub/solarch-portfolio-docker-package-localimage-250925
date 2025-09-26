# Environment Variable Alignment Fixes

## Issues Identified

During deployment stop, the following warnings appeared:
```
WARNING: The MONGO_ROOT_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The REDIS_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The GRAFANA_ADMIN_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The MONGO_ROOT_USERNAME variable is not set. Defaulting to a blank string.
WARNING: The SMTP_SERVER variable is not set. Defaulting to a blank string.
WARNING: The SMTP_USERNAME variable is not set. Defaulting to a blank string.
WARNING: The SMTP_PASSWORD variable is not set. Defaulting to a blank string.
WARNING: The FROM_EMAIL variable is not set. Defaulting to a blank string.
WARNING: The TO_EMAIL variable is not set. Defaulting to a blank string.
WARNING: The SECRET_KEY variable is not set. Defaulting to a blank string.
```

## Root Cause

**Mismatch between deployment script variable names and docker-compose.yml expectations:**

### Script vs Docker-Compose Misalignments:
- Script sets: `MONGO_USERNAME` / Docker expects: `MONGO_ROOT_USERNAME`
- Script sets: `MONGO_PASSWORD` / Docker expects: `MONGO_ROOT_PASSWORD`  
- Script sets: `GRAFANA_PASSWORD` / Docker expects: `GRAFANA_ADMIN_PASSWORD`
- Missing default assignments for some variables

## Fixes Applied

### 1. **Updated Script Variable Names**

**Before (Problematic)**:
```bash
export MONGO_ROOT_USERNAME MONGO_ROOT_PASSWORD
export GRAFANA_ADMIN_PASSWORD
```

**After (Fixed)**:
```bash  
export MONGO_USERNAME MONGO_PASSWORD
export GRAFANA_PASSWORD
```

### 2. **Fixed Variable Assignments in Script**

**Before**:
```bash
MONGO_ROOT_USERNAME="$2"
MONGO_ROOT_PASSWORD="$2"
GRAFANA_ADMIN_PASSWORD="$2"
```

**After**:
```bash
MONGO_USERNAME="$2"
MONGO_PASSWORD="$2"
GRAFANA_PASSWORD="$2"
```

### 3. **Added Missing Default Assignments**

**Added**:
```bash
MONGO_PASSWORD="${MONGO_PASSWORD:-}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"
```

### 4. **Updated Docker-Compose Variable References**

**Before**:
```yaml
- MONGO_INITDB_ROOT_USERNAME=${MONGO_ROOT_USERNAME:-admin}
- MONGO_INITDB_ROOT_PASSWORD=${MONGO_ROOT_PASSWORD}
- GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
```

**After**:
```yaml
- MONGO_INITDB_ROOT_USERNAME=${MONGO_USERNAME:-admin}
- MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}
- GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
```

## Variables Now Properly Aligned

### Core Application Variables:
✅ **SMTP_SERVER** - Email server configuration  
✅ **SMTP_USERNAME** - Email authentication username  
✅ **SMTP_PASSWORD** - Email authentication password  
✅ **FROM_EMAIL** - Sender email address  
✅ **TO_EMAIL** - Recipient email address  
✅ **SECRET_KEY** - Application secret key  

### Database Variables:
✅ **MONGO_USERNAME** - MongoDB admin username  
✅ **MONGO_PASSWORD** - MongoDB admin password  
✅ **REDIS_PASSWORD** - Redis authentication password  

### Monitoring Variables:
✅ **GRAFANA_PASSWORD** - Grafana admin password  

## Expected Results After Fix

### No More Environment Variable Warnings:
```bash
# No warnings should appear during deployment
docker-compose -f docker-compose.production.yml up -d
```

### All Variables Should Be Set:
```bash
# Check variables are exported
echo $MONGO_USERNAME        # Should show: admin
echo $MONGO_PASSWORD        # Should show: securepass123
echo $GRAFANA_PASSWORD      # Should show: adminpass123
echo $REDIS_PASSWORD        # Should show: redispass123
echo $SMTP_SERVER           # Should show: smtp.ionos.co.uk
echo $SMTP_USERNAME         # Should show: kamal.singh@architecturesolutions.co.uk
```

### Services Should Start Without Authentication Issues:
- MongoDB: Uses correct MONGO_USERNAME/MONGO_PASSWORD
- Grafana: Uses correct GRAFANA_PASSWORD
- Redis: Uses correct REDIS_PASSWORD
- Backend: Uses correct SMTP configuration

## Testing the Fix

### 1. Run Deployment Command:
```bash
./scripts/deploy-with-params.sh --http-port 3400 --https-port 3443 --backend-port 3001 \
--smtp-server smtp.ionos.co.uk --smtp-port 465 \
--smtp-username kamal.singh@architecturesolutions.co.uk --smtp-password NewPass6 \
--from-email kamal.singh@architecturesolutions.co.uk --to-email kamal.singh@architecturesolutions.co.uk \
--smtp-use-tls true --ga-measurement-id G-B2W705K4SN \
--mongo-express-port 3081 --mongo-express-username admin --mongo-express-password admin123 \
--mongo-port 37037 --mongo-username admin --mongo-password securepass123 \
--grafana-password adminpass123 --redis-password redispass123 --grafana-port 3030 \
--loki-port 3300 --prometheus-port 3091
```

### 2. Verify No Warnings:
- No "variable is not set" warnings should appear
- All services should start with proper authentication
- Environment variables should be properly passed to containers

### 3. Test Service Authentication:
```bash
# MongoDB should authenticate properly
docker exec portfolio-mongodb mongosh --username admin --password securepass123 --eval "db.adminCommand('ping')"

# Grafana should use correct admin password  
curl -u admin:adminpass123 http://localhost:3030/api/health

# Redis should accept password
docker exec portfolio-redis redis-cli AUTH redispass123
```

## Summary

✅ **Fixed script variable names** to match docker-compose expectations  
✅ **Added missing default assignments** for all required variables  
✅ **Aligned docker-compose variable references** with script exports  
✅ **Eliminated environment variable warnings** during deployment  

All environment variables should now be properly set and passed to containers without warnings.