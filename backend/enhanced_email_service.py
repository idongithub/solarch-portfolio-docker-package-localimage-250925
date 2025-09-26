# Enhanced Email Service with HTML templates and advanced features
# Phase 2 Enhancement: Professional email templates and improved functionality

import os
import smtplib
import ssl
import time
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from jinja2 import Template
from logging_config import get_logger, log_email_attempt, log_performance

logger = get_logger(__name__)

@dataclass
class EmailConfig:
    """Email configuration settings"""
    smtp_server: str
    smtp_port: int
    use_tls: bool = True
    use_ssl: bool = False
    starttls: bool = True
    timeout: int = 30
    retries: int = 3
    debug: bool = False
    verify_cert: bool = True
    local_hostname: str = ""
    auth: bool = True

@dataclass
class EmailCredentials:
    """Email authentication credentials"""
    username: str
    password: str
    from_email: str

@dataclass
class EmailRecipients:
    """Email recipient configuration"""
    to_email: str
    reply_to_email: Optional[str] = None
    cc_email: Optional[str] = None
    bcc_email: Optional[str] = None

@dataclass
class EmailContent:
    """Email content configuration"""
    subject_prefix: str = "[Portfolio Contact]"
    template: str = "default"
    charset: str = "utf-8"

class EnhancedEmailService:
    """Enhanced email service with templates and advanced features"""
    
    def __init__(self):
        self.config = self._load_config()
        self.credentials = self._load_credentials()
        self.recipients = self._load_recipients()
        self.content_config = self._load_content_config()
        self.templates = self._load_templates()
        
        # Rate limiting
        self.rate_limit_window = int(os.getenv('EMAIL_RATE_LIMIT_WINDOW', '3600'))
        self.rate_limit_max = int(os.getenv('EMAIL_RATE_LIMIT_MAX', '10'))
        self.email_cooldown = int(os.getenv('EMAIL_COOLDOWN_PERIOD', '60'))
        self.last_email_time = 0
        self.email_count_window = []
        
        logger.info("Enhanced Email Service initialized", extra={
            'smtp_server': self.config.smtp_server,
            'smtp_port': self.config.smtp_port,
            'use_tls': self.config.use_tls,
            'rate_limit_max': self.rate_limit_max
        })
    
    def _load_config(self) -> EmailConfig:
        """Load SMTP configuration from environment"""
        return EmailConfig(
            smtp_server=os.getenv('SMTP_SERVER', 'smtp.gmail.com'),
            smtp_port=int(os.getenv('SMTP_PORT', '587')),
            use_tls=os.getenv('SMTP_USE_TLS', 'true').lower() == 'true',
            use_ssl=os.getenv('SMTP_USE_SSL', 'false').lower() == 'true',
            starttls=os.getenv('SMTP_STARTTLS', 'true').lower() == 'true',
            timeout=int(os.getenv('SMTP_TIMEOUT', '30')),
            retries=int(os.getenv('SMTP_RETRIES', '3')),
            debug=os.getenv('SMTP_DEBUG', 'false').lower() == 'true',
            verify_cert=os.getenv('SMTP_VERIFY_CERT', 'true').lower() == 'true',
            local_hostname=os.getenv('SMTP_LOCAL_HOSTNAME', ''),
            auth=os.getenv('SMTP_AUTH', 'true').lower() == 'true'
        )
    
    def _load_credentials(self) -> EmailCredentials:
        """Load email credentials from environment"""
        return EmailCredentials(
            username=os.getenv('SMTP_USERNAME', ''),
            password=os.getenv('SMTP_PASSWORD', ''),
            from_email=os.getenv('FROM_EMAIL', os.getenv('SMTP_USERNAME', ''))
        )
    
    def _load_recipients(self) -> EmailRecipients:
        """Load recipient configuration from environment"""
        return EmailRecipients(
            to_email=os.getenv('TO_EMAIL', 'kamal.singh@architecturesolutions.co.uk'),
            reply_to_email=os.getenv('REPLY_TO_EMAIL'),
            cc_email=os.getenv('CC_EMAIL'),
            bcc_email=os.getenv('BCC_EMAIL')
        )
    
    def _load_content_config(self) -> EmailContent:
        """Load email content configuration"""
        return EmailContent(
            subject_prefix=os.getenv('EMAIL_SUBJECT_PREFIX', '[Portfolio Contact]'),
            template=os.getenv('EMAIL_TEMPLATE', 'default'),
            charset=os.getenv('EMAIL_CHARSET', 'utf-8')
        )
    
    def _load_templates(self) -> Dict[str, Dict[str, str]]:
        """Load email templates"""
        return {
            'default': {
                'subject': '{{ subject_prefix }} {{ project_type }} - {{ name }}',
                'html': '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portfolio Contact Form</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 8px 8px; }
        .field { margin-bottom: 20px; }
        .label { font-weight: 600; color: #495057; margin-bottom: 5px; display: block; }
        .value { background: white; padding: 12px; border-radius: 4px; border: 1px solid #dee2e6; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #dee2e6; color: #6c757d; font-size: 14px; }
        .badge { display: inline-block; padding: 4px 12px; background: #e9ecef; color: #495057; border-radius: 20px; font-size: 12px; font-weight: 500; margin: 2px; }
        .priority-high { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        .priority-medium { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 New Portfolio Inquiry</h1>
            <p>ARCHSOL IT Solutions - Professional Services</p>
        </div>
        
        <div class="content">
            <div class="field">
                <span class="label">Contact Information</span>
                <div class="value">
                    <strong>{{ name }}</strong>
                    {% if company %} - {{ company }}{% endif %}
                    {% if role %} ({{ role }}){% endif %}
                    <br>
                    📧 <a href="mailto:{{ email }}">{{ email }}</a>
                </div>
            </div>
            
            {% if project_type %}
            <div class="field">
                <span class="label">Project Type</span>
                <div class="value">
                    <span class="badge">{{ project_type }}</span>
                </div>
            </div>
            {% endif %}
            
            <div class="field">
                <span class="label">Project Details</span>
                <div class="value">
                    {% if budget %}<strong>Budget:</strong> {{ budget }}<br>{% endif %}
                    {% if timeline %}<strong>Timeline:</strong> {{ timeline }}<br>{% endif %}
                </div>
            </div>
            
            <div class="field">
                <span class="label">Message</span>
                <div class="value">{{ message | replace('\n', '<br>') }}</div>
            </div>
            
            {% if attachments %}
            <div class="field">
                <span class="label">Attachments</span>
                <div class="value">
                    {% for attachment in attachments %}
                    📎 {{ attachment }}<br>
                    {% endfor %}
                </div>
            </div>
            {% endif %}
        </div>
        
        <div class="footer">
            <p>Received via ARCHSOL IT Solutions Portfolio Website</p>
            <p>{{ timestamp }}</p>
            <p>
                <strong>Next Steps:</strong><br>
                • Review project requirements<br>
                • Schedule initial consultation call<br>
                • Prepare project proposal
            </p>
        </div>
    </div>
</body>
</html>
                ''',
                'text': '''
New Portfolio Contact Form Submission

Contact Information:
Name: {{ name }}
Email: {{ email }}
{% if company %}Company: {{ company }}{% endif %}
{% if role %}Role: {{ role }}{% endif %}

Project Details:
{% if project_type %}Project Type: {{ project_type }}{% endif %}
{% if budget %}Budget: {{ budget }}{% endif %}
{% if timeline %}Timeline: {{ timeline }}{% endif %}

Message:
{{ message }}

{% if attachments %}
Attachments:
{% for attachment in attachments %}
- {{ attachment }}
{% endfor %}
{% endif %}

---
Received: {{ timestamp }}
Website: ARCHSOL IT Solutions Portfolio
                '''
            },
            'confirmation': {
                'subject': 'Thank you for contacting ARCHSOL IT Solutions - {{ name }}',
                'html': '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thank You - ARCHSOL IT Solutions</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; border-radius: 0 0 8px 8px; }
        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #dee2e6; color: #6c757d; font-size: 14px; }
        .highlight { background: #e3f2fd; padding: 15px; border-radius: 4px; border-left: 4px solid #2196f3; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✅ Thank You, {{ name }}!</h1>
            <p>Your inquiry has been received</p>
        </div>
        
        <div class="content">
            <p>Thank you for reaching out to <strong>ARCHSOL IT Solutions</strong>. I've received your inquiry about <strong>{{ project_type }}</strong> and will review it carefully.</p>
            
            <div class="highlight">
                <h3>What happens next?</h3>
                <ul>
                    <li><strong>Within 24 hours:</strong> I'll review your requirements and prepare an initial response</li>
                    <li><strong>Within 1-2 business days:</strong> You'll receive a detailed response with next steps</li>
                    <li><strong>If urgent:</strong> I'll prioritize your request and respond sooner</li>
                </ul>
            </div>
            
            <p>Your project summary:</p>
            <ul>
                <li><strong>Project Type:</strong> {{ project_type }}</li>
                {% if budget %}<li><strong>Budget:</strong> {{ budget }}</li>{% endif %}
                {% if timeline %}<li><strong>Timeline:</strong> {{ timeline }}</li>{% endif %}
            </ul>
            
            <p>If you have any urgent questions in the meantime, please don't hesitate to reply to this email or contact me directly at <a href="mailto:kamal.singh@architecturesolutions.co.uk">kamal.singh@architecturesolutions.co.uk</a>.</p>
            
            <p>Best regards,<br>
            <strong>Kamal Singh</strong><br>
            IT Portfolio Architect<br>
            ARCHSOL IT Solutions</p>
        </div>
        
        <div class="footer">
            <p>ARCHSOL IT Solutions - Enterprise Architecture & Digital Transformation</p>
            <p>LinkedIn: <a href="#">linkedin.com/in/kamal-singh-architect</a></p>
        </div>
    </div>
</body>
</html>
                ''',
                'text': '''
Thank you for contacting ARCHSOL IT Solutions!

Dear {{ name }},

Thank you for reaching out about {{ project_type }}. I've received your inquiry and will review it carefully.

What happens next:
- Within 24 hours: I'll review your requirements
- Within 1-2 business days: You'll receive a detailed response
- If urgent: I'll prioritize your request

Your project summary:
- Project Type: {{ project_type }}
{% if budget %}Budget: {{ budget }}{% endif %}
{% if timeline %}Timeline: {{ timeline }}{% endif %}

For urgent questions, contact me directly at:
kamal.singh@architecturesolutions.co.uk

Best regards,
Kamal Singh
IT Portfolio Architect
ARCHSOL IT Solutions
                '''
            }
        }
    
    def check_rate_limit(self) -> Tuple[bool, str]:
        """Check if email sending is within rate limits"""
        current_time = time.time()
        
        # Check cooldown period
        if current_time - self.last_email_time < self.email_cooldown:
            remaining = int(self.email_cooldown - (current_time - self.last_email_time))
            return False, f"Please wait {remaining} seconds before sending another email"
        
        # Clean old entries from rate limit window
        window_start = current_time - self.rate_limit_window
        self.email_count_window = [t for t in self.email_count_window if t > window_start]
        
        # Check rate limit
        if len(self.email_count_window) >= self.rate_limit_max:
            return False, f"Rate limit exceeded. Maximum {self.rate_limit_max} emails per {self.rate_limit_window//60} minutes"
        
        return True, ""
    
    def send_contact_form_email(self, form_data: Dict) -> Tuple[bool, str]:
        """Send contact form email with enhanced templates"""
        
        # Check rate limits
        allowed, error_msg = self.check_rate_limit()
        if not allowed:
            logger.warning("Rate limit exceeded", extra={
                'operation': 'send_email',
                'reason': 'rate_limit',
                'error': error_msg
            })
            return False, error_msg
        
        # Validate credentials
        if not self.credentials.username or not self.credentials.password:
            logger.error("SMTP credentials not configured")
            return False, "Email service not configured"
        
        start_time = time.time()
        
        try:
            with log_performance(logger, "send_contact_email", 
                               recipient=form_data.get('email', 'unknown')):
                
                # Send notification email to admin
                admin_success, admin_error = self._send_notification_email(form_data)
                
                # Send confirmation email to user
                confirmation_success, confirmation_error = self._send_confirmation_email(form_data)
                
                # Update rate limiting
                current_time = time.time()
                self.email_count_window.append(current_time)
                self.last_email_time = current_time
                
                # Determine overall success
                if admin_success:
                    if confirmation_success:
                        return True, "Emails sent successfully"
                    else:
                        logger.warning("Confirmation email failed", extra={
                            'error': confirmation_error,
                            'admin_success': True
                        })
                        return True, "Notification sent, confirmation email failed"
                else:
                    logger.error("Notification email failed", extra={
                        'error': admin_error,
                        'confirmation_success': confirmation_success
                    })
                    return False, admin_error
                    
        except Exception as e:
            duration = time.time() - start_time
            log_email_attempt(logger, form_data.get('email', 'unknown'), 
                            self.config.smtp_server, False, duration, str(e))
            return False, f"Email service error: {str(e)}"
    
    def _send_notification_email(self, form_data: Dict) -> Tuple[bool, str]:
        """Send notification email to admin"""
        try:
            # Prepare template data
            template_data = {
                **form_data,
                'subject_prefix': self.content_config.subject_prefix,
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S UTC'),
                'attachments': form_data.get('attachments', [])
            }
            
            # Render templates
            subject_template = Template(self.templates['default']['subject'])
            html_template = Template(self.templates['default']['html'])
            text_template = Template(self.templates['default']['text'])
            
            subject = subject_template.render(**template_data)
            html_body = html_template.render(**template_data)
            text_body = text_template.render(**template_data)
            
            # Send email
            return self._send_email(
                to_email=self.recipients.to_email,
                subject=subject,
                html_body=html_body,
                text_body=text_body,
                reply_to=form_data.get('email')
            )
            
        except Exception as e:
            logger.error("Failed to send notification email", exc_info=True)
            return False, str(e)
    
    def _send_confirmation_email(self, form_data: Dict) -> Tuple[bool, str]:
        """Send confirmation email to user"""
        try:
            # Prepare template data
            template_data = {
                **form_data,
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S UTC')
            }
            
            # Render templates
            subject_template = Template(self.templates['confirmation']['subject'])
            html_template = Template(self.templates['confirmation']['html'])
            text_template = Template(self.templates['confirmation']['text'])
            
            subject = subject_template.render(**template_data)
            html_body = html_template.render(**template_data)
            text_body = text_template.render(**template_data)
            
            # Send email
            return self._send_email(
                to_email=form_data['email'],
                subject=subject,
                html_body=html_body,
                text_body=text_body,
                reply_to=self.recipients.to_email
            )
            
        except Exception as e:
            logger.error("Failed to send confirmation email", exc_info=True)
            return False, str(e)
    
    def _send_email(self, to_email: str, subject: str, html_body: str, 
                   text_body: str, reply_to: str = None) -> Tuple[bool, str]:
        """Send email using SMTP"""
        
        start_time = time.time()
        
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['From'] = self.credentials.from_email
            msg['To'] = to_email
            msg['Subject'] = subject
            
            if reply_to:
                msg['Reply-To'] = reply_to
            
            if self.recipients.cc_email:
                msg['Cc'] = self.recipients.cc_email
            
            # Attach text and HTML parts
            text_part = MIMEText(text_body, 'plain', self.content_config.charset)
            html_part = MIMEText(html_body, 'html', self.content_config.charset)
            
            msg.attach(text_part)
            msg.attach(html_part)
            
            # Connect to SMTP server
            if self.config.use_ssl:
                context = ssl.create_default_context()
                if not self.config.verify_cert:
                    context.check_hostname = False
                    context.verify_mode = ssl.CERT_NONE
                
                server = smtplib.SMTP_SSL(
                    self.config.smtp_server, 
                    self.config.smtp_port, 
                    context=context,
                    timeout=self.config.timeout
                )
            else:
                server = smtplib.SMTP(
                    self.config.smtp_server, 
                    self.config.smtp_port,
                    timeout=self.config.timeout
                )
                
                if self.config.starttls:
                    context = ssl.create_default_context()
                    if not self.config.verify_cert:
                        context.check_hostname = False
                        context.verify_mode = ssl.CERT_NONE
                    server.starttls(context=context)
            
            # Enable debug if configured
            if self.config.debug:
                server.set_debuglevel(1)
            
            # Login and send
            if self.config.auth:
                server.login(self.credentials.username, self.credentials.password)
            
            # Prepare recipient list
            recipients = [to_email]
            if self.recipients.cc_email:
                recipients.append(self.recipients.cc_email)
            if self.recipients.bcc_email:
                recipients.append(self.recipients.bcc_email)
            
            # Send email
            server.send_message(msg, to_addrs=recipients)
            server.quit()
            
            duration = time.time() - start_time
            log_email_attempt(logger, to_email, self.config.smtp_server, True, duration)
            
            return True, "Email sent successfully"
            
        except Exception as e:
            duration = time.time() - start_time
            log_email_attempt(logger, to_email, self.config.smtp_server, False, duration, str(e))
            return False, str(e)
    
    def get_service_status(self) -> Dict:
        """Get email service status and configuration"""
        return {
            'configured': bool(self.credentials.username and self.credentials.password),
            'smtp_server': self.config.smtp_server,
            'smtp_port': self.config.smtp_port,
            'use_tls': self.config.use_tls,
            'use_ssl': self.config.use_ssl,
            'rate_limit_max': self.rate_limit_max,
            'rate_limit_window': self.rate_limit_window,
            'cooldown_period': self.email_cooldown,
            'current_window_count': len(self.email_count_window),
            'templates_available': list(self.templates.keys())
        }

# Global service instance
enhanced_email_service = EnhancedEmailService()