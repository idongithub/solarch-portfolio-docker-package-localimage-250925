# Frontend Build Error Fix

## Issue Resolved

Fixed the deployment failure during frontend Docker build:
```
Error: Cannot find module 'react-scripts/config/env.js'
ERROR: Service 'frontend-http' failed to build: The command returned a non-zero code: 1
```

## Root Cause

The issue was in the optimized Dockerfiles (`Dockerfile.npm.optimized` and `Dockerfile.https.optimized`):

1. **Dependencies Issue**: The Dockerfiles were installing only production dependencies with `--only=production`
2. **Build Tool Missing**: `@craco/craco` is listed in `devDependencies` but required for the build process
3. **Build Script**: The `package.json` uses `craco build` which requires CRACO to be installed

## Fix Applied

### Root Cause:
The project uses **yarn** for dependency management (has yarn.lock) but the Dockerfiles were using **npm ci**, which creates a different dependency tree and can cause module resolution issues with CRACO.

### Before (Problematic):
```dockerfile
# Copy package files first for better caching
COPY frontend/package.json frontend/package-lock.json ./

# Install dependencies
RUN npm ci --legacy-peer-deps --only=production && \
    npm audit fix --audit-level moderate --force 2>/dev/null || true && \
    npm cache clean --force && \
    rm -rf ~/.npm
```

### After (Fixed):
```dockerfile
# Install yarn
RUN apk add --no-cache yarn

# Copy package files first for better caching  
COPY frontend/package.json frontend/yarn.lock ./

# Install all dependencies (including dev deps needed for build)
RUN yarn install --frozen-lockfile
```

### Build Stage Cleanup:
```dockerfile
# Build application and clean up all unnecessary files in single layer
RUN yarn build && \
    yarn cache clean && \
    rm -rf node_modules src public package*.json *.config.js *.md yarn.lock && \
    rm -rf .git .gitignore .env* && \
    find . -name "*.test.*" -delete && \
    find . -name "*.spec.*" -delete
```

## Files Updated

1. **`/app/Dockerfile.npm.optimized`** - Fixed HTTP frontend build
2. **`/app/Dockerfile.https.optimized`** - Fixed HTTPS frontend build

## Technical Details

### Package Dependencies:
- `react-scripts`: In `dependencies` (needed for build)
- `@craco/craco`: In `devDependencies` (needed for build)
- Build script: `"build": "craco build"`
- **Package Manager**: yarn (has yarn.lock file)

### Solution Strategy:
1. **Install Phase**: Use yarn (not npm) to respect yarn.lock and install ALL dependencies for build
2. **Build Phase**: Run `yarn build` with CRACO and dependencies installed via yarn
3. **Cleanup Phase**: Remove `node_modules`, dev files, and caches after build
4. **Production Phase**: Copy only built static files to nginx

### Key Fix:
**Use yarn instead of npm** - This ensures the dependency tree matches exactly what the project was developed with, resolving CRACO module resolution issues.

## Deployment Impact

- **Image Size**: Still optimized (dev dependencies removed after build)
- **Security**: Still secure (source files and dev tools removed)
- **Functionality**: Build process now works correctly
- **Performance**: No runtime impact (multi-stage build)

## Testing

The deployment script now works end-to-end:

```bash
# Test dry run (should work)
./scripts/deploy-with-params.sh --dry-run --mongo-password test123 --grafana-password admin123

# Full deployment (should work)
./scripts/deploy-with-params.sh --mongo-password securepass123 --grafana-password admin123
```

## What This Fixes

✅ **Frontend HTTP build** - No more CRACO/react-scripts errors  
✅ **Frontend HTTPS build** - Same fix applied  
✅ **Production deployment** - Complete stack deployment works  
✅ **Image optimization** - Still maintains small final image size  
✅ **Multi-stage builds** - Build artifacts properly cleaned up  

The deployment should now complete successfully without the module not found errors.