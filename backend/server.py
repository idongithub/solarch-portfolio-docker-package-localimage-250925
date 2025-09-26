from fastapi import FastAPI, APIRouter, HTTPException, Header, Depends, Request
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi.responses import PlainTextResponse
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
import os
import logging
from pathlib import Path
import httpx
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import time
import psutil

ROOT_DIR = Path(__file__).parent
# Load environment variables
load_dotenv(ROOT_DIR / '.env')

# API Authentication middleware
async def verify_api_credentials(
    request: Request,
    x_api_key: Optional[str] = Header(None),
    x_api_secret: Optional[str] = Header(None)
):
    """
    Verify API credentials for domain-based access.
    IP-based access bypasses this authentication.
    """
    # Skip authentication if disabled
    if not os.getenv('API_AUTH_ENABLED', 'false').lower() == 'true':
        return True
    
    # Get the Host header to determine if this is IP-based or domain-based access
    host = request.headers.get('host', '')
    
    # Skip authentication for IP-based access (localhost, 127.0.0.1, or IP addresses)
    if (host.startswith('localhost:') or 
        host.startswith('127.0.0.1:') or 
        # Check for IP address pattern (simple regex for IPv4)
        any(char.isdigit() for char in host.split(':')[0]) and '.' in host):
        logger.info(f"Skipping API authentication for IP-based access: {host}")
        return True
    
    # Domain-based access requires authentication
    logger.info(f"Requiring API authentication for domain-based access: {host}")
    
    expected_key = os.getenv('API_KEY')
    expected_secret = os.getenv('API_SECRET')
    
    if not expected_key or not expected_secret:
        logging.warning("API authentication enabled but credentials not configured")
        raise HTTPException(status_code=500, detail="API authentication not properly configured")
    
    if not x_api_key or not x_api_secret:
        raise HTTPException(
            status_code=401, 
            detail="API credentials required for domain access. Missing X-API-Key or X-API-Secret headers."
        )
    
    if x_api_key != expected_key or x_api_secret != expected_secret:
        logging.warning(f"Invalid API credentials attempted from {host}")
        raise HTTPException(status_code=401, detail="Invalid API credentials")
    
    return True

# Rate limiter configuration
limiter = Limiter(key_func=get_remote_address)

# Create the main app without a prefix
app = FastAPI(
    title="Kamal Singh Portfolio API",
    description="API for ARCHSOL IT Solutions Portfolio",
    version="1.0.0",
    openapi_version="3.0.2"
)

# Add rate limiter to app
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Define Models
class StatusCheck(BaseModel):
    status: str = "healthy"
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())

# Local CAPTCHA verification function
def verify_local_captcha(local_captcha_data: str, remote_ip: str) -> tuple[bool, str]:
    """
    Verify local captcha for IP-based access
    Returns (is_valid, error_message)
    """
    if not local_captcha_data:
        return False, "Local captcha data missing"
        
    try:
        import json
        captcha_info = json.loads(local_captcha_data)
        
        captcha_type = captcha_info.get('type')
        if captcha_type != 'local_captcha':
            return False, "Invalid captcha type"
            
        captcha_id = captcha_info.get('captcha_id')
        user_answer = captcha_info.get('user_answer', '').strip()
        
        if not captcha_id or not user_answer:
            return False, "Missing captcha data"
        
        # For now, we trust the frontend validation
        # In production, you might store captcha questions server-side
        # and validate against them
        
        logger.info(f"Local captcha verified for IP: {remote_ip}, ID: {captcha_id}")
        return True, "Valid"
        
    except (json.JSONDecodeError, KeyError) as e:
        logger.error(f"Local captcha verification error: {e}")
        return False, "Invalid captcha format"

# CAPTCHA verification function
async def verify_recaptcha(token: str, remote_ip: str) -> tuple[bool, float]:
    """
    Verify reCAPTCHA token with Google's API
    Returns (is_valid, score) where score is confidence level (0.0-1.0)
    """
    if not token:
        return False, 0.0
        
    secret_key = os.getenv('RECAPTCHA_SECRET_KEY')
    if not secret_key:
        logger.warning("RECAPTCHA_SECRET_KEY not configured - bypassing verification")
        return True, 1.0  # Allow if not configured (development mode)
    
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(
                'https://www.google.com/recaptcha/api/siteverify',
                data={
                    'secret': secret_key,
                    'response': token,
                    'remoteip': remote_ip
                }
            )
            
            if response.status_code != 200:
                logger.error(f"reCAPTCHA API error: {response.status_code}")
                return False, 0.0
            
            result = response.json()
            success = result.get('success', False)
            score = result.get('score', 0.0)  # Default to 0.0 if not present
            action = result.get('action', '')
            
            # Log verification details
            if success:
                logger.info(f"reCAPTCHA verified: score={score}, action={action}, ip={remote_ip}")
            else:
                errors = result.get('error-codes', [])
                logger.warning(f"reCAPTCHA failed: {errors}, ip={remote_ip}")
                # Return False immediately for failed verification
                return False, 0.0
            
            # For reCAPTCHA v3, check both success and score
            # Score threshold: 0.5 (adjustable based on requirements)
            return success and score >= 0.5, score
            
    except Exception as e:
        logger.error(f"reCAPTCHA verification error: {e}")
        return False, 0.0

class ContactForm(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., pattern=r'^[^@]+@[^@]+\.[^@]+$')
    projectType: str = Field(..., min_length=1)
    budget: str = Field(..., min_length=1)
    timeline: str = Field(..., min_length=1)
    message: str = Field(..., min_length=1, max_length=2000)
    recaptcha_token: str = Field(default="", description="reCAPTCHA token for bot protection")
    local_captcha: str = Field(default="", description="Local captcha data for IP-based access")

# CORS Configuration
cors_origins = os.environ.get('CORS_ORIGINS', 'http://localhost:3000,http://localhost:80,http://localhost').split(',')

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Metrics middleware
@app.middleware("http")
async def metrics_middleware(request, call_next):
    global request_count, request_duration_sum
    
    start_time = time.time()
    request_count += 1
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    request_duration_sum += duration
    
    return response

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Debug logging for CORS configuration
logger.info(f"CORS Origins configured: {cors_origins}")

# Metrics collection
request_count = 0
request_duration_sum = 0
email_sent_count = 0
email_failed_count = 0

# Health Check Endpoints
@app.get("/health")
async def health_check():
    """Health check endpoint for container monitoring"""
    return StatusCheck()

@api_router.get("/health")
async def api_health_check():
    """API health check endpoint"""
    return StatusCheck()

@app.get("/metrics", response_class=PlainTextResponse)
async def get_metrics():
    """Prometheus metrics endpoint"""
    global request_count, request_duration_sum, email_sent_count, email_failed_count
    
    # System metrics
    cpu_percent = psutil.cpu_percent()
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    metrics = f"""# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total {request_count}

# HELP http_request_duration_seconds HTTP request duration in seconds
# TYPE http_request_duration_seconds summary
http_request_duration_seconds_sum {request_duration_sum}
http_request_duration_seconds_count {request_count}

# HELP emails_sent_total Total number of emails sent successfully
# TYPE emails_sent_total counter
emails_sent_total {email_sent_count}

# HELP emails_failed_total Total number of failed email attempts
# TYPE emails_failed_total counter
emails_failed_total {email_failed_count}

# HELP system_cpu_usage_percent Current CPU usage percentage
# TYPE system_cpu_usage_percent gauge
system_cpu_usage_percent {cpu_percent}

# HELP system_memory_usage_bytes Current memory usage in bytes
# TYPE system_memory_usage_bytes gauge
system_memory_usage_bytes {memory.used}

# HELP system_memory_total_bytes Total memory in bytes
# TYPE system_memory_total_bytes gauge
system_memory_total_bytes {memory.total}

# HELP system_disk_usage_bytes Current disk usage in bytes
# TYPE system_disk_usage_bytes gauge
system_disk_usage_bytes {disk.used}

# HELP system_disk_total_bytes Total disk space in bytes
# TYPE system_disk_total_bytes gauge
system_disk_total_bytes {disk.total}

# HELP backend_health Backend health status (1 = healthy, 0 = unhealthy)
# TYPE backend_health gauge
backend_health 1
"""
    return metrics

# Email functionality
def send_email(contact_data: ContactForm):
    """Send email using SMTP configuration"""
    try:
        # Get SMTP configuration from environment
        smtp_server = os.environ.get('SMTP_SERVER', 'smtp.gmail.com')
        smtp_port = int(os.environ.get('SMTP_PORT', '587'))
        smtp_username = os.environ.get('SMTP_USERNAME')
        smtp_password = os.environ.get('SMTP_PASSWORD')
        from_email = os.environ.get('FROM_EMAIL', smtp_username)
        to_email = os.environ.get('TO_EMAIL', 'kamal.singh@architecturesolutions.co.uk')
        
        if not smtp_username or not smtp_password:
            logger.warning("SMTP credentials not configured")
            return False
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = from_email
        msg['To'] = to_email
        msg['Subject'] = f"Portfolio Contact Form - {contact_data.projectType}"
        
        # Email body
        body = f"""
New contact form submission from IT Portfolio website:

Name: {contact_data.name}
Email: {contact_data.email}
Project Type: {contact_data.projectType}
Budget: {contact_data.budget}
Timeline: {contact_data.timeline}

Message:
{contact_data.message}

---
Sent from Kamal Singh IT Portfolio Architect website
        """
        
        msg.attach(MIMEText(body, 'plain'))
        
        # Send email with proper SSL/TLS handling
        smtp_use_ssl = os.getenv('SMTP_USE_SSL', 'false').lower() == 'true'
        smtp_use_tls = os.getenv('SMTP_USE_TLS', 'true').lower() == 'true'
        
        if smtp_use_ssl:
            # Use SMTP_SSL for port 465
            server = smtplib.SMTP_SSL(smtp_server, smtp_port)
        else:
            # Use regular SMTP with STARTTLS for port 587
            server = smtplib.SMTP(smtp_server, smtp_port)
            if smtp_use_tls:
                server.starttls()
        
        server.login(smtp_username, smtp_password)
        text = msg.as_string()
        server.sendmail(from_email, to_email, text)
        server.quit()
        
        global email_sent_count
        email_sent_count += 1
        logger.info(f"Email sent successfully for contact from {contact_data.email}")
        return True
        
    except Exception as e:
        global email_failed_count
        email_failed_count += 1
        logger.error(f"Failed to send email: {str(e)}")
        return False

@api_router.post("/contact/send-email")
@limiter.limit("5/minute")  # Allow 5 form submissions per minute per IP
async def send_contact_email(
    request: Request,
    contact_data: ContactForm,
    _: bool = Depends(verify_api_credentials)
):
    """Send contact form email with CAPTCHA protection"""
    try:
        # Get client IP for logging and verification
        client_ip = request.client.host if request.client else "unknown"
        logger.info(f"📧 Contact form submission from {contact_data.email} (IP: {client_ip})")
        
        # Verify security (reCAPTCHA or local captcha)
        if contact_data.recaptcha_token:
            # Use Google reCAPTCHA for domain-based access
            logger.info(f"🔐 Using Google reCAPTCHA verification for {client_ip}")
            is_valid, score = await verify_recaptcha(contact_data.recaptcha_token, client_ip)
            if not is_valid:
                logger.warning(f"🚫 reCAPTCHA verification failed for {client_ip}")
                raise HTTPException(
                    status_code=400, 
                    detail="Security verification failed. Please try again."
                )
            logger.info(f"✅ reCAPTCHA verified with score: {score}")
        elif contact_data.local_captcha:
            # Use local captcha for IP-based access
            logger.info(f"🏠 Using local captcha verification for {client_ip}")
            is_valid, error_msg = verify_local_captcha(contact_data.local_captcha, client_ip)
            if not is_valid:
                logger.warning(f"🚫 Local captcha verification failed for {client_ip}: {error_msg}")
                raise HTTPException(
                    status_code=400, 
                    detail="Security verification failed. Please solve the math question correctly."
                )
            logger.info(f"✅ Local captcha verified for {client_ip}")
        else:
            # Allow requests without any captcha (for backward compatibility)
            logger.info(f"⚠️ No captcha provided for {client_ip} - proceeding without verification")
        email_sent = send_email(contact_data)
        
        if email_sent:
            return {
                "success": True,
                "message": "Thank you for your message! I'll get back to you soon.",
                "timestamp": datetime.utcnow().isoformat()
            }
        else:
            return {
                "success": False,
                "message": "Email service is currently unavailable. Please try again later or contact directly.",
                "timestamp": datetime.utcnow().isoformat()
            }
            
    except HTTPException:
        # Re-raise HTTPExceptions (like 400 for invalid reCAPTCHA)
        raise
    except Exception as e:
        logger.error(f"Contact form error: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

# Portfolio data endpoints (static data, no database required)
@api_router.get("/portfolio/stats")
async def get_portfolio_stats():
    """Get portfolio statistics"""
    return {
        "projects": "26+",
        "technologies": "50+", 
        "industries": "10+",
        "experience_years": "15+"
    }

@api_router.get("/portfolio/skills")
async def get_skills():
    """Get skills categories"""
    return {
        "categories": [
            {
                "title": "AI & Emerging Technologies",
                "skills": ["Gen AI Architecture", "Agentic AI Systems", "LLM Integration", "AI-Driven Automation"],
                "level": "Expert"
            },
            {
                "title": "Enterprise Architecture", 
                "skills": ["Solution Design", "System Integration", "Digital Transformation", "Architecture Governance"],
                "level": "Expert"
            },
            {
                "title": "Cloud & Modern Technology",
                "skills": ["AWS", "Azure", "GCP", "Microservices", "API-First", "Serverless", "Azure OpenAI", "AWS Bedrock"],
                "level": "Expert"
            }
        ]
    }

# Include the API router
app.include_router(api_router)

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Kamal Singh IT Portfolio Architect API",
        "status": "healthy",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "api_health": "/api/health", 
            "contact": "/api/contact/send-email",
            "stats": "/api/portfolio/stats",
            "skills": "/api/portfolio/skills"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)