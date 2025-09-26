# Makefile for Kamal Singh Portfolio
# Provides convenient commands for Docker deployment and management

.PHONY: help setup start stop restart logs clean build test deploy-dev deploy-prod

# Default target
help:
	@echo "Kamal Singh Portfolio - Docker Commands"
	@echo "======================================"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup       - Initial setup (copy env files, build images)"
	@echo "  make build       - Build all Docker images"
	@echo ""
	@echo "Development Commands:"
	@echo "  make start       - Start all services"
	@echo "  make stop        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - View all service logs"
	@echo "  make logs-f      - Follow all service logs"
	@echo ""
	@echo "Individual Service Commands:"
	@echo "  make logs-backend    - View backend logs"
	@echo "  make logs-frontend   - View frontend logs"
	@echo "  make logs-mongodb    - View MongoDB logs"
	@echo "  make shell-backend   - Access backend container shell"
	@echo "  make shell-frontend  - Access frontend container shell"
	@echo "  make shell-mongodb   - Access MongoDB shell"
	@echo ""
	@echo "Maintenance Commands:"
	@echo "  make clean       - Clean up containers and images"
	@echo "  make reset       - Reset everything (clean + rebuild)"
	@echo "  make backup      - Backup database"
	@echo "  make test        - Run health checks"
	@echo ""
	@echo "Production Commands:"
	@echo "  make deploy-prod - Deploy with production settings"
	@echo "  make status      - Check service status"

# Setup commands
setup:
	@echo "🚀 Setting up Kamal Singh Portfolio..."
	@if [ ! -f .env.docker ]; then \
		echo "📋 Creating environment file..."; \
		cp .env.docker.example .env.docker; \
		echo "⚠️  Please edit .env.docker with your configuration"; \
	fi
	@echo "🏗️  Building Docker images..."
	@docker-compose --env-file .env.docker build
	@echo "✅ Setup complete! Run 'make start' to start services."

build:
	@echo "🏗️  Building Docker images..."
	@docker-compose --env-file .env.docker build --no-cache

# Service management
start:
	@echo "🚀 Starting Kamal Singh Portfolio services..."
	@docker-compose --env-file .env.docker up -d
	@echo "✅ Services started successfully!"
	@echo ""
	@echo "📍 Access URLs:"
	@echo "  🌐 Portfolio: http://localhost:3000"
	@echo "  🔧 Backend API: http://localhost:8001"
	@echo "  📚 API Docs: http://localhost:8001/docs"
	@echo ""
	@echo "📊 Run 'make status' to check service health"

stop:
	@echo "🛑 Stopping services..."
	@docker-compose down
	@echo "✅ Services stopped"

restart:
	@echo "🔄 Restarting services..."
	@docker-compose --env-file .env.docker restart
	@echo "✅ Services restarted"

# Logging
logs:
	@docker-compose logs --tail=100

logs-f:
	@docker-compose logs -f

logs-backend:
	@docker-compose logs -f backend

logs-frontend:
	@docker-compose logs -f frontend

logs-mongodb:
	@docker-compose logs -f mongodb

# Shell access
shell-backend:
	@docker-compose exec backend bash

shell-frontend:
	@docker-compose exec frontend sh

shell-mongodb:
	@docker-compose exec mongodb mongosh -u admin -p

# Maintenance
clean:
	@echo "🧹 Cleaning up containers and images..."
	@docker-compose down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup complete"

reset: clean build
	@echo "🔄 Reset complete! Run 'make start' to start fresh."

backup:
	@echo "💾 Creating database backup..."
	@mkdir -p ./backups
	@docker-compose exec mongodb mongodump --uri="mongodb://$(shell grep MONGO_ROOT_USERNAME .env.docker | cut -d '=' -f2):$(shell grep MONGO_ROOT_PASSWORD .env.docker | cut -d '=' -f2)@localhost:27017/$(shell grep DB_NAME .env.docker | cut -d '=' -f2)?authSource=admin" --out=/tmp/backup
	@docker cp portfolio_mongodb:/tmp/backup ./backups/backup_$(shell date +%Y%m%d_%H%M%S)
	@echo "✅ Backup created in ./backups/"

# Testing and status
test:
	@echo "🔍 Running health checks..."
	@echo "Testing frontend..."
	@curl -f http://localhost:3000/health > /dev/null 2>&1 && echo "✅ Frontend: Healthy" || echo "❌ Frontend: Unhealthy"
	@echo "Testing backend..."
	@curl -f http://localhost:8001/api/health > /dev/null 2>&1 && echo "✅ Backend: Healthy" || echo "❌ Backend: Unhealthy"
	@echo "Testing MongoDB..."
	@docker-compose exec mongodb mongosh --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1 && echo "✅ MongoDB: Healthy" || echo "❌ MongoDB: Unhealthy"

status:
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "💻 Resource Usage:"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Production deployment
deploy-prod:
	@echo "🚀 Deploying with production configuration..."
	@docker-compose --env-file .env.docker --profile production up -d
	@echo "✅ Production deployment complete!"
	@echo ""
	@echo "📍 Production Access URLs:"
	@echo "  🌐 Frontend: http://localhost (via Nginx)"
	@echo "  🔧 Backend API: http://localhost/api"
	@echo ""

# Development helpers
dev-setup:
	@echo "🛠️  Setting up development environment..."
	@make setup
	@echo "📦 Installing local dependencies..."
	@cd backend && python -m venv venv && . venv/bin/activate && pip install -r requirements.txt
	@cd frontend && yarn install
	@echo "✅ Development setup complete!"

update:
	@echo "🔄 Updating application..."
	@git pull origin main
	@docker-compose --env-file .env.docker build --no-cache
	@docker-compose --env-file .env.docker up -d
	@echo "✅ Update complete!"

# Email testing
test-email:
	@echo "📧 Testing email functionality..."
	@curl -X POST http://localhost:8001/api/test-email \
		-H "Authorization: Bearer $(shell grep ADMIN_TOKEN .env.docker | cut -d '=' -f2)" \
		-H "Content-Type: application/json" \
		&& echo "✅ Email test completed" || echo "❌ Email test failed"

# Security
security-scan:
	@echo "🔒 Running security scans..."
	@docker scout cves portfolio_backend || echo "Docker Scout not available"
	@docker scout cves portfolio_frontend || echo "Docker Scout not available"

# Documentation
docs:
	@echo "📚 Portfolio Documentation"
	@echo "=========================="
	@echo ""
	@echo "📁 Available Documentation:"
	@echo "  - README_LOCAL_INSTALL.md    - Local installation guide"
	@echo "  - DOCKER_DEPLOYMENT_GUIDE.md - Docker deployment guide"
	@echo "  - QUICK_START_LOCAL.md       - Quick start guide"
	@echo ""
	@echo "📖 API Documentation: http://localhost:8001/docs (when running)"