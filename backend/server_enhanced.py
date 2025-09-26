# Enhanced FastAPI Server - Phase 2
# Advanced features including analytics, file upload, and performance monitoring

from fastapi import FastAPI, APIRouter, HTTPException, Request, File, UploadFile, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import uvicorn
import os
import time
import uuid
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime, timezone
from pydantic import BaseModel, Field, EmailStr
import asyncio
import aiofiles
from motor.motor_asyncio import AsyncIOMotorClient

# Import enhanced services
from logging_config import get_logger, log_api_request, log_security_event, logging_config
from enhanced_email_service import enhanced_email_service

# Initialize logging
logger = get_logger(__name__)

# Create the main app
app = FastAPI(
    title="ARCHSOL IT Portfolio API",
    description="Professional portfolio API with enhanced features",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Create API router
api_router = APIRouter(prefix="/api")

# File upload configuration
UPLOAD_DIR = Path("/app/uploads")
UPLOAD_DIR.mkdir(exist_ok=True)
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
ALLOWED_FILE_TYPES = {
    'application/pdf': '.pdf',
    'application/msword': '.doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document': '.docx',
    'text/plain': '.txt'
}

# MongoDB setup
MONGO_URL = os.getenv('MONGO_URL', 'mongodb://localhost:27017')
DATABASE_NAME = os.getenv('DB_NAME', 'portfolio_db')

try:
    client = AsyncIOMotorClient(MONGO_URL)
    db = client[DATABASE_NAME]
    logger.info("MongoDB connection established", extra={'database': DATABASE_NAME})
except Exception as e:
    logger.error("MongoDB connection failed", exc_info=True)
    db = None

# Pydantic Models
class ContactFormEnhanced(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    company: Optional[str] = Field(None, max_length=100)
    role: Optional[str] = Field(None, max_length=100)
    projectType: Optional[str] = None
    budget: Optional[str] = None
    timeline: Optional[str] = None
    message: str = Field(..., min_length=10, max_length=2000)
    attachments: Optional[List[str]] = []

class AnalyticsEvent(BaseModel):
    event_type: str
    category: str
    action: str
    properties: Optional[Dict[str, Any]] = {}
    session_id: Optional[str] = None
    user_agent: Optional[str] = None
    ip_address: Optional[str] = None
    timestamp: Optional[datetime] = None

class FileUploadResponse(BaseModel):
    filename: str
    file_id: str
    size: int
    content_type: str
    upload_time: datetime

class HealthStatus(BaseModel):
    status: str
    timestamp: datetime
    version: str
    services: Dict[str, Any]

class SearchQuery(BaseModel):
    query: str = Field(..., min_length=2, max_length=100)
    type: Optional[str] = "all"
    limit: Optional[int] = Field(10, ge=1, le=50)

# Middleware
@app.middleware("http")
async def logging_middleware(request: Request, call_next):
    """Log all API requests with performance metrics"""
    start_time = time.time()
    request_id = str(uuid.uuid4())
    
    # Add request ID to request state
    request.state.request_id = request_id
    
    # Get client info
    client_ip = request.headers.get("X-Forwarded-For", request.client.host if request.client else "unknown")
    user_agent = request.headers.get("User-Agent", "unknown")
    
    logger.info(f"Request started: {request.method} {request.url.path}", extra={
        'request_id': request_id,
        'method': request.method,
        'path': request.url.path,
        'ip_address': client_ip,
        'user_agent': user_agent,
        'phase': 'start'
    })
    
    try:
        response = await call_next(request)
        duration = time.time() - start_time
        
        log_api_request(
            logger, 
            request.method, 
            str(request.url.path),
            response.status_code,
            duration,
            request_id=request_id,
            ip_address=client_ip,
            user_agent=user_agent[:100] if user_agent else None
        )
        
        # Add performance headers
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Response-Time"] = f"{duration:.3f}s"
        
        return response
        
    except Exception as e:
        duration = time.time() - start_time
        logger.error("Request failed", extra={
            'request_id': request_id,
            'method': request.method,
            'path': request.url.path,
            'duration': duration * 1000,
            'error': str(e)
        }, exc_info=True)
        raise

# Rate limiting middleware (simple implementation)
request_counts = {}
RATE_LIMIT_WINDOW = 300  # 5 minutes
RATE_LIMIT_MAX = 100

@app.middleware("http")
async def rate_limiting_middleware(request: Request, call_next):
    """Simple rate limiting based on IP address"""
    client_ip = request.headers.get("X-Forwarded-For", request.client.host if request.client else "unknown")
    current_time = time.time()
    
    # Clean old entries
    request_counts[client_ip] = [
        timestamp for timestamp in request_counts.get(client_ip, [])
        if current_time - timestamp < RATE_LIMIT_WINDOW
    ]
    
    # Check rate limit
    if len(request_counts.get(client_ip, [])) >= RATE_LIMIT_MAX:
        log_security_event(logger, "rate_limit_exceeded", {
            'ip_address': client_ip,
            'path': request.url.path,
            'method': request.method
        })
        return JSONResponse(
            status_code=429,
            content={"detail": "Rate limit exceeded. Please try again later."}
        )
    
    # Add current request
    if client_ip not in request_counts:
        request_counts[client_ip] = []
    request_counts[client_ip].append(current_time)
    
    return await call_next(request)

# CORS configuration
cors_origins = os.getenv('CORS_ORIGINS', 'http://localhost:3000,http://localhost:8080,https://localhost:8443').split(',')

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Trusted hosts middleware
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["*"]  # Configure appropriately for production
)

# Static files for uploads
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")

# API Endpoints

@api_router.get("/", response_model=Dict[str, Any])
async def root():
    """API root with enhanced information"""
    return {
        "message": "ARCHSOL IT Portfolio API - Phase 2 Enhanced",
        "version": "2.0.0",
        "status": "healthy",
        "features": [
            "Enhanced contact form with file uploads",
            "Analytics tracking",
            "Performance monitoring", 
            "Rate limiting",
            "Structured logging",
            "HTML email templates"
        ],
        "endpoints": {
            "health": "/api/health",
            "contact": "/api/contact/send-email",
            "upload": "/api/upload/file",
            "analytics": "/api/analytics/track",
            "portfolio": {
                "stats": "/api/portfolio/stats",
                "skills": "/api/portfolio/skills",
                "projects": "/api/portfolio/projects"
            }
        },
        "documentation": {
            "swagger": "/docs",
            "redoc": "/redoc"
        }
    }

@api_router.get("/health", response_model=HealthStatus)
async def health_check():
    """Enhanced health check with service status"""
    services = {
        "email": enhanced_email_service.get_service_status(),
        "database": {
            "connected": db is not None,
            "url": MONGO_URL.replace(MONGO_URL.split('@')[0].split('//')[1] + '@', '***@') if '@' in MONGO_URL else MONGO_URL
        },
        "file_upload": {
            "enabled": True,
            "upload_dir": str(UPLOAD_DIR),
            "max_file_size": MAX_FILE_SIZE,
            "allowed_types": list(ALLOWED_FILE_TYPES.keys())
        }
    }
    
    # Test database connection
    if db:
        try:
            await db.command("ping")
            services["database"]["status"] = "healthy"
        except Exception as e:
            services["database"]["status"] = "unhealthy"
            services["database"]["error"] = str(e)
    
    return HealthStatus(
        status="healthy",
        timestamp=datetime.now(timezone.utc),
        version="2.0.0",
        services=services
    )

@api_router.post("/contact/send-email")
async def send_contact_email(
    contact_data: ContactFormEnhanced,
    background_tasks: BackgroundTasks,
    request: Request
):
    """Enhanced contact form with background processing"""
    start_time = time.time()
    
    try:
        # Get client info for logging
        client_ip = request.headers.get("X-Forwarded-For", request.client.host if request.client else "unknown")
        user_agent = request.headers.get("User-Agent", "unknown")
        
        logger.info("Contact form submission received", extra={
            'name': contact_data.name,
            'email': contact_data.email,
            'company': contact_data.company,
            'project_type': contact_data.projectType,
            'ip_address': client_ip,
            'user_agent': user_agent[:100] if user_agent else None
        })
        
        # Validate form data
        form_dict = contact_data.dict()
        
        # Process email in background for better performance
        background_tasks.add_task(process_contact_form, form_dict, client_ip)
        
        # Store in database if available
        if db:
            contact_record = {
                **form_dict,
                'timestamp': datetime.now(timezone.utc),
                'ip_address': client_ip,
                'user_agent': user_agent,
                'status': 'pending'
            }
            await db.contacts.insert_one(contact_record)
        
        duration = time.time() - start_time
        logger.info("Contact form processed", extra={
            'duration': duration * 1000,
            'email': contact_data.email
        })
        
        return {
            "success": True,
            "message": "Thank you for your message! I'll get back to you within 1-2 business days.",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
        
    except Exception as e:
        logger.error("Contact form submission failed", exc_info=True, extra={
            'email': contact_data.email if contact_data else 'unknown'
        })
        raise HTTPException(status_code=500, detail="Internal server error")

async def process_contact_form(form_data: Dict[str, Any], client_ip: str):
    """Background task to process contact form"""
    try:
        # Send email
        success, message = enhanced_email_service.send_contact_form_email(form_data)
        
        # Update database record if available
        if db:
            await db.contacts.update_one(
                {'email': form_data['email'], 'timestamp': {'$gte': datetime.now(timezone.utc).replace(hour=0, minute=0, second=0)}},
                {'$set': {'email_status': 'sent' if success else 'failed', 'email_message': message}}
            )
        
        logger.info("Background contact processing completed", extra={
            'email': form_data.get('email'),
            'success': success,
            'message': message
        })
        
    except Exception as e:
        logger.error("Background contact processing failed", exc_info=True)

@api_router.post("/upload/file", response_model=FileUploadResponse)
async def upload_file(file: UploadFile = File(...)):
    """File upload endpoint with validation"""
    
    # Validate file size
    if file.size and file.size > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"File size {file.size} exceeds maximum allowed size {MAX_FILE_SIZE}"
        )
    
    # Validate file type
    if file.content_type not in ALLOWED_FILE_TYPES:
        raise HTTPException(
            status_code=415,
            detail=f"File type {file.content_type} not allowed. Allowed types: {list(ALLOWED_FILE_TYPES.keys())}"
        )
    
    try:
        # Generate unique filename
        file_id = str(uuid.uuid4())
        file_extension = ALLOWED_FILE_TYPES[file.content_type]
        filename = f"{file_id}{file_extension}"
        file_path = UPLOAD_DIR / filename
        
        # Save file
        async with aiofiles.open(file_path, 'wb') as f:
            content = await file.read()
            await f.write(content)
        
        # Get file size
        file_size = len(content)
        
        logger.info("File uploaded successfully", extra={
            'filename': file.filename,
            'file_id': file_id,
            'size': file_size,
            'content_type': file.content_type
        })
        
        return FileUploadResponse(
            filename=file.filename,
            file_id=file_id,
            size=file_size,
            content_type=file.content_type,
            upload_time=datetime.now(timezone.utc)
        )
        
    except Exception as e:
        logger.error("File upload failed", exc_info=True)
        raise HTTPException(status_code=500, detail="File upload failed")

@api_router.post("/analytics/track")
async def track_analytics_event(event: AnalyticsEvent, request: Request):
    """Track analytics events"""
    try:
        # Add request metadata
        client_ip = request.headers.get("X-Forwarded-For", request.client.host if request.client else "unknown")
        user_agent = request.headers.get("User-Agent", "unknown")
        
        # Enhance event data
        event_data = {
            **event.dict(),
            'ip_address': client_ip,
            'user_agent': user_agent,
            'timestamp': datetime.now(timezone.utc),
            'server_timestamp': datetime.now(timezone.utc)
        }
        
        # Store in database if available
        if db:
            await db.analytics.insert_one(event_data)
        
        logger.info("Analytics event tracked", extra={
            'event_type': event.event_type,
            'category': event.category,
            'action': event.action,
            'session_id': event.session_id
        })
        
        return {"success": True, "message": "Event tracked successfully"}
        
    except Exception as e:
        logger.error("Analytics tracking failed", exc_info=True)
        raise HTTPException(status_code=500, detail="Analytics tracking failed")

@api_router.get("/portfolio/stats")
async def get_portfolio_stats():
    """Get enhanced portfolio statistics"""
    stats = {
        "projects": "26+",
        "technologies": "50+",
        "industries": "15+",
        "experience_years": "26+",
        "certifications": "12+",
        "successful_transformations": "40+",
        "team_size_managed": "100+",
        "budget_managed": "£50M+"
    }
    
    # Add dynamic stats from database if available
    if db:
        try:
            contact_stats = await db.contacts.aggregate([
                {"$group": {
                    "_id": None,
                    "total_inquiries": {"$sum": 1},
                    "unique_companies": {"$addToSet": "$company"},
                    "project_types": {"$addToSet": "$projectType"}
                }}
            ]).to_list(1)
            
            if contact_stats:
                stats["inquiries_received"] = contact_stats[0]["total_inquiries"]
                stats["companies_contacted"] = len([c for c in contact_stats[0]["unique_companies"] if c])
        except Exception as e:
            logger.warning("Could not fetch dynamic stats", exc_info=True)
    
    return stats

@api_router.get("/portfolio/skills")
async def get_portfolio_skills():
    """Get enhanced skills data"""
    return {
        "categories": [
            {
                "title": "AI & Emerging Technologies",
                "skills": [
                    "Gen AI Architecture & Strategy",
                    "Agentic AI Systems Design",
                    "LLM Integration & Optimization",
                    "AI-Driven Automation",
                    "Machine Learning Operations (MLOps)",
                    "AI Ethics & Governance",
                    "Prompt Engineering",
                    "AI Model Fine-tuning"
                ],
                "level": "Expert",
                "years_experience": "3+",
                "highlight": True
            },
            {
                "title": "Enterprise Architecture",
                "skills": [
                    "Solution Architecture Design",
                    "System Integration Patterns",
                    "Digital Transformation Strategy",
                    "Architecture Governance",
                    "Technical Due Diligence",
                    "Enterprise Architecture Frameworks (TOGAF, Zachman)",
                    "Business Process Optimization",
                    "Technology Roadmap Planning"
                ],
                "level": "Expert",
                "years_experience": "15+",
                "highlight": True
            },
            {
                "title": "Cloud & Modern Technology",
                "skills": [
                    "AWS (Solutions Architect Professional)",
                    "Microsoft Azure (Architect Expert)",
                    "Google Cloud Platform",
                    "Microservices Architecture",
                    "API-First Design",
                    "Serverless Computing",
                    "Azure OpenAI Service",
                    "AWS Bedrock",
                    "Kubernetes & Container Orchestration",
                    "Infrastructure as Code (Terraform, ARM)"
                ],
                "level": "Expert",
                "years_experience": "12+",
                "highlight": False
            },
            {
                "title": "Security & Identity",
                "skills": [
                    "Customer Identity & Access Management (CIAM)",
                    "Zero Trust Architecture",
                    "OAuth 2.0 / OpenID Connect",
                    "Security Architecture Review",
                    "Privacy by Design",
                    "GDPR Compliance",
                    "Security Risk Assessment",
                    "Identity Federation"
                ],
                "level": "Expert",
                "years_experience": "10+",
                "highlight": False
            }
        ],
        "certifications": [
            {
                "name": "AWS Solutions Architect Professional",
                "issuer": "Amazon Web Services",
                "year": "2023",
                "credential_id": "AWS-PSA-2023-001"
            },
            {
                "name": "Microsoft Azure Solutions Architect Expert",
                "issuer": "Microsoft",
                "year": "2023",
                "credential_id": "MSFT-AZ-304-2023"
            },
            {
                "name": "TOGAF 9.2 Certified",
                "issuer": "The Open Group",
                "year": "2022",
                "credential_id": "TOGAF-2022-001"
            }
        ]
    }

@api_router.get("/portfolio/projects")
async def get_portfolio_projects():
    """Get enhanced project portfolio"""
    return {
        "featured_projects": [
            {
                "id": "gen-ai-transformation",
                "title": "Enterprise Gen AI Transformation",
                "category": "AI & Digital Transformation",
                "client": "Fortune 500 Financial Services",
                "duration": "18 months",
                "budget_range": "£2M - £5M",
                "description": "Led comprehensive Gen AI strategy and implementation",
                "key_outcomes": [
                    "40% reduction in manual processes",
                    "£3.2M annual cost savings",
                    "95% user adoption rate"
                ],
                "technologies": ["Azure OpenAI", "LangChain", "Kubernetes", "Python", "React"],
                "highlight": True
            },
            {
                "id": "cloud-migration-strategy",
                "title": "Multi-Cloud Migration & Modernization",
                "category": "Cloud Transformation",
                "client": "Global Manufacturing Company", 
                "duration": "24 months",
                "budget_range": "£5M - £10M",
                "description": "Architected and executed large-scale cloud transformation",
                "key_outcomes": [
                    "60% infrastructure cost reduction",
                    "99.9% uptime achievement",
                    "50% faster deployment cycles"
                ],
                "technologies": ["AWS", "Azure", "Kubernetes", "Terraform", "GitLab CI/CD"],
                "highlight": True
            }
        ],
        "project_categories": [
            "AI & Digital Transformation",
            "Cloud Transformation", 
            "Identity & Access Management",
            "API & Integration",
            "Security Architecture"
        ],
        "total_projects": 26,
        "success_rate": "98%"
    }

# Include the API router
app.include_router(api_router)

# Startup and shutdown events
@app.on_event("startup")
async def startup_event():
    """Application startup tasks"""
    logger.info("ARCHSOL IT Portfolio API starting up", extra={
        'version': '2.0.0',
        'features': 'Phase 2 Enhanced'
    })

@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown tasks"""
    logger.info("ARCHSOL IT Portfolio API shutting down")
    if client:
        client.close()

# Error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Custom HTTP exception handler"""
    logger.warning("HTTP exception", extra={
        'status_code': exc.status_code,
        'detail': exc.detail,
        'path': request.url.path,
        'method': request.method
    })
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "timestamp": datetime.now(timezone.utc).isoformat()}
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """General exception handler"""
    logger.error("Unhandled exception", exc_info=True, extra={
        'path': request.url.path,
        'method': request.method
    })
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    )

if __name__ == "__main__":
    # Configure uvicorn for enhanced logging
    uvicorn.run(
        "server_enhanced:app",
        host="0.0.0.0",
        port=8001,
        log_config=None,  # Use our custom logging
        access_log=False  # We handle this in middleware
    )