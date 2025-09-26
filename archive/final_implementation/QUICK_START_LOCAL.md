# 🚀 Kamal Singh Portfolio - Quick Start Guide (Local Installation)

## ⚡ One-Command Setup

### Step 1: Run Complete Installation
```bash
# Make script executable and run
chmod +x install_local.sh
./install_local.sh
```

### Step 2: Start Application  
```bash
# Start all services (MongoDB, Backend, Frontend)
./start_local.sh
```

### Step 3: Access Portfolio
- **🌐 Portfolio**: http://localhost:3000
- **🔧 Backend API**: http://localhost:8001  
- **📚 API Docs**: http://localhost:8001/docs

## 🎮 Management Commands

```bash
# Service Control
./start_local.sh          # Start all services
./stop_local.sh           # Stop all services
./manage_services.sh      # Service management menu

# Service Status & Logs
./manage_services.sh status    # Check service health
./manage_services.sh logs      # View service logs  
./manage_services.sh restart   # Restart all services

# Maintenance
./manage_services.sh update    # Update dependencies
./manage_services.sh help      # Show all commands
```

## 🏗️ What Gets Installed

### ✅ System Prerequisites
- Node.js 18.x + Yarn
- Python 3.9+ + pip
- MongoDB 6.0+ with service
- All required system packages

### ✅ Application Stack  
- **Frontend**: React 19 + Tailwind CSS + Shadcn/UI
- **Backend**: FastAPI + Python + MongoDB
- **Database**: MongoDB with sample data and indexes
- **Management**: Enhanced start/stop/status scripts

### ✅ Portfolio Features
- **5 Featured Projects** with detailed outcomes
- **8 Professional Experiences** (26+ years timeline)
- **6 Anonymous Testimonials** from industry leaders  
- **Multi-page Navigation** (Home, About, Skills, Experience, Projects, Contact)
- **Professional Design** with corporate theme and animations
- **Contact Form** with project type selection

## 🛠️ Troubleshooting

### Quick Fixes
```bash
# Check what's running
./manage_services.sh status

# Restart everything  
./manage_services.sh restart

# Full reinstall
./install_local.sh
```

### Port Conflicts
```bash
# Check ports
lsof -i :3000  # Frontend
lsof -i :8001  # Backend

# Kill processes
sudo kill -9 <PID>
```

### MongoDB Issues
```bash
# Linux: Restart MongoDB
sudo systemctl restart mongod

# macOS: Restart MongoDB  
brew services restart mongodb/brew/mongodb-community

# Test connection
mongosh --eval "db.adminCommand('ping')"
```

## 💼 About This Portfolio

**Kamal Singh** - IT Portfolio Architect
- 📍 Amersham, United Kingdom
- 📧 chkamalsingh@yahoo.com
- 📱 07908 521 588
- 💼 26+ years in Enterprise Architecture & Digital Transformation

**Specialties**: Cloud Migration, CIAM/IAM, API-First Design, Microservices, Digital Transformation across Banking, Insurance, Retail, and Gaming industries.

---

**Ready to start?** Run `./install_local.sh` and have a professional portfolio running in minutes! 🎉