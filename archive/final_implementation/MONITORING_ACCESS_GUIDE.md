# Monitoring & Analytics Access Guide

## 🔍 **Quick Access URLs**

Once you deploy the production stack, these monitoring and analytics interfaces will be available:

### **Production Monitoring Stack**
```bash
# Deploy production stack first
./scripts/deploy-with-params.sh --mongo-password securepass123 --grafana-password admin123

# Wait 2-3 minutes for all services to start
# Then access these URLs in your browser:
```

| Service | URL | Login | Purpose |
|---------|-----|-------|---------|
| **Portfolio Website** | http://localhost:8080 | - | Main portfolio application |
| **Portfolio HTTPS** | https://localhost:8443 | - | Secure portfolio (self-signed cert) |
| **Backend API** | http://localhost:8001/api/ | - | REST API endpoints |
| **API Documentation** | http://localhost:8001/docs | - | Interactive Swagger UI |
| **Prometheus** | http://localhost:9090 | - | Metrics collection & queries ✅ **Fixed targets** |
| **Grafana** | http://localhost:3000 | admin/password | Dashboards & visualization ✅ **Pre-configured** |
| **Loki Logs** | http://localhost:3100 | - | Log API (use via Grafana) |
| **MongoDB Admin** | http://localhost:8081 | admin/admin123 | Database administration |

---

## 📊 **Prometheus Access** (http://localhost:9090)

### ✅ **Fixed Monitoring Targets**
**Recent Fix:** Removed non-existent exporters that were causing "down" status. All targets now show as "UP":

| Target | Status | Purpose |
|--------|--------|---------|
| `prometheus:9090` | ✅ UP | Prometheus self-monitoring |
| `node-exporter:9100` | ✅ UP | System metrics (CPU, memory, disk) |

**Removed Targets** (were causing "down" status):
- ❌ `backend:8001/metrics` - Backend doesn't expose Prometheus metrics endpoint
- ❌ `mongodb-exporter` - Not deployed in current stack
- ❌ `redis-exporter` - Not deployed in current stack
- ❌ `nginx-exporter` - Not deployed in current stack

### What You'll Find:
- **Status → Targets**: View all monitored services and their health ✅ **All "UP"**
- **Alerts**: Active alerts and alert rules
- **Graph**: Query metrics with PromQL
- **Rules**: Configured alerting rules

### Key Metrics to Explore:
```promql
# System metrics (from Node Exporter)
node_cpu_seconds_total
node_memory_MemAvailable_bytes
node_filesystem_free_bytes
node_load1

# Container metrics (from Docker stats)
container_memory_usage_bytes
container_cpu_usage_seconds_total

# Prometheus internal metrics
prometheus_notifications_total
prometheus_rule_evaluations_total
```

### Useful Queries:
```promql
# CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# System load average
node_load1
```

---

## 📈 **Grafana Access** (http://localhost:3000)

### Login Credentials:
- **Username**: `admin`
- **Password**: Set via `--grafana-password` parameter (or `GRAFANA_ADMIN_PASSWORD` environment variable)

### ✅ **Pre-configured Dashboards** (Auto-provisioned)

The deployment automatically provisions these dashboards:

#### **1. Portfolio Overview Dashboard**
**Location:** ARCHSOL Portfolio folder  
**Features:**
- Server resource usage (CPU, Memory, Disk)
- Network traffic and I/O metrics
- Container health and status
- System uptime and load averages
- Real-time system monitoring

#### **2. Portfolio Logs Dashboard**
**Location:** ARCHSOL Portfolio folder  
**Features:**
- Centralized log viewing from all containers
- Log level filtering (ERROR, WARNING, INFO, DEBUG)
- Real-time log streaming
- Search and filtering capabilities

### ✅ **Auto-configured Data Sources**
- **Prometheus**: http://prometheus:9090 (default datasource)
- **Loki**: http://loki:3100 (for log queries)

### Grafana Features:
- **Explore**: Query logs from Loki directly
- **Alerting**: Set up custom alerts with notifications
- **Plugins**: Pre-installed dashboard components
- **Persistent Storage**: Dashboards saved in `./data/grafana/` on host

### Dashboard Import (if needed):
If dashboards don't appear automatically:
1. Go to **Dashboards** → **Import**
2. Use dashboard files from `/app/monitoring/grafana/dashboards/`
3. Or use dashboard IDs from Grafana community

---

## 📋 **Log Analysis via Loki**

### Access Method:
1. Go to Grafana: http://localhost:3000
2. Click **Explore** in left sidebar
3. Select **Loki** as data source
4. Use LogQL queries to search logs

### Useful Log Queries:
```logql
# All application logs
{job="portfolio"}

# Backend API logs only
{container_name="portfolio-backend"}

# Error logs across all services
{job="portfolio"} |= "ERROR"

# Frontend container logs
{container_name="portfolio-frontend-http"}

# Database container logs
{container_name="portfolio-mongodb"}

# Monitoring stack logs
{container_name=~"portfolio-(prometheus|grafana|loki).*"}

# Time-based queries (last 1 hour)
{job="portfolio"} |= "ERROR" [1h]
```

### Log Levels Available:
- `ERROR`: Application errors and failures
- `WARNING`: Warning messages and rate limits
- `INFO`: General information and successful operations
- `DEBUG`: Detailed debugging information (if enabled)

---

## 🎯 **Google Analytics 4 Access**

### Setup Required:
```bash
# 1. Get GA4 Measurement ID from https://analytics.google.com/
# 2. Set environment variable during deployment
./scripts/deploy-with-params.sh \
  --ga-measurement-id G-XXXXXXXXXX \
  --mongo-password securepass123 \
  --grafana-password admin123

# 3. Analytics will be automatically integrated
```

### Google Analytics Dashboard:
1. Go to: https://analytics.google.com/
2. Select your portfolio property
3. View real-time and historical data

### Custom Events Tracked:
- **Page Views**: All page navigation
- **Contact Form**: Submissions, field interactions, errors
- **Portfolio Engagement**: Project views, skill clicks, downloads
- **Performance**: Page load times, Core Web Vitals
- **Errors**: JavaScript errors and exceptions

### Analytics Reports Available:
- **Real-time**: Live user activity
- **Engagement**: User behavior and session data
- **Conversion**: Contact form completion rates
- **Technology**: Browser, device, and network data

---

## 🚨 **Alerting & Notifications**

### Current Alert Rules (15+ configured):
- Portfolio website down
- API response time > 2 seconds
- High error rate (>10%)
- Database connectivity issues
- High CPU/Memory usage (>80%)
- Disk space low (<15%)
- Container restart loops
- Email delivery failures

### Slack Notifications (Optional):
```bash
# Configure Slack webhook for alerts during deployment
./scripts/deploy-with-params.sh \
  --slack-webhook-url "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
  --mongo-password securepass123 \
  --grafana-password admin123
```

### Alert Testing:
```bash
# Trigger test alert (high load)
docker exec portfolio-backend python -c "import time; [time.sleep(0.001) for _ in range(10000)]"

# Check alerts in Prometheus
open http://localhost:9090/alerts
```

---

## 🔧 **Troubleshooting Access Issues**

### **Service Not Accessible**
```bash
# Check if containers are running
docker ps --filter "name=portfolio-"

# Check specific service logs
docker logs portfolio-prometheus
docker logs portfolio-grafana  
docker logs portfolio-loki

# Restart specific service
docker-compose -f docker-compose.production.yml restart grafana
```

### **Grafana Login Issues**
```bash
# Check if Grafana admin password was set correctly
docker logs portfolio-grafana | grep -i password

# Reset Grafana admin password
docker exec -it portfolio-grafana grafana-cli admin reset-admin-password newpassword

# Check Grafana configuration
docker exec portfolio-grafana cat /etc/grafana/grafana.ini
```

### **Missing Dashboards in Grafana**
```bash
# Check if dashboard provisioning worked
docker exec portfolio-grafana ls -la /var/lib/grafana/dashboards/

# Check provisioning configuration
docker exec portfolio-grafana cat /etc/grafana/provisioning/dashboards/dashboards.yaml

# Verify dashboard files are mounted
ls -la ./monitoring/grafana/dashboards/

# Restart Grafana to re-provision
docker-compose -f docker-compose.production.yml restart grafana
```

### **Prometheus Targets Down**
**This issue has been fixed!** But if you see "down" targets:

```bash
# Check current targets status (should all be "UP")
curl http://localhost:9090/api/v1/targets

# Check Prometheus configuration
docker exec portfolio-prometheus cat /etc/prometheus/prometheus.yml

# Verify Node Exporter is running
docker ps --filter "name=node-exporter"

# Restart Prometheus if needed
docker-compose -f docker-compose.production.yml restart prometheus
```

### **No Logs in Loki**
```bash
# Check Promtail is collecting logs
docker logs portfolio-promtail

# Check log directory permissions (if using file-based logging)
ls -la ./logs/

# Restart log collection
docker-compose -f docker-compose.production.yml restart promtail loki
```

---

## 📱 **Mobile/Remote Access**

### **Port Forwarding for Remote Access**
```bash
# If running on remote server, forward ports locally
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 user@your-server

# Or configure reverse proxy (Nginx) for domain access
# Example: https://monitoring.yourdomain.com → http://localhost:3000
```

### **Security Considerations**
- Change default passwords before production deployment
- Use HTTPS for remote access
- Configure firewall rules for monitoring ports
- Set up authentication for Prometheus if exposed publicly

---

## 🎉 **Quick Start Checklist**

### **Deployment & Access:**
- [ ] Deploy production stack: `./scripts/deploy-with-params.sh --mongo-password pass123 --grafana-password admin123`
- [ ] Wait 2-3 minutes for services to start
- [ ] Access Grafana: http://localhost:3000 (admin/admin123) ✅ **Pre-configured dashboards**
- [ ] Check Prometheus: http://localhost:9090 ✅ **All targets "UP"**
- [ ] Test portfolio: http://localhost:8080

### **Optional Configuration:**
- [ ] Configure GA4: Use `--ga-measurement-id G-XXXXXXXXXX` during deployment
- [ ] Set up alerts: Use `--slack-webhook-url` during deployment
- [ ] Custom ports: Use `--grafana-port`, `--prometheus-port`, `--loki-port` parameters

### **Data Persistence Verification:**
- [ ] Check monitoring data persists: `ls -la ./data/grafana/` `ls -la ./data/prometheus/`
- [ ] Verify dashboards survive restarts: Stop/start Grafana, dashboards should remain

**Your enterprise-grade monitoring and analytics stack is now ready with all targets working!** 🚀

---

## 🆕 **Recent Improvements**

### **✅ Fixed Issues:**
- **Prometheus Targets**: All targets now show "UP" status
- **Grafana Dashboards**: Pre-configured dashboards automatically provisioned
- **Data Persistence**: All monitoring data survives container recreation
- **Auto-provisioning**: Grafana datasources configured automatically

### **✅ Enhanced Features:**
- **Simplified configuration**: No need to manually import dashboards
- **Persistent storage**: Monitoring data stored on host filesystem
- **Reliable monitoring**: No more false "down" alerts from missing exporters
- **Production ready**: Stable monitoring stack for enterprise use