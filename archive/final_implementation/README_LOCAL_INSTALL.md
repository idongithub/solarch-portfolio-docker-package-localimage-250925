# 🚀 Kamal Singh Portfolio - Complete Local Installation Guide

## 📋 Overview

This is a professional portfolio website for **Kamal Singh, IT Portfolio Architect**, featuring a complete full-stack application with React frontend, FastAPI backend, and MongoDB database. This guide provides automated installation for local server deployment.

## ⚡ One-Command Installation

### Quick Start (Automated)
```bash
# 1. Clone or download the portfolio
git clone <repository-url> kamal-singh-portfolio
cd kamal-singh-portfolio

# 2. Run complete installation (installs everything)
chmod +x install_local.sh
./install_local.sh

# 3. Start the application
./start_local.sh
```

**That's it!** The installation script handles everything automatically.

## 🎯 What Gets Installed

### System Components
- ✅ **Node.js 18.x** - JavaScript runtime for frontend
- ✅ **Yarn** - Package manager for Node.js dependencies  
- ✅ **Python 3.9+** - Backend runtime environment
- ✅ **MongoDB 6.0+** - Database server with sample data
- ✅ **System Prerequisites** - All required system packages

### Application Stack
- ✅ **Frontend**: React 19 + Tailwind CSS + Shadcn/UI components
- ✅ **Backend**: FastAPI + Python with MongoDB integration
- ✅ **Database**: MongoDB with collections, indexes, and sample data
- ✅ **Configuration**: Environment files for both frontend and backend
- ✅ **Management Scripts**: Start, stop, and service management tools

## 🌐 Access Your Portfolio

Once installation is complete and services are started:

| Service | URL | Description |
|---------|-----|-------------|
| 🌐 **Portfolio Website** | http://localhost:3000 | Main portfolio application |
| 🔧 **Backend API** | http://localhost:8001 | REST API server |
| 📚 **API Documentation** | http://localhost:8001/docs | Interactive API docs |

## 📱 Portfolio Pages

| Page | URL | Features |
|------|-----|----------|
| 🏠 **Home** | http://localhost:3000/ | Hero section with professional intro |
| 👤 **About** | http://localhost:3000/about | Career journey and achievements |
| 🛠️ **Skills** | http://localhost:3000/skills | Interactive competencies with ratings |
| 💼 **Experience** | http://localhost:3000/experience | Professional timeline (26+ years) |
| 🚀 **Projects** | http://localhost:3000/projects | Featured portfolio with 5 projects |
| 📞 **Contact** | http://localhost:3000/contact | Professional contact form |

## 🎮 Management Commands

### Service Management
```bash
# Start all services (MongoDB, Backend, Frontend)
./start_local.sh

# Stop all services
./stop_local.sh

# Service management menu
./manage_services.sh

# Check service status
./manage_services.sh status

# View service logs
./manage_services.sh logs

# Restart all services
./manage_services.sh restart

# Update dependencies
./manage_services.sh update
```

### Advanced Management
```bash
# Check what's running
./manage_services.sh status

# View recent logs
./manage_services.sh logs

# Update all dependencies
./manage_services.sh update

# Full help menu
./manage_services.sh help
```

## 🏗️ Architecture & Features

### 💼 Professional Design
- **Corporate Theme**: Navy, charcoal, gold color scheme
- **Typography**: Professional serif fonts (Georgia)
- **Responsive Design**: Works on all devices and screen sizes
- **Smooth Animations**: Hover effects and page transitions
- **Professional Images**: High-quality stock photography

### 📊 Portfolio Content
- **26+ Years Experience** highlighted across all sections
- **5 Featured Projects** with detailed business outcomes
- **8 Professional Roles** in experience timeline  
- **6 Anonymous Testimonials** from industry leaders
- **Core Competencies** with expertise level indicators
- **Multi-industry Experience** (Banking, Insurance, Retail, Gaming, etc.)

### 🔧 Technical Stack
- **Frontend**: React 19, React Router, Tailwind CSS, Shadcn/UI
- **Backend**: FastAPI, Python 3.9+, Pydantic, Uvicorn
- **Database**: MongoDB 6.0+ with collections and indexes
- **Development**: Hot reload, auto-restart, comprehensive logging
- **Management**: Custom scripts for easy service control

### 📈 Database Features
- **Schema Validation**: Data integrity with MongoDB validators
- **Performance Indexes**: Optimized queries for all collections
- **Sample Data**: Pre-loaded with realistic test data
- **Collections**: Status checks, contacts, projects, testimonials
- **Security Ready**: Prepared for authentication and access control

## 🛠️ Manual Installation (Advanced)

If you prefer manual control or the automated script fails:

### 1. Install Prerequisites

#### Ubuntu/Debian:
```bash
# System packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget gnupg software-properties-common

# Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Yarn
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -y yarn

# Python 3.9+
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential

# MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update && sudo apt-get install -y mongodb-org
sudo systemctl start mongod && sudo systemctl enable mongod
```

#### macOS:
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew install node yarn python mongodb-community
brew services start mongodb/brew/mongodb-community
```

### 2. Setup Database
```bash
# Initialize database with sample data
mongosh --file updated_init_database.js
```

### 3. Setup Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file
cp .env.example .env  # or create manually
```

### 4. Setup Frontend  
```bash
cd frontend
yarn install

# Create .env file
cp .env.example .env  # or create manually
```

### 5. Start Services
```bash
# Terminal 1 - Backend
cd backend && source venv/bin/activate && uvicorn server:app --host 0.0.0.0 --port 8001 --reload

# Terminal 2 - Frontend  
cd frontend && yarn start
```

## 🔧 Environment Configuration

### Backend (.env)
```bash
# Database
MONGO_URL=mongodb://localhost:27017
DB_NAME=portfolio_db

# Server
HOST=0.0.0.0
PORT=8001
ENVIRONMENT=development
DEBUG=True

# Security
SECRET_KEY=your-secret-key-here

# CORS
ALLOWED_ORIGINS=["http://localhost:3000", "http://127.0.0.1:3000"]
```

### Frontend (.env)
```bash
# Backend API
REACT_APP_BACKEND_URL=http://localhost:8001

# Environment
NODE_ENV=development
PORT=3000
GENERATE_SOURCEMAP=true
BROWSER=none
```

## 📁 Project Structure

```
kamal-singh-portfolio/
├── 📁 backend/                 # FastAPI backend application
│   ├── server.py              # Main FastAPI app
│   ├── requirements.txt       # Python dependencies
│   ├── .env                   # Backend environment variables
│   └── venv/                  # Python virtual environment
├── 📁 frontend/               # React frontend application  
│   ├── 📁 src/
│   │   ├── 📁 components/     # React components
│   │   │   ├── 📁 ui/         # Shadcn/UI components
│   │   │   └── Layout.jsx     # Main layout component
│   │   ├── 📁 pages/          # Page components
│   │   │   ├── AboutPage.jsx
│   │   │   ├── ProjectsPage.jsx
│   │   │   └── ...            # Other page components
│   │   ├── 📁 hooks/          # Custom React hooks
│   │   ├── mock.js            # Portfolio data (5 projects, 8 experiences)
│   │   ├── App.js             # Main React app
│   │   └── index.js           # React entry point
│   ├── package.json           # Node.js dependencies
│   ├── tailwind.config.js     # Tailwind CSS config
│   └── .env                   # Frontend environment variables
├── 📄 install_local.sh        # Complete installation script
├── 📄 start_local.sh          # Start all services
├── 📄 stop_local.sh           # Stop all services  
├── 📄 manage_services.sh      # Service management
├── 📄 updated_init_database.js # Enhanced database setup
└── 📄 README_LOCAL_INSTALL.md # This file
```

## 🚨 Troubleshooting

### Common Issues & Solutions

#### 🔴 Installation Fails
```bash
# Check prerequisites
node --version    # Should be 16+
python3 --version # Should be 3.8+
mongod --version  # Should be 4.4+

# Re-run installation
./install_local.sh
```

#### 🔴 Services Won't Start
```bash
# Check what's running
./manage_services.sh status

# Check for port conflicts
lsof -i :3000  # Frontend port
lsof -i :8001  # Backend port

# Kill conflicting processes
sudo kill -9 <PID>

# Restart services
./manage_services.sh restart
```

#### 🔴 MongoDB Issues
```bash
# Check MongoDB service
# Linux:
sudo systemctl status mongod
sudo systemctl restart mongod

# macOS:
brew services list | grep mongodb
brew services restart mongodb/brew/mongodb-community

# Test connection
mongosh --eval "db.adminCommand('ping')"
```

#### 🔴 Frontend Issues
```bash
cd frontend

# Clear cache and reinstall
rm -rf node_modules package-lock.json yarn.lock
yarn install

# Check for errors
yarn start
```

#### 🔴 Backend Issues
```bash
cd backend

# Check virtual environment
source venv/bin/activate
pip install -r requirements.txt

# Test backend directly
python -c "from server import app; print('✅ Backend OK')"

# Check logs
uvicorn server:app --host 0.0.0.0 --port 8001 --reload
```

### 🔍 Diagnostic Commands
```bash
# System health check
./manage_services.sh status

# View detailed logs
./manage_services.sh logs

# Check database contents
mongosh portfolio_db --eval "show collections"

# Test API endpoints
curl http://localhost:8001/api/
curl http://localhost:8001/api/status
```

## 🔐 Security & Production

### For Development
- Default settings are optimized for local development
- Debug mode enabled for detailed error messages
- CORS configured for localhost access
- No authentication required

### For Production Deployment
Update environment variables:

```bash
# Backend production .env
ENVIRONMENT=production
DEBUG=False
SECRET_KEY=super-secure-production-key
ALLOWED_ORIGINS=["https://yourdomain.com"]
MONGO_URL=mongodb://username:password@server:27017

# Frontend production .env  
REACT_APP_BACKEND_URL=https://api.yourdomain.com
NODE_ENV=production
GENERATE_SOURCEMAP=false
```

## 💼 About Kamal Singh

This portfolio showcases **Kamal Singh**, a seasoned IT Portfolio Architect:

- 📍 **Location**: Amersham, United Kingdom
- 📧 **Email**: chkamalsingh@yahoo.com  
- 📱 **Phone**: 07908 521 588
- 💼 **LinkedIn**: https://linkedin.com/in/kamalsingh-architect
- ⏰ **Availability**: Available for consulting and architecture leadership roles

### Expertise Areas
- 🏢 **Enterprise Architecture** - TOGAF, IASA certified
- ☁️ **Cloud Technologies** - AWS, Azure, GCP certified  
- 🔄 **Digital Transformation** - 26+ years experience
- 🔐 **CIAM/IAM Solutions** - Security architecture expertise
- 🌐 **API-First Design** - Microservices and integration
- 📈 **Leadership** - Team management and governance

### Industry Experience
- 🏦 Banking & Finance
- 🛡️ Insurance
- 🛍️ Retail & eCommerce  
- 🎮 Gaming & Entertainment
- 🏛️ Public Sector
- ⚡ Utilities

## 🆘 Support & Help

### Getting Help
1. **Check the troubleshooting section above**
2. **Run diagnostic commands to identify issues**
3. **Review logs for error messages**
4. **Ensure all prerequisites are properly installed**
5. **Try restarting services or reinstalling**

### Additional Resources
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

---

## 🎉 Success! 

Once everything is running, you'll have a complete professional portfolio showcasing Kamal Singh's 26+ years of IT architecture expertise, featuring 5 detailed projects, 8 professional experiences, and a fully functional contact system.

**Ready to start?** Run `./install_local.sh` and you'll have a professional portfolio running in minutes! 🚀