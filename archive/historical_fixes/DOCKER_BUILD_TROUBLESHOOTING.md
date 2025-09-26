# Docker Build Troubleshooting Guide

## Common Docker Build Issues & Solutions

### 1. React 19 Compatibility Issues

**Problem:** Build fails with React 19 dependency conflicts
**Solution:** Downgraded to React 18.2.0 for better compatibility

```json
"react": "^18.2.0",
"react-dom": "^18.2.0",
"react-router-dom": "^6.26.1"
```

### 2. Python Package Version Conflicts

**Problem:** Cryptography, email-validator, or other package version conflicts
**Solution:** Fixed versions in `requirements.txt`:

```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
cryptography==42.0.8
email-validator==2.1.1
pydantic==2.5.3
```

### 3. MongoDB Installation Issues

**Problem:** Deprecated `apt-key` usage causing MongoDB installation failures
**Solution:** Updated to use proper GPG keyring approach:

```dockerfile
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg \
    && echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
```

### 4. Frontend Build Memory Issues

**Problem:** JavaScript heap out of memory during build
**Solution:** Increased memory allocation:

```bash
yarn build --max_old_space_size=4096
```

### 5. Missing Files in Docker Context

**Problem:** Missing `env.template.js` file referenced in frontend Dockerfile
**Solution:** Created the missing file:

```javascript
window.ENV = {
  REACT_APP_BACKEND_URL: "${REACT_APP_BACKEND_URL}",
  NODE_ENV: "${NODE_ENV}"
};
```

### 6. Node.js and Yarn Installation Issues

**Problem:** Yarn installation conflicts or failures
**Solution:** Simplified to use npm to install yarn globally:

```dockerfile
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn
```

## Build Commands

### Build All-in-One Docker Image:
```bash
# Using the enhanced build script (recommended)
./build-docker-fixed.sh

# Or manually
docker build -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest .
```

### Build Multi-Container Setup:
```bash
# Build backend
docker build -f backend/Dockerfile -t portfolio-backend ./backend

# Build frontend
docker build -f frontend/Dockerfile -t portfolio-frontend ./frontend

# Run with docker-compose
docker-compose up -d
```

## Testing the Build

### Quick Health Check:
```bash
# Start container
docker run -d -p 8080:80 --name test-portfolio kamal-singh-portfolio:latest

# Wait for startup
sleep 15

# Test HTTP endpoint
curl -f http://localhost:8080

# Check logs
docker logs test-portfolio

# Cleanup
docker stop test-portfolio && docker rm test-portfolio
```

## Environment Variables

### Required for Email Functionality:
```bash
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
FROM_EMAIL=your-email@gmail.com
TO_EMAIL=kamal.singh@architecturesolutions.co.uk
```

### Optional Configuration:
```bash
MONGO_URL=mongodb://localhost:27017
DB_NAME=portfolio_db
WEBSITE_URL=http://localhost
DEBUG=False
ENVIRONMENT=production
```

## Performance Optimization

### Build with BuildKit:
```bash
DOCKER_BUILDKIT=1 docker build -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest .
```

### Multi-stage Build Cache:
```bash
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest .
```

## Debugging Build Issues

### Enable Verbose Logging:
```bash
docker build --progress=plain -f Dockerfile.all-in-one -t kamal-singh-portfolio:latest . 2>&1 | tee build.log
```

### Check Build Context Size:
```bash
# Ensure .dockerignore is properly configured
ls -la .dockerignore
```

### Inspect Failed Builds:
```bash
# Run intermediate container for debugging
docker run --rm -it <failed-image-id> /bin/bash
```

## Troubleshooting Checklist

- [ ] Docker version >= 20.10.0
- [ ] Sufficient disk space (>5GB)
- [ ] Sufficient memory (>4GB)
- [ ] All required files present in build context
- [ ] No conflicting package versions
- [ ] Proper network connectivity for downloads
- [ ] .dockerignore configured to exclude node_modules, .git

## Support

If issues persist:
1. Check the build log: `docker-build.log`
2. Verify system requirements
3. Try building individual components separately
4. Use the enhanced build script for better error reporting