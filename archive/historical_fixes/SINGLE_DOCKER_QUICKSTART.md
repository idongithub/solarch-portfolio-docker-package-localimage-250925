# 🐳 Kamal Singh Portfolio - Single Docker Container

## ⚡ Ultra-Quick Start

Get the complete Kamal Singh Portfolio running in **one container** with **one command**:

### 1. Build the Image
```bash
./build-single-image.sh
```

### 2. Run the Container
```bash
# Without email (demo mode)
./run-portfolio.sh

# With email functionality
./run-portfolio.sh your-email@gmail.com your-app-password
```

### 3. Access Portfolio
**🌐 http://localhost** - Your portfolio is live!

---

## 🎯 What You Get

✅ **Complete Portfolio** - Frontend + Backend + Database in one container  
✅ **Email Contact Form** - Professional emails sent to kamal.singh@architecturesolutions.co.uk  
✅ **5 Featured Projects** - Showcasing 26+ years of IT architecture expertise  
✅ **Professional Design** - Corporate theme with modern UI  
✅ **Production Ready** - SSL support, security headers, health checks  

---

## 📦 Container Contents

| Service | Port | Purpose |
|---------|------|---------|
| **Nginx** | 80, 443 | Web server + reverse proxy |
| **React Frontend** | Internal | Portfolio website |
| **FastAPI Backend** | Internal | API + email service |
| **MongoDB** | Internal | Database with sample data |

---

## 🚀 Deployment Options

### Local Development
```bash
docker run -d -p 80:80 --name portfolio kamal-singh-portfolio:latest
```

### Production with Email
```bash
docker run -d -p 80:80 -p 443:443 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  --name portfolio \
  kamal-singh-portfolio:latest
```

### Custom Domain
```bash
docker run -d -p 80:80 -p 443:443 \
  -e SMTP_USERNAME=your-email@gmail.com \
  -e SMTP_PASSWORD=your-app-password \
  -e WEBSITE_URL=https://yourdomain.com \
  --name portfolio \
  kamal-singh-portfolio:latest
```

---

## 📧 Email Setup (Gmail)

1. **Enable 2-Factor Authentication** on Gmail
2. **Generate App Password**:
   - Google Account → Security → 2-Step Verification → App passwords
3. **Use in deployment**:
   ```bash
   ./run-portfolio.sh youremail@gmail.com abcdwxyzabcdwxyz
   ```

---

## 🛠️ Container Management

```bash
# View logs
docker logs portfolio

# Stop/start
docker stop portfolio
docker start portfolio

# Remove
docker rm portfolio

# Health check
docker exec portfolio /app/healthcheck.sh
```

---

## 🎉 Ready to Deploy!

Your **complete professional portfolio** is now packaged in a single Docker image:

- **Showcase** 26+ years of IT architecture expertise
- **Capture leads** with functional contact form
- **Deploy anywhere** Docker runs
- **Professional appearance** with corporate branding

**Perfect for consultants, architects, and IT professionals! 🚀**