# Dockerfile for Kamal Singh Portfolio Backend
# Production-ready Python FastAPI application

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p /app/logs

# Create non-root user for security
RUN groupadd -r portfolio \
    && useradd -r -g portfolio -s /bin/bash -c "Portfolio user" portfolio \
    && chown -R portfolio:portfolio /app

# Switch to non-root user
USER portfolio

# Expose port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8001/api/health || exit 1

# Default command
CMD ["python", "-m", "uvicorn", "enhanced_server:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]