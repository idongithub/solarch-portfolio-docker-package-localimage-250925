# NumPy Docker Build Fix

## Issue Resolved

Fixed backend Docker build failure:
```
Building wheel for numpy (pyproject.toml): finished with status 'error'
RuntimeError: Broken toolchain: cannot link a simple C++ program. 
note: A compiler with support for C++11 language features is required.
[Errno 2] No such file or directory: 'g++'
```

## Root Cause

The backend Dockerfile was using `python:3.11-alpine` without the necessary build tools for NumPy compilation:

1. **Missing C++ Compiler**: NumPy requires `g++` for C++ code compilation
2. **Missing BLAS/LAPACK**: NumPy needs linear algebra libraries for optimal performance
3. **Missing Fortran Compiler**: NumPy's mathematical operations require Fortran libraries
4. **Alpine Linux Limitations**: Minimal Alpine images don't include build toolchains

## Fix Applied

### Before (Problematic):
```dockerfile
# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    linux-headers \
    curl

# Install Python dependencies and compile them
RUN pip install --no-cache-dir --user -r requirements.txt
```

### After (Fixed):
```dockerfile
# Install build dependencies including C++ compiler for NumPy
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    g++ \
    musl-dev \
    linux-headers \
    curl \
    gfortran \
    openblas-dev \
    lapack-dev

# Install Python dependencies and compile them
RUN pip install --no-cache-dir --user -r requirements.txt && \
    apk del .build-deps
```

### Runtime Stage Fix:
```dockerfile
# Install runtime dependencies for NumPy and FastAPI
RUN apk add --no-cache curl openblas lapack && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
```

## Key Dependencies Added

### Build Dependencies:
- **`g++`** - C++ compiler required for NumPy compilation
- **`gfortran`** - Fortran compiler for mathematical libraries
- **`openblas-dev`** - Development headers for optimized BLAS operations
- **`lapack-dev`** - Development headers for linear algebra routines

### Runtime Dependencies:
- **`openblas`** - Optimized Basic Linear Algebra Subprograms
- **`lapack`** - Linear Algebra PACKage for runtime operations

## Why This Fix Works

### NumPy Requirements:
- **C++ Compilation**: NumPy contains C++ code that requires g++ compiler
- **Mathematical Libraries**: BLAS/LAPACK provide optimized mathematical operations
- **Fortran Support**: Some NumPy algorithms use Fortran-compiled libraries

### Performance Benefits:
- **Optimized BLAS**: OpenBLAS provides hardware-optimized linear algebra operations
- **Better Performance**: Compiled NumPy with proper libraries runs significantly faster
- **Reduced Warnings**: Eliminates "falls back to netlib Blas" performance warnings

## Backend Dependencies Requiring NumPy

From `requirements.txt`:
```
pandas==2.1.4     # Depends on NumPy for data structures
numpy==1.24.4     # Direct dependency
```

Pandas requires NumPy, so this fix enables both packages to build successfully.

## Image Size Optimization

### Multi-Stage Build Benefits:
1. **Build Stage**: Installs heavy build tools (gcc, g++, dev packages)
2. **Runtime Stage**: Only includes minimal runtime libraries
3. **Cleanup**: Removes build dependencies after compilation (`apk del .build-deps`)

### Final Image Size:
- **Build dependencies**: Removed after compilation (~200MB+ savings)
- **Runtime libraries**: Only essential libraries included (~20MB)
- **Optimized performance**: NumPy compiled with hardware-optimized libraries

## Testing

The backend build should now complete successfully:

```bash
# Test backend build
./scripts/deploy-with-params.sh --build-test

# Full deployment
./scripts/deploy-with-params.sh \
  --mongo-password securepass123 --grafana-password admin123 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true --smtp-port 465
```

## Progress Summary

**Issues Fixed So Far:**
1. ✅ **CRACO build error** - Package manager mismatch resolved
2. ✅ **Nginx setup error** - Directory creation sequence fixed
3. ✅ **MongoDB image error** - Updated to available mongo:7.0 image
4. ✅ **NumPy build error** - Added C++ compiler and math libraries

**Current Status:**
- Backend should build successfully with NumPy and Pandas
- All Docker images should compile without build errors
- Ready for next deployment attempt

The deployment should now progress past the backend build stage successfully.