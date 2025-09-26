# Email Service for Kamal Singh Portfolio
# Production-ready email functionality with SMTP configuration

import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import os
import logging
from datetime import datetime
from typing import Optional, Dict, Any
from jinja2 import Template
import asyncio
from functools import wraps
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class EmailService:
    def __init__(self):
        """Initialize email service with SMTP configuration from environment variables"""
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', '587'))
        self.smtp_username = os.getenv('SMTP_USERNAME', '')
        self.smtp_password = os.getenv('SMTP_PASSWORD', '')
        self.from_email = os.getenv('FROM_EMAIL', self.smtp_username)
        self.to_email = os.getenv('TO_EMAIL', 'kamal.singh@architecturesolutions.co.uk')
        self.use_tls = os.getenv('SMTP_USE_TLS', 'true').lower() == 'true'
        
        # Rate limiting
        self.rate_limit_window = int(os.getenv('EMAIL_RATE_LIMIT_WINDOW', '3600'))  # 1 hour
        self.rate_limit_max = int(os.getenv('EMAIL_RATE_LIMIT_MAX', '10'))  # 10 emails per hour
        self.email_timestamps = []
        
        # Validate configuration
        if not all([self.smtp_username, self.smtp_password, self.to_email]):
            logger.warning("Email service not fully configured. Check environment variables.")
    
    def rate_limit_check(self) -> bool:
        """Check if rate limit is exceeded"""
        current_time = time.time()
        # Remove old timestamps outside the window
        self.email_timestamps = [ts for ts in self.email_timestamps 
                               if current_time - ts < self.rate_limit_window]
        
        if len(self.email_timestamps) >= self.rate_limit_max:
            logger.warning(f"Rate limit exceeded: {len(self.email_timestamps)} emails in the last {self.rate_limit_window} seconds")
            return False
        
        self.email_timestamps.append(current_time)
        return True
    
    def create_html_template(self, contact_data: Dict[str, Any]) -> str:
        """Create professional HTML email template"""
        html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Contact Form Submission</title>
    <style>
        body {
            font-family: Georgia, serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #1e3a8a, #374151);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .header p {
            margin: 5px 0 0 0;
            opacity: 0.9;
        }
        .content {
            margin-bottom: 30px;
        }
        .field {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #f8fafc;
            border-left: 4px solid #d97706;
            border-radius: 4px;
        }
        .field-label {
            font-weight: bold;
            color: #1e3a8a;
            margin-bottom: 5px;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 1px;
        }
        .field-value {
            color: #374151;
            font-size: 16px;
        }
        .message-field {
            background-color: #f0f9ff;
            border-left-color: #1e3a8a;
        }
        .footer {
            border-top: 2px solid #e5e7eb;
            padding-top: 20px;
            text-align: center;
            color: #6b7280;
            font-size: 14px;
        }
        .timestamp {
            font-style: italic;
            color: #9ca3af;
        }
        .priority-high {
            border-left-color: #dc2626;
            background-color: #fef2f2;
        }
        .priority-urgent {
            border-left-color: #dc2626;
            background-color: #fef2f2;
            border: 2px solid #dc2626;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📧 New Contact Form Submission</h1>
            <p>Portfolio Website - Professional Inquiry</p>
        </div>
        
        <div class="content">
            <div class="field">
                <div class="field-label">👤 Contact Name</div>
                <div class="field-value">{{ name }}</div>
            </div>
            
            <div class="field">
                <div class="field-label">📧 Email Address</div>
                <div class="field-value">{{ email }}</div>
            </div>
            
            {% if company %}
            <div class="field">
                <div class="field-label">🏢 Company</div>
                <div class="field-value">{{ company }}</div>
            </div>
            {% endif %}
            
            {% if role %}
            <div class="field">
                <div class="field-label">💼 Role/Position</div>
                <div class="field-value">{{ role }}</div>
            </div>
            {% endif %}
            
            {% if projectType %}
            <div class="field">
                <div class="field-label">🚀 Project Type</div>
                <div class="field-value">{{ projectType }}</div>
            </div>
            {% endif %}
            
            {% if budget %}
            <div class="field">
                <div class="field-label">💰 Budget Range</div>
                <div class="field-value">{{ budget }}</div>
            </div>
            {% endif %}
            
            {% if timeline %}
            <div class="field">
                <div class="field-label">⏰ Timeline</div>
                <div class="field-value">{{ timeline }}</div>
            </div>
            {% endif %}
            
            {% if message %}
            <div class="field message-field">
                <div class="field-label">💬 Message</div>
                <div class="field-value">{{ message }}</div>
            </div>
            {% endif %}
        </div>
        
        <div class="footer">
            <p><strong>Kamal Singh - IT Portfolio Architect</strong></p>
            <p>📍 Amersham, United Kingdom | 📧 kamal.singh@architecturesolutions.co.uk</p>
            <p class="timestamp">Received: {{ timestamp }}</p>
            <p><em>This message was sent from the portfolio contact form at {{ website_url }}</em></p>
        </div>
    </div>
</body>
</html>
        """
        
        template = Template(html_template)
        return template.render(
            **contact_data,
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC"),
            website_url=os.getenv('WEBSITE_URL', 'http://localhost:3000')
        )
    
    def create_text_template(self, contact_data: Dict[str, Any]) -> str:
        """Create plain text email template"""
        text_content = f"""
NEW CONTACT FORM SUBMISSION
==========================

Contact Details:
- Name: {contact_data.get('name', 'Not provided')}
- Email: {contact_data.get('email', 'Not provided')}
- Company: {contact_data.get('company', 'Not provided')}
- Role: {contact_data.get('role', 'Not provided')}

Project Information:
- Project Type: {contact_data.get('projectType', 'Not specified')}
- Budget Range: {contact_data.get('budget', 'Not specified')}
- Timeline: {contact_data.get('timeline', 'Not specified')}

Message:
{contact_data.get('message', 'No message provided')}

==========================
Received: {datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")}
From: Portfolio Contact Form
Website: {os.getenv('WEBSITE_URL', 'http://localhost:3000')}

Kamal Singh - IT Portfolio Architect
Amersham, United Kingdom
kamal.singh@architecturesolutions.co.uk
        """
        return text_content.strip()
    
    def create_auto_reply_template(self, contact_name: str) -> str:
        """Create auto-reply HTML template"""
        auto_reply_html = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thank You - Message Received</title>
    <style>
        body {{
            font-family: Georgia, serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }}
        .header {{
            background: linear-gradient(135deg, #1e3a8a, #374151);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 30px;
        }}
        .content {{
            color: #374151;
            font-size: 16px;
        }}
        .signature {{
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e5e7eb;
            color: #6b7280;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✅ Thank You for Your Inquiry</h1>
        </div>
        
        <div class="content">
            <p>Dear {contact_name},</p>
            
            <p>Thank you for reaching out through my portfolio website. I have received your message and appreciate your interest in my architecture and consulting services.</p>
            
            <p><strong>What happens next?</strong></p>
            <ul>
                <li>I will review your inquiry within 24 hours</li>
                <li>You can expect a personalized response within 1-2 business days</li>
                <li>If your project requires immediate attention, please call me directly</li>
            </ul>
            
            <p>In the meantime, feel free to explore my portfolio to learn more about my expertise in Enterprise Architecture, Digital Transformation, and Cloud Solutions.</p>
            
            <div class="signature">
                <p><strong>Best regards,</strong></p>
                <p><strong>Kamal Singh</strong><br>
                IT Portfolio Architect<br>
                📧 kamal.singh@architecturesolutions.co.uk<br>
                📱 07908 521 588<br>
                📍 Amersham, United Kingdom</p>
                
                <p><em>Specializing in Enterprise Architecture • Digital Transformation • Cloud Migration</em></p>
            </div>
        </div>
    </div>
</body>
</html>
        """
        return auto_reply_html
    
    async def send_email(self, contact_data: Dict[str, Any]) -> Dict[str, Any]:
        """Send email notification and auto-reply"""
        try:
            # Rate limit check
            if not self.rate_limit_check():
                return {
                    "success": False,
                    "error": "Rate limit exceeded. Please try again later.",
                    "code": "RATE_LIMIT_EXCEEDED"
                }
            
            # Check configuration
            if not all([self.smtp_username, self.smtp_password, self.to_email]):
                logger.error("Email service not configured properly")
                return {
                    "success": False,
                    "error": "Email service not configured",
                    "code": "CONFIG_ERROR"
                }
            
            # Create connection
            context = ssl.create_default_context()
            
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                if self.use_tls:
                    server.starttls(context=context)
                server.login(self.smtp_username, self.smtp_password)
                
                # Send notification email to Kamal
                await self._send_notification_email(server, contact_data)
                
                # Send auto-reply to sender
                await self._send_auto_reply(server, contact_data)
                
                logger.info(f"Emails sent successfully for contact: {contact_data.get('email')}")
                
                return {
                    "success": True,
                    "message": "Email sent successfully",
                    "timestamp": datetime.now().isoformat()
                }
                
        except smtplib.SMTPAuthenticationError:
            logger.error("SMTP authentication failed")
            return {
                "success": False,
                "error": "Email authentication failed",
                "code": "AUTH_ERROR"
            }
        except smtplib.SMTPException as e:
            logger.error(f"SMTP error: {str(e)}")
            return {
                "success": False,
                "error": f"Email service error: {str(e)}",
                "code": "SMTP_ERROR"
            }
        except Exception as e:
            logger.error(f"Unexpected error sending email: {str(e)}")
            return {
                "success": False,
                "error": f"Unexpected error: {str(e)}",
                "code": "UNKNOWN_ERROR"
            }
    
    async def _send_notification_email(self, server: smtplib.SMTP, contact_data: Dict[str, Any]):
        """Send notification email to Kamal Singh"""
        # Create multipart message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = f"🔔 New Portfolio Inquiry from {contact_data.get('name', 'Unknown')}"
        msg['From'] = self.from_email
        msg['To'] = self.to_email
        msg['Reply-To'] = contact_data.get('email', '')
        
        # Create text and HTML versions
        text_content = self.create_text_template(contact_data)
        html_content = self.create_html_template(contact_data)
        
        # Attach parts
        text_part = MIMEText(text_content, 'plain')
        html_part = MIMEText(html_content, 'html')
        
        msg.attach(text_part)
        msg.attach(html_part)
        
        # Send email
        server.send_message(msg)
        logger.info(f"Notification email sent to {self.to_email}")
    
    async def _send_auto_reply(self, server: smtplib.SMTP, contact_data: Dict[str, Any]):
        """Send auto-reply to the contact"""
        sender_email = contact_data.get('email')
        if not sender_email:
            return
        
        # Create auto-reply message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = "✅ Thank you for your inquiry - Kamal Singh Portfolio"
        msg['From'] = self.from_email
        msg['To'] = sender_email
        
        # Create HTML auto-reply
        html_content = self.create_auto_reply_template(contact_data.get('name', 'there'))
        
        # Simple text version
        text_content = f"""
Dear {contact_data.get('name', 'there')},

Thank you for reaching out through my portfolio website. I have received your message and appreciate your interest in my architecture and consulting services.

I will review your inquiry and respond within 1-2 business days.

Best regards,
Kamal Singh
IT Portfolio Architect
kamal.singh@architecturesolutions.co.uk
        """
        
        # Attach parts
        text_part = MIMEText(text_content.strip(), 'plain')
        html_part = MIMEText(html_content, 'html')
        
        msg.attach(text_part)
        msg.attach(html_part)
        
        # Send auto-reply
        server.send_message(msg)
        logger.info(f"Auto-reply sent to {sender_email}")

# Global email service instance
email_service = EmailService()