# Getting Started with Kamal Singh Portfolio

Welcome to the professional portfolio website for Kamal Singh, IT Portfolio Architect. This guide provides quick access to all deployment options with complete flexibility.

## 🎯 **WHERE TO START** - 3 Options

### 🚀 **Option 1: Complete Full-Stack (Recommended)**
Deploy everything with one command:
```bash
./scripts/deploy-with-params.sh --mongo-password securepass123 --grafana-password admin123
```

### 🔧 **Option 2: Individual Containers**
Run only what you need:
```bash
./scripts/build-individual-containers.sh backend --smtp-username me@gmail.com --smtp-password mypass
./scripts/build-individual-containers.sh frontend-http --port 3000
```

### 📋 **Option 3: Generate Docker Commands**
Get copy-paste ready commands:
```bash
./scripts/docker-commands-generator.sh all --with-params
```

---

## 📚 **COMPLETE FLEXIBILITY & OPTIONS**

👉 **[COMPLETE_DEPLOYMENT_GUIDE.md](COMPLETE_DEPLOYMENT_GUIDE.md)** - **READ THIS FOR ALL OPTIONS**

This comprehensive guide covers:
- **All deployment scripts** with every parameter explained
- **Complete SMTP configuration** (Gmail, Outlook, Yahoo, custom)
- **Port customization** for all services
- **Environment file usage**
- **Individual container management**
- **Docker command generation**
- **Production vs development modes**

---

## ⚡ **Quick Configuration**

### SMTP Email Setup (Required for Contact Form)
```bash
# Using command line (recommended)
./scripts/deploy-with-params.sh \
  --smtp-username your-email@gmail.com \
  --smtp-password your-app-password \
  --from-email your-email@gmail.com \
  --mongo-password securepass123 \
  --grafana-password admin123
```

### Custom Ports & Services
```bash
# Deploy with custom ports
./scripts/deploy-with-params.sh \
  --http-port 3000 --backend-port 3001 --grafana-port 3030 \
  --mongo-password securepass123 --grafana-password admin123
```

---

## 🔗 **Access URLs After Deployment**

- **Portfolio**: http://localhost:8080 (or your custom port)
- **API Docs**: http://localhost:8001/docs
- **Grafana**: http://localhost:3000 (admin/your-password)
- **Prometheus**: http://localhost:9090
- **Mongo Express**: http://localhost:8081 (admin/admin123)

---

## 📖 **All Documentation**

- **[COMPLETE_DEPLOYMENT_GUIDE.md](COMPLETE_DEPLOYMENT_GUIDE.md)** - **🔥 MAIN GUIDE - All Options & Flexibility**
- **[DOCKER_IMAGE_MANAGEMENT_GUIDE.md](DOCKER_IMAGE_MANAGEMENT_GUIDE.md)** - **🐋 Docker Workflows & Best Practices**
- **[HOST_VOLUME_PERSISTENCE_UPDATE.md](HOST_VOLUME_PERSISTENCE_UPDATE.md)** - **🏠 Data Safety & Persistence**
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Backend API reference
- **[MONITORING_ACCESS_GUIDE.md](MONITORING_ACCESS_GUIDE.md)** - Monitoring stack access
- **[SMTP_CONFIGURATION_GUIDE.md](SMTP_CONFIGURATION_GUIDE.md)** - Email configuration
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and C4 diagrams
- **[PHASE_2_3_CHANGELOG.md](PHASE_2_3_CHANGELOG.md)** - Enterprise features changelog

---

## 🎉 **What You Get**

### **✅ Application Features**
- Professional IT Portfolio with 5 pages
- Enhanced contact form with file upload
- Advanced search across all content
- Google Analytics 4 integration
- Professional IT/corporate imagery

### **✅ Enterprise Infrastructure**
- Complete monitoring stack (Prometheus, Grafana, Loki) with persistent data storage
- CI/CD pipeline with GitHub Actions
- Automated backup/restore with host volume persistence
- SSL/HTTPS support with auto-generated certificates
- Docker containerization with data safety via host mounting

### **✅ Complete Flexibility**
- **All ports customizable** via command line
- **Any SMTP provider** (Gmail, Outlook, Yahoo, custom)
- **Individual container deployment**
- **Environment file or CLI configuration**
- **Development and production modes**

---

## 🐋 **Docker Image Management**

### Efficient Development Workflow
```bash
# For code changes - stop and cleanup (data persists on host)
./stop-and-cleanup.sh

# For configuration changes only - quick stop
docker-compose -f docker-compose.production.yml down

# Force rebuild if cache issues
./scripts/deploy-with-params.sh [parameters...] --force-rebuild

# Fresh start including database (⚠️ removes host data)
./stop-and-cleanup.sh --remove-volumes

# Safe mode - see what would be removed without removing
./stop-and-cleanup.sh --safe-mode
```

## 🛠️ **Troubleshooting**

### Common Issues
```bash
# Fresh start (recommended first step)
./stop-and-cleanup.sh

# Check container status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# View logs
docker logs portfolio-backend

# Test API
curl http://localhost:8001/api/

# Test SMTP
./verify-email-smtp.sh gmail-ssl
```

### Get Help
1. Check [COMPLETE_DEPLOYMENT_GUIDE.md](COMPLETE_DEPLOYMENT_GUIDE.md) for all options
2. Check [DOCKER_IMAGE_MANAGEMENT_GUIDE.md](DOCKER_IMAGE_MANAGEMENT_GUIDE.md) for Docker workflows
3. Run any script with `--help` flag
4. Use `./stop-and-cleanup.sh` for clean restart

---

## 🚀 **Next Steps**

1. **Read**: [COMPLETE_DEPLOYMENT_GUIDE.md](COMPLETE_DEPLOYMENT_GUIDE.md) for all deployment options
2. **Deploy**: Choose your deployment method above
3. **Configure**: Set up SMTP for email functionality
4. **Monitor**: Access Grafana for system monitoring
5. **Customize**: Use command line parameters for flexibility

**Start with the Complete Deployment Guide for crystal clear instructions!** 👆