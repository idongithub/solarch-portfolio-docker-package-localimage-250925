# System Architecture - Final Implementation

## 🏗️ **Production Architecture Overview**

This document describes the **final implemented architecture** featuring intelligent dual security, Kong API Gateway integration, and comprehensive monitoring for the Kamal Singh Portfolio Platform.

## 🌐 **High-Level System Architecture**

```mermaid
graph TB
    subgraph "User Access Layer"
        U1[Local HTTP Users<br/>192.168.86.75:3400]
        U2[Local HTTPS Users<br/>192.168.86.75:3443] 
        U3[Domain Users<br/>portfolio.architecturesolutions.co.uk]
    end
    
    subgraph "Enhanced Security Layer"
        S1[Origin Validation<br/>Whitelist Enforcement]
        S2[Browser Detection<br/>User-Agent Analysis]
        S3[API Authentication<br/>Credential Validation]
        S4[Auto-Detection Logic<br/>IP vs Domain Analysis]
        S5[Local Math Captcha<br/>Privacy-First Security]
        S6[Google reCAPTCHA v3<br/>Enterprise Security]
    end
    
    subgraph "API Gateway & Proxy Layer"
        G1[Direct HTTP Access<br/>No Proxy Required]
        G2[Kong API Gateway<br/>HTTPS Proxy + CORS]
        G3[Traefik Load Balancer<br/>SSL + API Auth]
    end
    
    subgraph "Application Layer"
        A1[React Frontend<br/>Intelligent Routing]
        A2[FastAPI Backend<br/>Dual Verification Engine]
        A3[Nginx Web Server<br/>Security Headers + CSP]
    end
    
    subgraph "Data & Storage Layer"
        D1[MongoDB Database<br/>Contact & Analytics Data]
        D2[Redis Cache<br/>Sessions & Rate Limiting]
        D3[Volume Persistence<br/>Data Retention]
        D4[Mongo Express GUI<br/>Database Administration]
    end
    
    subgraph "Analytics & Tracking"
        T1[Google Analytics<br/>User Behavior Tracking]
        T2[Matomo Analytics<br/>Privacy-First Tracking]
        T3[Frontend Integration<br/>index.html Tracking Scripts]
    end
    
    subgraph "External Services"
        E1[IONOS SMTP Server<br/>Email Delivery]
        E2[Google reCAPTCHA API<br/>Token Verification]
        E3[DNS Provider<br/>Domain Resolution]
        E4[Google Analytics API<br/>Measurement ID: G-B2W705K4SN]
        E5[Matomo Instance<br/>matomo.architecturesolutions.co.uk]
    end
    
    subgraph "Monitoring & Observability"
        M1[Prometheus<br/>Metrics Collection]
        M2[Grafana<br/>Dashboards & Alerts]
        M3[Loki<br/>Log Aggregation]
        M4[Promtail<br/>Log Shipping]
    end
    
    %% Enhanced Security Flow Connections
    U1 --> S1 --> S2 --> S3 --> S4 --> S5 --> G1 --> A1
    U2 --> S1 --> S2 --> S3 --> S4 --> S5 --> G2 --> A1
    U3 --> S1 --> S2 --> S3 --> S4 --> S6 --> G3 --> A1
    
    %% Application Flow
    A1 --> A2 --> D1
    A3 --> A1
    
    %% External Service Connections
    A2 --> E1
    A2 --> E2
    U3 --> E3
    
    %% Monitoring Connections
    A2 -.-> M1
    G2 -.-> M1
    G3 -.-> M1
    A2 -.-> M4
    M1 --> M2
    M4 --> M3
    M3 --> M2
    
    %% Styling
    style S1 fill:#e1f5fe
    style S2 fill:#e8f5e8
    style S3 fill:#fff3e0
    style G2 fill:#f3e5f5
    style A1 fill:#e0f2f1
```

## 🔀 **Access Method Detection & Routing**

### **Frontend Intelligence Engine**
```javascript
// Core detection logic implemented in SimpleContact.jsx
const detectAccessMethod = () => {
  const hostname = window.location.hostname;
  const protocol = window.location.protocol;
  
  // IP Address Pattern Detection
  const isIPAddress = hostname.match(/^\d+\.\d+\.\d+\.\d+$/);
  const isLocalhost = hostname === 'localhost' || hostname === '127.0.0.1';
  
  if (isIPAddress || isLocalhost) {
    // Local Access Mode
    return {
      mode: 'local',
      captcha: 'math',
      routing: protocol === 'https:' ? 'kong' : 'direct',
      backend: protocol === 'https:' 
        ? `https://${KONG_HOST}:${KONG_PORT}` 
        : `http://${hostname}:3001`,
      authentication: false
    };
  }
  
  // Domain Access Mode  
  return {
    mode: 'domain',
    captcha: 'recaptcha',
    routing: 'traefik', 
    backend: `https://${hostname}`,
    authentication: true
  };
};
```

### **Routing Decision Matrix**
| Access URL | Detection | Captcha | Gateway | Backend Route | Authentication |
|------------|-----------|---------|---------|---------------|----------------|
| `http://192.168.86.75:3400` | IP + HTTP | Math | Direct | `http://192.168.86.75:3001` | None |
| `https://192.168.86.75:3443` | IP + HTTPS | Math | Kong | `https://192.168.86.75:8443` | None |
| `https://portfolio.architecturesolutions.co.uk` | Domain | reCAPTCHA | Traefik | `https://portfolio.architecturesolutions.co.uk` | API Key |

## 🛡️ **Dual Security Implementation**

### **Local Math Captcha System**
```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant M as Math Generator
    participant B as Backend
    participant DB as MongoDB
    
    U->>F: Access IP-based URL
    F->>F: Detect local access mode
    F->>M: Generate math question
    M->>M: Create: "7 + 3 = ?"
    M->>F: Display question + answer validation
    U->>F: Enter answer "10"
    F->>F: Validate answer locally
    F->>B: Submit with local_captcha JSON
    B->>B: Verify JSON structure & log
    B->>DB: Store contact data
    B->>F: Return success response
    F->>U: Show success message
```

#### **Math Captcha Features**
- **Question Types**: Addition, Subtraction, Multiplication
- **Difficulty Range**: Numbers 1-10 for user-friendliness
- **Validation**: Both frontend and backend verification
- **Session Tracking**: Unique captcha IDs per submission
- **Refresh Capability**: New questions on demand

#### **Implementation Details**
```javascript
// Math captcha generation logic
const generateMathCaptcha = () => {
  const operations = ['+', '-', '×'];
  const num1 = Math.floor(Math.random() * 10) + 1;
  const num2 = Math.floor(Math.random() * 10) + 1;
  const operation = operations[Math.floor(Math.random() * operations.length)];
  
  let answer, question;
  switch(operation) {
    case '+':
      answer = num1 + num2;
      question = `${num1} + ${num2}`;
      break;
    case '-':
      const larger = Math.max(num1, num2);
      const smaller = Math.min(num1, num2);
      answer = larger - smaller;
      question = `${larger} - ${smaller}`;
      break;
    case '×':
      answer = num1 * num2;
      question = `${num1} × ${num2}`;
      break;
  }
  
  return { question, answer, id: Date.now() };
};
```

### **Google reCAPTCHA v3 System**
```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant G as Google API
    participant B as Backend
    participant DB as MongoDB
    
    U->>F: Access domain URL
    F->>F: Detect domain access mode
    F->>G: Load reCAPTCHA script
    G->>F: Script ready + API available
    U->>F: Submit form
    F->>G: Execute reCAPTCHA (action: contact_form)
    G->>F: Return token + confidence score
    F->>B: Submit with recaptcha_token
    B->>G: Verify token with secret key
    G->>B: Return validation + score
    B->>B: Check score >= 0.5 threshold
    B->>DB: Store contact data
    B->>F: Return success response
    F->>U: Show success message
```

#### **reCAPTCHA Configuration**
- **Version**: reCAPTCHA v3 (invisible)
- **Site Key**: `6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM`
- **Action**: `contact_form`
- **Score Threshold**: 0.5 (configurable)
- **Timeout**: 30 seconds for token generation

## 🌉 **Kong API Gateway Architecture**

### **Kong Service Configuration**
```yaml
# Production Kong Setup for Portfolio Application
services:
  - name: portfolio-backend
    url: http://192.168.86.75:3001
    protocol: http
    connect_timeout: 60000
    write_timeout: 60000
    read_timeout: 60000

routes:
  - name: portfolio-api-route
    service: portfolio-backend
    protocols: ["https"]
    hosts: ["192.168.86.75"]
    paths: ["/api"]
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    strip_path: false
    preserve_host: false

plugins:
  # CORS Plugin for Local HTTPS Frontend
  - name: cors
    service: portfolio-backend
    config:
      origins: ["https://192.168.86.75:3443"]
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
      headers: ["Accept", "Content-Type", "Authorization", "X-Requested-With"]
      credentials: true
      
  # Response Transformation for Additional CORS
  - name: response-transformer
    service: portfolio-backend
    config:
      add:
        headers: ["Access-Control-Allow-Origin:*"]
```

### **Kong Request Flow**
```mermaid
graph LR
    A[HTTPS Frontend<br/>192.168.86.75:3443] --> B[Kong Gateway<br/>192.168.86.75:8443]
    B --> C[CORS Plugin<br/>Origin Validation]
    C --> D[Response Transform<br/>Header Addition]
    D --> E[Portfolio Backend<br/>192.168.86.75:3001]
    E --> F[FastAPI Processing]
    F --> G[MongoDB Storage]
    
    B --> H[Admin API<br/>192.168.86.75:8001]
    B --> I[Manager GUI<br/>192.168.86.75:8002]
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style E fill:#e8f5e8
```

## 🔒 **Traefik Load Balancer Architecture**

### **Production Domain Configuration**
```yaml
# Traefik Dynamic Configuration for Domain Access
http:
  routers:
    portfolio-frontend:
      rule: "Host(`portfolio.architecturesolutions.co.uk`)"
      service: frontend-service
      middlewares: ["secure-headers"]
      tls:
        certResolver: "letsencrypt"
        
    portfolio-api:
      rule: "Host(`portfolio.architecturesolutions.co.uk`) && PathPrefix(`/api`)"
      service: backend-service
      middlewares: ["api-auth", "secure-headers"]
      tls:
        certResolver: "letsencrypt"
        
  services:
    frontend-service:
      loadBalancer:
        servers:
          - url: "http://192.168.86.75:3000"
          
    backend-service:
      loadBalancer:
        servers:
          - url: "http://192.168.86.75:3001"
          
  middlewares:
    api-auth:
      headers:
        customRequestHeaders:
          X-API-Key: "${API_KEY}"
          
    secure-headers:
      headers:
        customRequestHeaders:
          X-Frame-Options: "DENY"
          X-Content-Type-Options: "nosniff"
```

## 🔧 **Environment Variable Architecture**

### **Build-Time Injection System**
```dockerfile
# Dockerfile.https.optimized - Environment Variable Injection
FROM node:18-alpine as build-stage

# Build arguments for all environment variables
ARG REACT_APP_BACKEND_URL=http://localhost:8001
ARG REACT_APP_KONG_HOST=192.168.86.75
ARG REACT_APP_KONG_PORT=8443
ARG REACT_APP_BACKEND_URL_HTTP=http://192.168.86.75:3001
ARG REACT_APP_RECAPTCHA_SITE_KEY=6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM

# Environment variables for React build
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL
ENV REACT_APP_KONG_HOST=$REACT_APP_KONG_HOST
ENV REACT_APP_KONG_PORT=$REACT_APP_KONG_PORT
ENV REACT_APP_BACKEND_URL_HTTP=$REACT_APP_BACKEND_URL_HTTP
ENV REACT_APP_RECAPTCHA_SITE_KEY=$REACT_APP_RECAPTCHA_SITE_KEY

# Build application with injected variables
RUN npm run build
```

### **Docker Compose Integration**
```yaml
# docker-compose.production.yml - Build Arguments
services:
  frontend-https:
    build:
      context: .
      dockerfile: Dockerfile.https.optimized
      args:
        REACT_APP_BACKEND_URL: ${REACT_APP_BACKEND_URL}
        REACT_APP_KONG_HOST: ${REACT_APP_KONG_HOST}
        REACT_APP_KONG_PORT: ${REACT_APP_KONG_PORT}
        REACT_APP_BACKEND_URL_HTTP: ${REACT_APP_BACKEND_URL_HTTP}
        REACT_APP_RECAPTCHA_SITE_KEY: ${REACT_APP_RECAPTCHA_SITE_KEY}
```

### **Deployment Script Variable Export**
```bash
# deploy-with-params.sh - Environment Variable Export
export REACT_APP_BACKEND_URL="https://portfolio.architecturesolutions.co.uk"
export REACT_APP_KONG_HOST="192.168.86.75"
export REACT_APP_KONG_PORT="8443"
export REACT_APP_BACKEND_URL_HTTP="http://192.168.86.75:3001"
export REACT_APP_RECAPTCHA_SITE_KEY="6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM"
```

## 📊 **Data Flow Architecture**

### **Contact Form Processing Flow**
```mermaid
graph TB
    A[User Submits Form] --> B{Access Method Detection}
    
    B -->|Local Access| C[Math Captcha Validation]
    B -->|Domain Access| D[reCAPTCHA Token Verification]
    
    C --> E[Frontend Local Validation]
    D --> F[Google API Verification]
    
    E --> G[Backend JSON Parsing]
    F --> H[Backend Score Validation]
    
    G --> I[Rate Limiting Check]
    H --> I
    
    I --> J[Honeypot Field Validation]
    J --> K[Input Sanitization]
    K --> L[Email Template Generation]
    L --> M[IONOS SMTP Delivery]
    M --> N[MongoDB Data Storage]
    N --> O[Analytics Update]
    O --> P[Response to User]
    
    %% Error Paths
    C -->|Invalid| Q[Error Response]
    F -->|Score < 0.5| Q
    I -->|Rate Exceeded| R[Rate Limited Response]
    M -->|SMTP Failure| S[Email Error Response]
    
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style M fill:#e1f5fe
    style N fill:#f3e5f5
```

### **Monitoring Data Pipeline**
```mermaid
graph LR
    A[Application Logs] --> B[Promtail]
    C[Application Metrics] --> D[Prometheus]
    E[Kong Metrics] --> D
    F[Nginx Metrics] --> D
    
    B --> G[Loki]
    D --> H[Grafana]
    G --> H
    
    H --> I[Portfolio Dashboard]
    H --> J[Security Dashboard]
    H --> K[Kong Dashboard]
    H --> L[System Dashboard]
    
    D --> M[Alert Manager]
    M --> N[Email Notifications]
    M --> O[Webhook Alerts]
    
    style G fill:#e8f5e8
    style H fill:#f3e5f5
    style D fill:#e1f5fe
```

## 🔐 **Enhanced Multi-Layer Security Architecture**

### **Security Layer Breakdown**

1. **Origin Validation Layer (S1)**:
   - Validates request origin against whitelist
   - Prevents unauthorized domain access
   - Returns 403 Forbidden for invalid origins

2. **Browser Detection Layer (S2)**:
   - Analyzes User-Agent headers
   - Differentiates browser vs API requests
   - Enables appropriate authentication flow

3. **API Authentication Layer (S3)**:
   - Validates API credentials for non-browser requests
   - Requires X-API-Key and X-API-Secret headers
   - Returns 401 Unauthorized for invalid/missing credentials

4. **Access Method Detection (S4)**:
   - Determines IP vs Domain access method
   - Routes to appropriate CAPTCHA system
   - Maintains backward compatibility

5. **CAPTCHA Verification (S5/S6)**:
   - S5: Local math CAPTCHA for IP access
   - S6: Google reCAPTCHA v3 for domain access
   - Prevents automated abuse

### **Security Configuration**

```env
# API Authentication
API_KEY=portfolio-api-key-secure-2024
API_SECRET=portfolio-api-secret-secure-2024
API_AUTH_ENABLED=true

# CAPTCHA Configuration  
RECAPTCHA_SECRET_KEY=6LcgftMrAAAAANYLqKcqycaZrYzEhpVBmQNeacsm
RECAPTCHA_SITE_KEY=6LcgftMrAAAAaPJRuWA4mQgstPWYoIXoPM4PBjMM
```

## 🔒 **Security Architecture Layers**

### **Layer 1: Network Security**
- **HTTPS Enforcement**: TLS 1.3 encryption for all traffic
- **CORS Configuration**: Origin-based access control
- **CSP Headers**: Content Security Policy implementation
- **SSL Certificates**: Let's Encrypt or custom certificates

### **Layer 2: Application Security**
- **Dual Captcha**: Math captcha + reCAPTCHA v3
- **Rate Limiting**: 5 requests/minute per IP address
- **Input Validation**: Pydantic models with field validation
- **Honeypot Fields**: Hidden form fields for bot detection

### **Layer 3: API Security**
- **Authentication Bypass**: IP-based access patterns
- **API Key Authentication**: Domain-based access control
- **Request Signing**: Header validation for API calls
- **Token Validation**: JWT or API key verification

### **Layer 4: Infrastructure Security**
- **Container Isolation**: Docker security boundaries
- **User Permissions**: Non-root container execution
- **Network Segmentation**: Container network isolation
- **Volume Security**: Persistent data protection

### **Layer 5: Monitoring Security**
- **Access Logging**: Comprehensive request logging
- **Security Events**: Failed authentication tracking
- **Anomaly Detection**: Unusual traffic pattern alerts
- **Incident Response**: Automated security notifications

## 📈 **Performance Architecture**

### **Frontend Optimization**
- **Build Optimization**: Webpack bundle optimization
- **Code Splitting**: Lazy loading for routes
- **Asset Caching**: Nginx static file caching
- **CDN Integration**: Static asset delivery optimization

### **Backend Optimization**
- **Async Operations**: FastAPI async request handling
- **Connection Pooling**: Database connection optimization
- **Caching Strategy**: Redis integration capability
- **Query Optimization**: MongoDB indexing and aggregation

### **Network Optimization**
- **Kong Proxy**: < 50ms additional latency
- **Traefik Routing**: Efficient load balancing
- **Nginx Compression**: Gzip compression for responses
- **Keep-Alive**: HTTP connection reuse

### **Database Optimization**
- **Indexing Strategy**: Optimized query performance
- **Connection Management**: Pool size optimization
- **Data Modeling**: Efficient document structure
- **Backup Strategy**: Automated backup procedures

## 🔄 **Deployment Architecture**

### **Container Orchestration**
```yaml
# Production Docker Compose Services
services:
  frontend-http:     # React HTTP frontend
  frontend-https:    # React HTTPS frontend  
  backend:           # FastAPI application
  mongodb:           # Database service
  redis:             # Cache & session store
  mongo-express:     # Database GUI
  prometheus:        # Metrics collection
  grafana:          # Monitoring dashboards
  loki:             # Log aggregation
  promtail:         # Log shipping
```

### **Technology Stack**

#### **Frontend Layer**
- **Framework**: React 18+ with functional components
- **Routing**: React Router v6
- **Styling**: Tailwind CSS + Custom CSS
- **Analytics Integration**: 
  - Google Analytics (gtag.js) - Measurement ID: G-B2W705K4SN
  - Matomo Analytics - Container: Bx60SjUR
  - **Integration Method**: Direct script injection in `/public/index.html`
- **Build Tool**: Create React App
- **HTTP Server**: Nginx with security headers

#### **Backend Layer** 
- **Framework**: FastAPI (Python 3.9+)
- **Authentication**: JWT + API Key validation
- **Rate Limiting**: SlowAPI middleware
- **Email Service**: IONOS SMTP integration
- **CORS**: Configurable origin whitelist

#### **Data Layer**
- **Primary Database**: MongoDB 6.0+ (Document storage)
- **Cache Layer**: Redis 7-alpine 
  - **Usage**: Session storage, rate limiting counters, API response caching
  - **Configuration**: Password protected, persistent storage, memory optimization
- **Persistence**: Docker volumes for data retention

#### **Security & Analytics**
- **Captcha Systems**: 
  - Local Math Captcha (privacy-first)
  - Google reCAPTCHA v3 (enterprise security)
- **API Security**: Origin validation + credential verification  
- **Analytics**: Dual tracking with Google Analytics + Matomo
- **SSL/TLS**: Self-signed certificates for local HTTPS

### **Volume Management**
- **MongoDB Data**: Persistent volume for database
- **SSL Certificates**: Volume for TLS certificates
- **Log Storage**: Persistent logging data
- **Backup Storage**: Automated backup volumes

### **Health Monitoring**
- **Container Health**: Docker health checks
- **Service Health**: Application health endpoints
- **Database Health**: MongoDB connection monitoring
- **External Service Health**: SMTP and API monitoring

This architecture provides a robust, scalable, and secure foundation for the portfolio application with intelligent adaptation to different access methods and deployment scenarios.