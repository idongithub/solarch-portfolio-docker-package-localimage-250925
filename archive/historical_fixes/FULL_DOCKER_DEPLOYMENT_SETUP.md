# Full Docker-Based Deployment Setup Guide

## Prerequisites Installation

### 1. Install Docker on Ubuntu
```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt update

# Install Docker CE
sudo apt install docker-ce docker-ce-cli containerd.io

# Add your user to docker group (avoid using sudo)
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. Install Docker Compose
```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 3. Logout and Login Again
```bash
# This is required for the docker group changes to take effect
logout
# Then log back in
```

## Full Docker Deployment

### 1. Stop Supervisor Services (If Running)
```bash
# Stop any running supervisor services to free up ports
sudo supervisorctl stop all
```

### 2. Deploy Full Docker Stack
```bash
cd /path/to/your/portfolio/app

# Run your deployment command
./scripts/deploy-with-params.sh \
  --http-port 3400 \
  --https-port 3443 \
  --backend-port 3001 \
  --smtp-server smtp.ionos.co.uk \
  --smtp-port 465 \
  --smtp-username kamal.singh@architecturesolutions.co.uk \
  --smtp-password NewPass6 \
  --from-email kamal.singh@architecturesolutions.co.uk \
  --to-email kamal.singh@architecturesolutions.co.uk \
  --smtp-use-tls true \
  --ga-measurement-id G-B2W705K4SN \
  --mongo-express-port 3081 \
  --mongo-express-username admin \
  --mongo-express-password admin123 \
  --mongo-port 37037 \
  --mongo-username admin \
  --mongo-password securepass123 \
  --grafana-password adminpass123 \
  --redis-password redispass123 \
  --grafana-port 3030 \
  --loki-port 3300 \
  --prometheus-port 3091
```

## Expected Docker Services

After successful deployment, you should have these Docker containers:

### Core Application:
- **portfolio-frontend-http** - HTTP frontend on port 3400
- **portfolio-frontend-https** - HTTPS frontend on port 3443
- **portfolio-backend** - FastAPI backend on port 3001

### Database Services:
- **portfolio-mongodb** - MongoDB on port 37037
- **portfolio-mongo-express** - MongoDB admin UI on port 3081
- **portfolio-redis** - Redis cache on port 6379

### Monitoring Stack:
- **portfolio-prometheus** - Metrics collection on port 3091
- **portfolio-grafana** - Dashboards on port 3030
- **portfolio-loki** - Log aggregation on port 3300
- **portfolio-promtail** - Log shipping
- **portfolio-node-exporter** - System metrics

### Support Services:
- **portfolio-backup** - Automated database backups

## Verification Commands

### 1. Check Container Status
```bash
# View all containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check for unhealthy containers
docker ps --filter "health=unhealthy"

# Check container logs
docker logs portfolio-backend
docker logs portfolio-mongodb
docker logs portfolio-mongo-express
```

### 2. Test Service URLs
```bash
# Frontend
curl http://localhost:3400/
curl -k https://localhost:3443/

# Backend API
curl http://localhost:3001/api/health
curl http://localhost:3001/docs

# Database Admin
curl http://localhost:3081/

# Monitoring
curl http://localhost:3030/  # Grafana
curl http://localhost:3091/  # Prometheus
curl http://localhost:3300/ready  # Loki
```

### 3. Access in Browser
- **Portfolio HTTP**: http://localhost:3400
- **Portfolio HTTPS**: https://localhost:3443
- **Backend API Docs**: http://localhost:3001/docs
- **Mongo Express**: http://localhost:3081 (admin/admin123)
- **Grafana**: http://localhost:3030 (admin/adminpass123)
- **Prometheus**: http://localhost:3091
- **Loki**: http://localhost:3300

## Troubleshooting Common Issues

### 1. Port Conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :3001
sudo netstat -tulpn | grep :3400

# Stop conflicting services
sudo supervisorctl stop backend
sudo supervisorctl stop frontend
```

### 2. Container Health Issues
```bash
# Check container health
docker inspect portfolio-backend | grep Health -A 10

# Check specific container logs
docker logs --tail 50 portfolio-backend
docker logs --tail 50 portfolio-mongodb
```

### 3. MongoDB Authentication Issues
```bash
# Test MongoDB connection
docker exec portfolio-mongodb mongosh --username admin --password securepass123 --eval "db.adminCommand('ping')"
```

### 4. Clean Restart
```bash
# Stop all containers
docker-compose -f docker-compose.production.yml down

# Remove all containers and networks
docker-compose -f docker-compose.production.yml down --remove-orphans

# Restart deployment
./scripts/deploy-with-params.sh [your-parameters]
```

## Docker Environment Benefits

### Full Service Stack:
✅ **Complete monitoring** with Prometheus, Grafana, Loki  
✅ **Database admin interface** with Mongo Express  
✅ **Automated backups** and log aggregation  
✅ **SSL/HTTPS support** with certificate generation  
✅ **Service isolation** with proper networking  
✅ **Health monitoring** and automatic restarts  
✅ **Scalable architecture** ready for production  

### vs Supervisor Setup:
- **More services**: Monitoring stack, database admin, backups
- **Better isolation**: Each service in its own container
- **Production ready**: Health checks, networking, volumes
- **Easier management**: Single docker-compose command
- **Port flexibility**: All ports customizable

## Next Steps

1. **Install Docker** and Docker Compose on your Ubuntu machine
2. **Stop supervisor services** to free up ports
3. **Run the deployment command** with your parameters
4. **Verify all containers** are healthy and accessible
5. **Test all service URLs** in your browser

The full Docker deployment will give you the complete enterprise-grade portfolio infrastructure with monitoring, database admin, and all the advanced features.