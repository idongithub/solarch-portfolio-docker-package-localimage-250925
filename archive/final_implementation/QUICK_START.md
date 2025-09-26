# 🚀 Kamal Singh Portfolio - Quick Start Guide

## 🎯 GitHub Deployment (One-Command Setup)

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/kamal-singh-portfolio.git
cd kamal-singh-portfolio

# 2. Run automated setup
chmod +x setup.sh
./setup.sh

# 3. Start the application
./start_portfolio.sh
```

This automatically installs all dependencies and configures the environment.

## 🏃‍♂️ Start the Application

```bash
# Start both frontend and backend
./start_portfolio.sh
```

## 🌐 Access Your Portfolio

- **Portfolio Website**: http://localhost:3000
- **API Documentation**: http://localhost:8001/docs

## 📱 Available Pages

| Page | URL | Description |
|------|-----|-------------|
| 🏠 Home | http://localhost:3000/ | Professional introduction with animated hero |
| 👤 About | http://localhost:3000/about | Career journey and leadership philosophy |
| 🛠️ Skills | http://localhost:3000/skills | Interactive competencies with star ratings |
| 💼 Experience | http://localhost:3000/experience | Professional timeline with achievements |
| 🚀 Projects | http://localhost:3000/projects | Featured portfolio with business impact |
| 📞 Contact | http://localhost:3000/contact | Professional contact form |

## 🛑 Stop the Application

```bash
./stop_portfolio.sh
```

## 📋 What You Get

### ✨ Professional Design
- **Corporate Theme**: Navy, charcoal, gold color scheme
- **Professional Typography**: Georgia serif fonts
- **Responsive Layout**: Works on all devices
- **Smooth Animations**: Hover effects and transitions

### 💼 Portfolio Content
- **26+ Years Experience** highlighted
- **Core Competencies** with expertise levels
- **Professional Timeline** with achievements
- **Featured Projects** with business outcomes
- **Client Testimonials** from industry leaders
- **Contact Form** with project type selection

### 🔧 Technical Stack
- **Frontend**: React 19, Tailwind CSS, Shadcn/UI
- **Backend**: FastAPI, MongoDB, Python
- **Features**: Multi-page navigation, interactive elements

## 🆘 Quick Troubleshooting

### If Something Doesn't Work:

1. **Check Prerequisites**:
   ```bash
   node --version  # Should be 16+
   python3 --version  # Should be 3.8+
   mongod --version  # Should be 4.4+
   ```

2. **Restart Services**:
   ```bash
   ./stop_portfolio.sh
   ./start_portfolio.sh
   ```

3. **Reset Everything**:
   ```bash
   ./stop_portfolio.sh
   ./setup.sh
   ./start_portfolio.sh
   ```

## 📞 Professional Contact

This portfolio showcases **Kamal Singh**:
- **IT Portfolio Architect** with 26+ years experience
- **Location**: Amersham, United Kingdom
- **Email**: chkamalsingh@yahoo.com
- **Phone**: 07908 521 588
- **Specialties**: Enterprise Architecture, Digital Transformation, Cloud Migration

---

**Need detailed setup instructions?** → See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)  
**Having issues?** → Check the troubleshooting section in [README.md](README.md)