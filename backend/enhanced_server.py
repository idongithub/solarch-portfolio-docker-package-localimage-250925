# Enhanced FastAPI server with email functionality
# Production-ready server for Kamal Singh Portfolio

from fastapi import FastAPI, APIRouter, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, EmailStr, validator
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime
import asyncio
from email_service import email_service

# Load environment variables
ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# MongoDB connection
mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
db_name = os.environ.get('DB_NAME', 'portfolio_db')
client = AsyncIOMotorClient(mongo_url)
db = client[db_name]

# Create FastAPI app
app = FastAPI(
    title="Kamal Singh Portfolio API",
    description="Professional portfolio backend with email functionality",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Create API router
api_router = APIRouter(prefix="/api")

# Security
security = HTTPBearer(auto_error=False)

# Pydantic Models
class StatusCheck(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    message: Optional[str] = None

class StatusCheckCreate(BaseModel):
    client_name: str
    message: Optional[str] = None

class ContactForm(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    company: Optional[str] = Field(None, max_length=100)
    role: Optional[str] = Field(None, max_length=100)
    projectType: Optional[str] = Field(None, max_length=100)
    budget: Optional[str] = Field(None, max_length=50)
    timeline: Optional[str] = Field(None, max_length=50)
    message: str = Field(..., min_length=10, max_length=2000)
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    status: str = Field(default="new")
    priority: str = Field(default="normal")
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None

    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()

    @validator('message')
    def validate_message(cls, v):
        if not v.strip():
            raise ValueError('Message cannot be empty')
        return v.strip()

class ContactFormCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    company: Optional[str] = Field(None, max_length=100)
    role: Optional[str] = Field(None, max_length=100)
    projectType: Optional[str] = Field(None, max_length=100)
    budget: Optional[str] = Field(None, max_length=50)
    timeline: Optional[str] = Field(None, max_length=50)
    message: str = Field(..., min_length=10, max_length=2000)

class EmailResponse(BaseModel):
    success: bool
    message: str
    timestamp: Optional[str] = None
    error: Optional[str] = None
    code: Optional[str] = None

# API Routes
@api_router.get("/", tags=["Health"])
async def root():
    """Health check endpoint"""
    return {
        "message": "Kamal Singh Portfolio API",
        "version": "2.0.0",
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }

@api_router.get("/health", tags=["Health"])
async def health_check():
    """Detailed health check including database connectivity"""
    try:
        # Test database connection
        await db.status_checks.find_one()
        db_status = "connected"
    except Exception as e:
        logger.error(f"Database connection error: {str(e)}")
        db_status = "disconnected"
    
    # Test email service configuration
    email_configured = all([
        email_service.smtp_username,
        email_service.smtp_password,
        email_service.to_email
    ])
    
    return {
        "api_status": "healthy",
        "database_status": db_status,
        "email_service": "configured" if email_configured else "not_configured",
        "timestamp": datetime.utcnow().isoformat()
    }

@api_router.post("/status", response_model=StatusCheck, tags=["Status"])
async def create_status_check(input: StatusCheckCreate):
    """Create a new status check entry"""
    try:
        status_dict = input.dict()
        status_obj = StatusCheck(**status_dict)
        await db.status_checks.insert_one(status_obj.dict())
        logger.info(f"Status check created: {status_obj.client_name}")
        return status_obj
    except Exception as e:
        logger.error(f"Error creating status check: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@api_router.get("/status", response_model=List[StatusCheck], tags=["Status"])
async def get_status_checks(limit: int = 100):
    """Get recent status check entries"""
    try:
        status_checks = await db.status_checks.find().sort("timestamp", -1).limit(limit).to_list(length=limit)
        return [StatusCheck(**status_check) for status_check in status_checks]
    except Exception as e:
        logger.error(f"Error fetching status checks: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@api_router.post("/contact", response_model=Dict[str, Any], tags=["Contact"])
async def submit_contact_form(
    contact_data: ContactFormCreate, 
    background_tasks: BackgroundTasks,
    request: Optional[Any] = None
):
    """Submit contact form with email notification"""
    try:
        # Create contact record
        contact_dict = contact_data.dict()
        contact_obj = ContactForm(**contact_dict)
        
        # Add request metadata if available
        if hasattr(request, 'client') and hasattr(request.client, 'host'):
            contact_obj.ip_address = request.client.host
        if hasattr(request, 'headers'):
            contact_obj.user_agent = request.headers.get('user-agent', '')
        
        # Save to database
        await db.contacts.insert_one(contact_obj.dict())
        logger.info(f"Contact form submitted: {contact_obj.email}")
        
        # Send email in background
        background_tasks.add_task(send_contact_email, contact_obj.dict())
        
        return {
            "success": True,
            "message": "Contact form submitted successfully. You will receive a confirmation email shortly.",
            "id": contact_obj.id,
            "timestamp": contact_obj.timestamp.isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error submitting contact form: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to submit contact form")

@api_router.get("/contacts", response_model=List[ContactForm], tags=["Contact"])
async def get_contacts(
    limit: int = 50, 
    status: Optional[str] = None,
    credentials: HTTPAuthorizationCredentials = security
):
    """Get contact form submissions (admin only)"""
    # Simple authentication check - in production, implement proper JWT
    if not credentials or credentials.credentials != os.getenv('ADMIN_TOKEN', 'admin_secret'):
        raise HTTPException(status_code=401, detail="Unauthorized")
    
    try:
        query = {}
        if status:
            query['status'] = status
            
        contacts = await db.contacts.find(query).sort("timestamp", -1).limit(limit).to_list(length=limit)
        return [ContactForm(**contact) for contact in contacts]
    except Exception as e:
        logger.error(f"Error fetching contacts: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@api_router.post("/test-email", response_model=EmailResponse, tags=["Email"])
async def test_email_service(credentials: HTTPAuthorizationCredentials = security):
    """Test email service configuration (admin only)"""
    if not credentials or credentials.credentials != os.getenv('ADMIN_TOKEN', 'admin_secret'):
        raise HTTPException(status_code=401, detail="Unauthorized")
    
    test_data = {
        "name": "Test User",
        "email": "test@example.com",
        "company": "Test Company",
        "role": "Developer",
        "projectType": "Email Test",
        "budget": "£1k - £5k",
        "timeline": "Immediate",
        "message": "This is a test email to verify the email service configuration."
    }
    
    result = await email_service.send_email(test_data)
    
    if result['success']:
        return EmailResponse(**result)
    else:
        raise HTTPException(status_code=500, detail=result.get('error', 'Email service error'))

# Background task for sending emails
async def send_contact_email(contact_data: Dict[str, Any]):
    """Background task to send email notifications"""
    try:
        result = await email_service.send_email(contact_data)
        if result['success']:
            logger.info(f"Email sent successfully for contact: {contact_data.get('email')}")
        else:
            logger.error(f"Failed to send email: {result.get('error')}")
    except Exception as e:
        logger.error(f"Error in background email task: {str(e)}")

# Include router
app.include_router(api_router)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "timestamp": datetime.utcnow().isoformat()}
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "timestamp": datetime.utcnow().isoformat()
        }
    )

# Startup and shutdown events
@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    logger.info("Starting Kamal Singh Portfolio API...")
    logger.info(f"Database: {db_name}")
    logger.info(f"Email service configured: {email_service.smtp_server}")

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    logger.info("Shutting down Kamal Singh Portfolio API...")
    client.close()

# Main entry point
if __name__ == "__main__":
    import uvicorn
    
    port = int(os.getenv('PORT', 8001))
    host = os.getenv('HOST', '0.0.0.0')
    
    uvicorn.run(
        "enhanced_server:app",
        host=host,
        port=port,
        reload=False,  # Set to False for production
        log_level="info"
    )