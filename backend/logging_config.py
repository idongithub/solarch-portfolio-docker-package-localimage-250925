# Enhanced Logging Configuration for Phase 2
# Structured logging with performance monitoring and analytics

import os
import sys
import json
import logging
import logging.handlers
from datetime import datetime
from pathlib import Path
from contextlib import contextmanager
from typing import Dict, Any, Optional
import traceback
import time

class StructuredFormatter(logging.Formatter):
    """Custom formatter for structured JSON logging"""
    
    def format(self, record):
        # Create structured log entry
        log_entry = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        # Add extra fields if present
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        if hasattr(record, 'duration'):
            log_entry['duration_ms'] = record.duration
        if hasattr(record, 'status_code'):
            log_entry['status_code'] = record.status_code
        if hasattr(record, 'method'):
            log_entry['method'] = record.method
        if hasattr(record, 'path'):
            log_entry['path'] = record.path
        if hasattr(record, 'ip_address'):
            log_entry['ip_address'] = record.ip_address
        if hasattr(record, 'user_agent'):
            log_entry['user_agent'] = record.user_agent
        if hasattr(record, 'email_recipient'):
            log_entry['email_recipient'] = record.email_recipient
        if hasattr(record, 'smtp_server'):
            log_entry['smtp_server'] = record.smtp_server
        if hasattr(record, 'error_type'):
            log_entry['error_type'] = record.error_type
        
        # Add exception info if present
        if record.exc_info:
            log_entry['exception'] = {
                'type': record.exc_info[0].__name__,
                'value': str(record.exc_info[1]),
                'traceback': traceback.format_exception(*record.exc_info)
            }
        
        # Add stack trace for errors
        if record.levelno >= logging.ERROR and not record.exc_info:
            log_entry['stack_trace'] = traceback.format_stack()
        
        return json.dumps(log_entry)

class PerformanceLogger:
    """Context manager for logging performance metrics"""
    
    def __init__(self, logger: logging.Logger, operation: str, **kwargs):
        self.logger = logger
        self.operation = operation
        self.kwargs = kwargs
        self.start_time = None
    
    def __enter__(self):
        self.start_time = time.time()
        self.logger.info(f"Starting {self.operation}", extra={
            'operation': self.operation,
            'phase': 'start',
            **self.kwargs
        })
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        duration = (time.time() - self.start_time) * 1000  # Convert to ms
        
        if exc_type:
            self.logger.error(f"Failed {self.operation}", extra={
                'operation': self.operation,
                'phase': 'error',
                'duration': duration,
                'error_type': exc_type.__name__,
                **self.kwargs
            }, exc_info=True)
        else:
            self.logger.info(f"Completed {self.operation}", extra={
                'operation': self.operation,
                'phase': 'complete',
                'duration': duration,
                **self.kwargs
            })

class LoggingConfig:
    """Centralized logging configuration"""
    
    def __init__(self):
        self.log_dir = Path("/app/logs")
        self.log_dir.mkdir(exist_ok=True)
        
        # Determine log level from environment
        self.log_level = getattr(logging, os.getenv('LOG_LEVEL', 'INFO').upper(), logging.INFO)
        
        # Environment settings
        self.is_production = os.getenv('ENVIRONMENT', 'development') == 'production'
        self.enable_structured_logging = os.getenv('STRUCTURED_LOGGING', 'true').lower() == 'true'
        
    def setup_logging(self):
        """Configure logging for the application"""
        
        # Create root logger
        root_logger = logging.getLogger()
        root_logger.setLevel(self.log_level)
        
        # Remove default handlers
        for handler in root_logger.handlers[:]:
            root_logger.removeHandler(handler)
        
        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(self.log_level)
        
        if self.enable_structured_logging:
            console_handler.setFormatter(StructuredFormatter())
        else:
            console_formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            console_handler.setFormatter(console_formatter)
        
        root_logger.addHandler(console_handler)
        
        # File handlers for different log levels
        self._setup_file_handlers(root_logger)
        
        # Set up specific loggers
        self._setup_specific_loggers()
        
        # Log configuration
        logger = logging.getLogger(__name__)
        logger.info("Logging configuration initialized", extra={
            'log_level': logging.getLevelName(self.log_level),
            'structured_logging': self.enable_structured_logging,
            'production': self.is_production,
            'log_directory': str(self.log_dir)
        })
    
    def _setup_file_handlers(self, root_logger: logging.Logger):
        """Set up rotating file handlers"""
        
        # All logs file
        all_logs_handler = logging.handlers.RotatingFileHandler(
            self.log_dir / "application.log",
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        all_logs_handler.setLevel(logging.DEBUG)
        
        # Error logs file
        error_logs_handler = logging.handlers.RotatingFileHandler(
            self.log_dir / "errors.log",
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        error_logs_handler.setLevel(logging.ERROR)
        
        # Performance logs file
        performance_logs_handler = logging.handlers.RotatingFileHandler(
            self.log_dir / "performance.log",
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        performance_logs_handler.setLevel(logging.INFO)
        performance_logs_handler.addFilter(lambda record: hasattr(record, 'duration'))
        
        if self.enable_structured_logging:
            formatter = StructuredFormatter()
            all_logs_handler.setFormatter(formatter)
            error_logs_handler.setFormatter(formatter)
            performance_logs_handler.setFormatter(formatter)
        else:
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            all_logs_handler.setFormatter(formatter)
            error_logs_handler.setFormatter(formatter)
            performance_logs_handler.setFormatter(formatter)
        
        root_logger.addHandler(all_logs_handler)
        root_logger.addHandler(error_logs_handler)
        root_logger.addHandler(performance_logs_handler)
    
    def _setup_specific_loggers(self):
        """Configure specific loggers for different components"""
        
        # FastAPI/Uvicorn logger
        uvicorn_logger = logging.getLogger("uvicorn")
        uvicorn_logger.setLevel(self.log_level)
        
        # Email logger
        email_logger = logging.getLogger("email")
        email_logger.setLevel(logging.INFO)
        
        # Security logger
        security_logger = logging.getLogger("security")
        security_logger.setLevel(logging.WARNING)
        
        # Database logger
        db_logger = logging.getLogger("database")
        db_logger.setLevel(logging.INFO)
        
        # External API logger
        api_logger = logging.getLogger("external_api")
        api_logger.setLevel(logging.INFO)
        
        # Silence noisy third-party loggers in production
        if self.is_production:
            logging.getLogger("urllib3").setLevel(logging.WARNING)
            logging.getLogger("requests").setLevel(logging.WARNING)
    
    @contextmanager
    def log_performance(self, operation: str, logger: Optional[logging.Logger] = None, **kwargs):
        """Context manager for performance logging"""
        if logger is None:
            logger = logging.getLogger(__name__)
        
        with PerformanceLogger(logger, operation, **kwargs):
            yield

# Global logging configuration instance
logging_config = LoggingConfig()

# Convenience functions
def get_logger(name: str) -> logging.Logger:
    """Get a logger with the specified name"""
    return logging.getLogger(name)

def log_api_request(logger: logging.Logger, method: str, path: str, 
                   status_code: int, duration: float, **kwargs):
    """Log API request details"""
    logger.info(f"{method} {path}", extra={
        'method': method,
        'path': path,
        'status_code': status_code,
        'duration': duration * 1000,  # Convert to ms
        'request_type': 'api',
        **kwargs
    })

def log_email_attempt(logger: logging.Logger, recipient: str, smtp_server: str, 
                     success: bool, duration: float = None, error: str = None):
    """Log email sending attempts"""
    level = logging.INFO if success else logging.ERROR
    message = f"Email {'sent' if success else 'failed'} to {recipient}"
    
    extra = {
        'email_recipient': recipient,
        'smtp_server': smtp_server,
        'email_success': success,
        'operation': 'send_email'
    }
    
    if duration:
        extra['duration'] = duration * 1000
    
    if error:
        extra['error_message'] = error
    
    logger.log(level, message, extra=extra)

def log_security_event(logger: logging.Logger, event_type: str, details: Dict[str, Any]):
    """Log security-related events"""
    logger.warning(f"Security event: {event_type}", extra={
        'security_event': event_type,
        'event_details': details,
        **details
    })

def log_database_operation(logger: logging.Logger, operation: str, collection: str,
                          duration: float, success: bool, **kwargs):
    """Log database operations"""
    level = logging.INFO if success else logging.ERROR
    message = f"Database {operation} on {collection}"
    
    logger.log(level, message, extra={
        'database_operation': operation,
        'collection': collection,
        'duration': duration * 1000,
        'db_success': success,
        **kwargs
    })

# Initialize logging when module is imported
if not logging.getLogger().handlers:
    logging_config.setup_logging()