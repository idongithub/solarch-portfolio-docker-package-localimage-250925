from fastapi import FastAPI, APIRouter, HTTPException
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional
import uuid
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Define Models
class StatusCheck(BaseModel):
    status: str = "healthy"
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())

class ContactForm(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., regex=r'^[^@]+@[^@]+\.[^@]+$')
    projectType: str = Field(..., min_length=1)
    budget: str = Field(..., min_length=1)
    timeline: str = Field(..., min_length=1)
    message: str = Field(..., min_length=10, max_length=2000)

# CORS Configuration
cors_origins = os.environ.get('CORS_ORIGINS', 'http://localhost:3000,http://localhost:80,http://localhost').split(',')

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Health Check Endpoints
@app.get("/health")
async def health_check():
    """Health check endpoint for container monitoring"""
    return StatusCheck()

@api_router.get("/health")
async def api_health_check():
    """API health check endpoint"""
    return StatusCheck()

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
        
        # Send email
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(smtp_username, smtp_password)
        text = msg.as_string()
        server.sendmail(from_email, to_email, text)
        server.quit()
        
        logger.info(f"Email sent successfully for contact from {contact_data.email}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send email: {str(e)}")
        return False

@api_router.post("/contact/send-email")
async def send_contact_email(contact_data: ContactForm):
    """Send contact form email"""
    try:
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