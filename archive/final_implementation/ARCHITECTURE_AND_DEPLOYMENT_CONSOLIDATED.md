# 🏗️ Architecture & Deployment - Consolidated Guide

This document provides the complete architecture overview and deployment instructions for the ARCHSOL IT Solutions portfolio system.

## 🔐 API Security & Deployment Options

### 🚀 Standard Deployment
```bash
# Basic deployment with domain
./scripts/deploy-with-params.sh --domain portfolio --mongo-password pass123 --grafana-password admin123
```

### 🔒 Secure Production Deployment (Recommended)
```bash
# Auto-generated API security
./scripts/deploy-with-params.sh \
  --domain portfolio \
  --enable-api-auth \
  --http-port 3400 --https-port 3443 --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 --smtp-use-ssl true \
  --mongo-password securepass123 --grafana-password admin123
```

### 🎯 API Security Architecture
```
🌐 PRODUCTION (Secured Domain Access)
────────────────────────────────────
Internet → https://portfolio.architecturesolutions.co.uk
    ↓
Traefik (192.168.86.56:434) [Injects API Headers]
    ↓
X-API-Key + X-API-Secret (Auto-generated 64-char keys)
    ↓  
Backend Validation (192.168.86.75:3001)
    ↓
✅ Authenticated Response

🏠 DEVELOPMENT (Unrestricted IP Access)  
─────────────────────────────────────
Developer → http://192.168.86.75:3400
    ↓ [Direct Container Access]
Backend (192.168.86.75:3001)
    ↓ [No Authentication Required]
✅ Direct Response
```

### 📋 Security Features
- **Traefik Middleware**: Auto-injects API credentials for domain requests
- **FastAPI Validation**: Backend validates credentials via dependency injection
- **Zero Frontend Impact**: Complete transparency to React application
- **Development Friendly**: IP access bypasses authentication
- **Credential Display**: Keys shown at deployment + saved to files
- **Easy Rotation**: Redeploy with new keys anytime

## 🏗️ System Architecture Overview

### Multi-Container Architecture
- **Frontend**: Dual protocol support (HTTP/HTTPS) with shared React codebase
- **Backend**: FastAPI with CORS support for both HTTP and HTTPS frontends
- **Database**: MongoDB 4.4 with host volume persistence
- **Monitoring**: Prometheus, Grafana, Loki stack with pre-configured dashboards
- **External Integration**: Traefik-ready with host port exposure

### Recent Architecture Improvements

#### ✅ HTTP/HTTPS Frontend Integration
- **CORS Configuration Fixed**: Backend supports both HTTP (localhost:8080) and HTTPS (localhost:8443)
- **Unified Contact Form**: Email functionality working from both frontends
- **Dynamic Frontend Environment**: Automatic backend URL configuration
- **Shared Codebase**: Single React build serving both containers

#### ✅ External Traefik Integration
- **Traefik Labels Removed**: Docker Compose optimized for external load balancer
- **Host Port Exposure**: Services accessible via host ports
- **SSL Termination Flexibility**: Supports both internal SSL and external Traefik SSL
- **Domain Parameter Support**: Dynamic frontend configuration for custom domains

## 📋 Complete Deployment Scripts

### Script 1: deploy-with-params.sh
**Purpose**: Deploy entire application stack with all services

**Frontend Configuration:**
- `--http-port PORT` - HTTP frontend port (default: 8080)
- `--https-port PORT` - HTTPS frontend port (default: 8443)
- `--backend-port PORT` - Backend API port (default: 8001)

**SMTP Configuration:**
```bash
# Gmail Example
./scripts/deploy-with-params.sh \
  --smtp-server smtp.gmail.com --smtp-port 587 \
  --smtp-username me@gmail.com --smtp-password myapppass \
  --smtp-use-tls true --smtp-use-ssl false
```

**Database Configuration:**
- `--mongo-port PORT` - MongoDB port (default: 27017)
- `--mongo-password PASS` - MongoDB admin password (REQUIRED)
- `--mongo-data-path PATH` - Data persistence path (default: ./data/mongodb)

**Monitoring Configuration:**
- `--prometheus-port PORT` - Prometheus port (default: 9090)
- `--grafana-port PORT` - Grafana port (default: 3000)
- `--grafana-password PASS` - Grafana admin password (REQUIRED)

### Script 2: build-individual-containers.sh
**Purpose**: Build and run individual containers

**Examples:**
```bash
# Build HTTP frontend
./scripts/build-individual-containers.sh frontend-http --port 3000

# Build backend with SMTP
./scripts/build-individual-containers.sh backend \
  --smtp-username me@gmail.com --smtp-password mypass
```

### Script 3: docker-commands-generator.sh
**Purpose**: Generate copy-paste ready Docker commands

```bash
# Generate all commands with parameters
./scripts/docker-commands-generator.sh all --with-params
```

## 🐋 Docker Image Management

### Enhanced Stop Script (Recommended for Development)
```bash
# Stop containers and remove project images (keeps data)
./stop-and-cleanup.sh

# Complete cleanup including volumes (⚠️ deletes database)
./stop-and-cleanup.sh --remove-volumes

# Preview what would be removed
./stop-and-cleanup.sh --safe-mode
```

### Key Features:
- ✅ **MongoDB WiredTiger Conflict Detection** - Automatic detection and cleanup
- ✅ **Smart Image Detection** - Finds portfolio images with various patterns
- ✅ **Safe Mode** - Preview removals without executing
- ✅ **Data Preservation** - Database data survives container recreation

## 📊 Container Specifications

| Container | Base Image | Ports | Purpose | Recent Updates |
|-----------|------------|-------|---------|----------------|
| HTTP Frontend | nginx:alpine | 8080 | HTTP portfolio serving | CORS-compatible |
| HTTPS Frontend | nginx:alpine | 8443 | HTTPS portfolio serving | CORS-compatible |
| Backend API | python:3.11-slim | 8001 | REST API, SMTP, CORS for both HTTP/HTTPS | Fixed CORS origins |
| MongoDB | mongo:4.4 | 27017 | Document database | AVX compatible |
| Redis | redis:alpine | 6379 | Caching | Host persistence |
| Prometheus | prom/prometheus | 9090 | Metrics collection | Fixed targets |
| Grafana | grafana/grafana | 3000 | Dashboards | Pre-configured |
| Loki | grafana/loki | 3100 | Log aggregation | Schema v13 |

## 🔧 SMTP Configuration Reference

### Popular Provider Settings
```bash
# Gmail (Port 587 - TLS)
--smtp-server smtp.gmail.com --smtp-port 587 \
--smtp-use-tls true --smtp-use-ssl false

# Gmail (Port 465 - SSL)
--smtp-server smtp.gmail.com --smtp-port 465 \
--smtp-use-ssl true --smtp-use-tls false

# Outlook
--smtp-server smtp-mail.outlook.com --smtp-port 587 \
--smtp-use-tls true --smtp-use-ssl false

# Custom/Corporate
--smtp-server mail.company.com --smtp-port 587 \
--smtp-use-tls true --smtp-timeout 45
```

## 🏠 Data Persistence & Safety

### Host Volume Mounting
All critical data stored on host filesystem:
```
/app/
├── data/                    # All persistent data (auto-created)
│   ├── mongodb/            # MongoDB database files
│   ├── grafana/            # Grafana dashboards & settings
│   ├── prometheus/         # Prometheus metrics
│   └── loki/               # Loki log data
├── backups/                # MongoDB backup files
├── ssl/                    # SSL certificates
└── logs/                   # Application logs
```

### Benefits:
- ✅ **Database survives container recreation**
- ✅ **Grafana dashboards persist**
- ✅ **Prometheus metrics history preserved**
- ✅ **No data loss during updates**
- ✅ **WiredTiger conflict resolution**

## 🔗 Access URLs After Deployment

- **Portfolio (HTTP)**: http://localhost:8080
- **Portfolio (HTTPS)**: https://localhost:8443
- **API Documentation**: http://localhost:8001/docs
- **Grafana**: http://localhost:3000 (admin/your-password)
- **Prometheus**: http://localhost:9090
- **Mongo Express**: http://localhost:8081 (admin/admin123)

## 🚨 Recent Major Fixes

### ✅ CORS Issue Resolution
- **Problem**: Email functionality worked in HTTP frontend but not HTTPS frontend
- **Root Cause**: Backend CORS_ORIGINS didn't include https://localhost:8443
- **Solution**: Updated CORS configuration to support both HTTP and HTTPS origins
- **Result**: Both frontends now work with email functionality

### ✅ Monitoring Stack Fixes
- **Fixed Prometheus targets** - No more "down" status
- **Pre-configured Grafana dashboards** - Ready-to-use visualizations
- **Auto-provisioning** - Datasources configured automatically

### ✅ External Traefik Integration
- **Removed internal Traefik labels** - Optimized for external load balancer
- **Host port exposure** - Services accessible for external reverse proxy
- **Domain parameter support** - Dynamic configuration for custom domains

## 💡 Best Practices

1. **Development**: Use `./stop-and-cleanup.sh` for regular cleanup
2. **Production**: Never use `--remove-volumes` in production
3. **SMTP**: Use App Passwords for Gmail, verify certificates for custom servers
4. **Monitoring**: Check Grafana dashboards after deployment
5. **Data Safety**: Regular backups stored in ./backups/
6. **WiredTiger**: Let script auto-detect and fix conflicts

## 🎉 Summary

This consolidated architecture provides:
- **Complete deployment flexibility** - All ports and settings customizable
- **Dual protocol support** - HTTP and HTTPS frontends with shared backend
- **External Traefik ready** - Host port exposure for reverse proxy integration
- **Enterprise monitoring** - Prometheus, Grafana, Loki with persistence
- **Data safety** - Host volume mounting with WiredTiger conflict resolution
- **CORS compatibility** - Fixed backend configuration for both frontend protocols

Start with: `./scripts/deploy-with-params.sh --help` to see all options!