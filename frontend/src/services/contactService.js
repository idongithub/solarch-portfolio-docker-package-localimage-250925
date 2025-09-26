// Contact service for handling form submissions
// Integrates with backend email functionality

import axios from 'axios';

// Dynamic backend URL based on frontend protocol to handle mixed content issues
const getBackendUrl = () => {
  console.log('🔍 Detecting backend URL...');
  console.log('Current location:', window.location.href);
  console.log('Protocol:', window.location.protocol);
  
  // If explicit backend URL is set (domain access), use it
  if (process.env.REACT_APP_BACKEND_URL) {
    console.log('✅ Using explicit backend URL:', process.env.REACT_APP_BACKEND_URL);
    return process.env.REACT_APP_BACKEND_URL;
  }
  
  // For IP access, determine based on current frontend protocol
  const isHttps = window.location.protocol === 'https:';
  const currentHost = window.location.hostname;
  
  console.log('🔍 IP access detected - Protocol:', isHttps ? 'HTTPS' : 'HTTP');
  
  if (isHttps) {
    // HTTPS frontend uses Kong API Gateway to avoid mixed content issues
    // Kong URL can be configured via environment variable or defaults to current host
    const kongHost = process.env.REACT_APP_KONG_HOST || currentHost;
    const kongPort = process.env.REACT_APP_KONG_PORT || '8443';
    const kongUrl = `https://${kongHost}:${kongPort}`;
    console.log('✅ HTTPS detected - Using Kong proxy URL:', kongUrl);
    return kongUrl;
  } else {
    // HTTP frontend can call HTTP backend directly  
    // Try to construct backend URL from environment or detect from current host
    let backendUrl = process.env.REACT_APP_BACKEND_URL_HTTP;
    
    if (!backendUrl) {
      // Fallback: construct from current host (assuming backend is on port 3001)
      backendUrl = `http://${currentHost}:3001`;
    }
    
    console.log('✅ HTTP detected - Using direct backend URL:', backendUrl);
    return backendUrl;
  }
};

const API_BASE_URL = getBackendUrl();
console.log('🚀 Final API_BASE_URL:', API_BASE_URL);

class ContactService {
  constructor() {
    this.apiClient = axios.create({
      baseURL: `${API_BASE_URL}/api`,
      timeout: 30000, // 30 seconds timeout for email sending
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor for logging
    this.apiClient.interceptors.request.use(
      (config) => {
        console.log('🚀 API Request:', config.method?.toUpperCase(), config.url);
        return config;
      },
      (error) => {
        console.error('❌ Request Error:', error);
        return Promise.reject(error);
      }
    );

    // Response interceptor for error handling
    this.apiClient.interceptors.response.use(
      (response) => {
        console.log('✅ API Response:', response.status, response.config.url);
        return response;
      },
      (error) => {
        console.error('❌ Response Error:', error.response?.status, error.response?.data);
        return Promise.reject(error);
      }
    );
  }

  /**
   * Submit contact form with email notification
   * @param {Object} formData - Contact form data
   * @returns {Promise<Object>} - Response from backend
   */
  async submitContactForm(formData) {
    try {
      // Validate form data
      this.validateFormData(formData);

      // Submit form
      const response = await this.apiClient.post('/contact/send-email', formData);
      
      console.log('✅ Contact form submitted successfully:', response.data);
      
      return {
        success: true,
        data: response.data,
        message: response.data.message || 'Contact form submitted successfully'
      };

    } catch (error) {
      console.error('❌ Error submitting contact form:', error);
      
      // Handle different error types
      if (error.response) {
        // Server responded with error status
        const { status, data } = error.response;
        
        switch (status) {
          case 400:
            return {
              success: false,
              error: 'Invalid form data. Please check your inputs.',
              details: data.detail || 'Validation error'
            };
          case 429:
            return {
              success: false,
              error: 'Too many requests. Please wait a moment before trying again.',
              details: 'Rate limit exceeded'
            };
          case 500:
            return {
              success: false,
              error: 'Server error. Please try again later.',
              details: data.detail || 'Internal server error'
            };
          default:
            return {
              success: false,
              error: `Server error (${status}). Please try again later.`,
              details: data.detail || 'Unknown server error'
            };
        }
      } else if (error.request) {
        // Network error
        return {
          success: false,
          error: 'Network error. Please check your connection and try again.',
          details: 'No response from server'
        };
      } else {
        // Other error
        return {
          success: false,
          error: 'An unexpected error occurred. Please try again.',
          details: error.message
        };
      }
    }
  }

  /**
   * Validate form data before submission
   * @param {Object} formData - Form data to validate
   * @throws {Error} - Validation error
   */
  validateFormData(formData) {
    const required = ['name', 'email', 'message'];
    const missing = required.filter(field => !formData[field]?.trim());
    
    if (missing.length > 0) {
      throw new Error(`Missing required fields: ${missing.join(', ')}`);
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.email)) {
      throw new Error('Invalid email address');
    }

    // Message length validation
    if (formData.message.trim().length < 1) {
      throw new Error('Message is required');
    }

    if (formData.message.trim().length > 2000) {
      throw new Error('Message must be less than 2000 characters');
    }

    // Name length validation
    if (formData.name.trim().length < 2) {
      throw new Error('Name must be at least 2 characters long');
    }

    if (formData.name.trim().length > 100) {
      throw new Error('Name must be less than 100 characters');
    }
  }

  /**
   * Test backend connectivity
   * @returns {Promise<boolean>} - Backend availability
   */
  async testBackendConnection() {
    try {
      const response = await this.apiClient.get('/health');
      return response.status === 200;
    } catch (error) {
      console.error('❌ Backend connection test failed:', error);
      return false;
    }
  }

  /**
   * Get backend health status
   * @returns {Promise<Object>} - Health status
   */
  async getHealthStatus() {
    try {
      const response = await this.apiClient.get('/health');
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return {
        success: false,
        error: 'Backend health check failed'
      };
    }
  }
}

// Export singleton instance
export const contactService = new ContactService();
export default contactService;