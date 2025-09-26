import React, { useState, useEffect } from 'react';
import { Send } from 'lucide-react';
import LocalCaptcha from './LocalCaptcha';

const SimpleContact = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
    website: '' // Honeypot field
  });
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState('');
  const [recaptchaLoaded, setRecaptchaLoaded] = useState(false);
  
  // Local captcha state
  const [localCaptchaData, setLocalCaptchaData] = useState(null);
  const [localCaptchaValid, setLocalCaptchaValid] = useState(false);
  
  // Get environment variables from build-time or runtime (MOVED TO TOP)
  const getEnvVar = (key) => {
    // First try build-time env vars
    if (process.env[key]) {
      return process.env[key];
    }
    
    // Then try runtime config (for Docker)
    if (window.ENV && window.ENV[key]) {
      return window.ENV[key];
    }
    
    // Fallback defaults
    const defaults = {
      'REACT_APP_KONG_HOST': '192.168.86.75',
      'REACT_APP_KONG_PORT': '8443',
      'REACT_APP_BACKEND_URL_HTTP': 'http://192.168.86.75:3001',
      'REACT_APP_RECAPTCHA_SITE_KEY': '6LcgftMrAAAAAPJRuWA4mQgstPWYoIXoPM4PBjMM'
    };
    
    return defaults[key] || '';
  };
  
  // Detect if this is IP-based access (local) or domain-based access
  const isLocalAccess = () => {
    const hostname = window.location.hostname;
    // Check if hostname is an IP address or localhost
    return hostname.match(/^\d+\.\d+\.\d+\.\d+$/) || 
           hostname === 'localhost' || 
           hostname === '127.0.0.1';
  };

  const useLocalCaptcha = isLocalAccess();

  // Load reCAPTCHA (only for domain-based access)
  useEffect(() => {
    if (useLocalCaptcha) {
      console.log('🏠 Local access detected - using local captcha');
      return;
    }
    
    console.log('🌐 Domain access detected - using Google reCAPTCHA');
    const siteKey = getEnvVar('REACT_APP_RECAPTCHA_SITE_KEY');
    console.log('🔍 reCAPTCHA initialization:', {
      siteKey: siteKey ? `${siteKey.substring(0, 20)}...` : 'undefined',
      protocol: window.location.protocol,
      grecaptchaExists: !!window.grecaptcha
    });
    
    if (siteKey && !window.grecaptcha) {
      const script = document.createElement('script');
      script.src = `https://www.google.com/recaptcha/api.js?render=${siteKey}`;
      script.onload = () => {
        console.log('✅ reCAPTCHA script loaded successfully');
        setRecaptchaLoaded(true);
      };
      script.onerror = (error) => {
        console.error('❌ reCAPTCHA script failed to load:', error);
        setRecaptchaLoaded(false);
      };
      document.head.appendChild(script);
    } else if (window.grecaptcha) {
      console.log('✅ reCAPTCHA already available');
      setRecaptchaLoaded(true);
    } else if (!siteKey) {
      console.warn('⚠️ REACT_APP_RECAPTCHA_SITE_KEY not configured');
    }
  }, [useLocalCaptcha]);

  // Get backend URL based on current origin
  const getBackendUrl = () => {
    const currentHost = window.location.hostname;
    const isHttps = window.location.protocol === 'https:';
    
    console.log('🔍 Backend URL Detection:');
    console.log('  Protocol:', window.location.protocol);
    console.log('  Hostname:', currentHost);
    console.log('  Kong Host:', getEnvVar('REACT_APP_KONG_HOST'));
    console.log('  Kong Port:', getEnvVar('REACT_APP_KONG_PORT'));
    
    // Domain-based access (not IP address)
    if (!currentHost.match(/^\d+\.\d+\.\d+\.\d+$/) && 
        currentHost !== 'localhost' && 
        getEnvVar('REACT_APP_BACKEND_URL')) {
      const backendUrl = getEnvVar('REACT_APP_BACKEND_URL');
      console.log('✅ Using domain backend URL:', backendUrl);
      return backendUrl;
    }
    
    // IP-based access
    if (isHttps) {
      const kongHost = getEnvVar('REACT_APP_KONG_HOST') || currentHost;
      const kongPort = getEnvVar('REACT_APP_KONG_PORT') || '8443';
      const kongUrl = `https://${kongHost}:${kongPort}`;
      console.log('✅ HTTPS detected - Using Kong proxy URL:', kongUrl);
      return kongUrl;
    } else {
      const backendUrl = getEnvVar('REACT_APP_BACKEND_URL_HTTP') || `http://${currentHost}:3001`;
      console.log('✅ HTTP detected - Using direct backend URL:', backendUrl);
      return backendUrl;
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log('Form submitted!', formData);
    
    // Simple validation
    if (!formData.name || !formData.email || !formData.message) {
      setStatus('Please fill in all fields');
      return;
    }
    
    // Captcha validation
    if (useLocalCaptcha) {
      if (!localCaptchaValid) {
        setStatus('Please solve the math question correctly');
        return;
      }
    }
    
    setIsSubmitting(true);
    setStatus('Sending...');
    
    try {
      let securityToken = '';
      
      if (useLocalCaptcha) {
        // Use local captcha data
        console.log('✅ Using local captcha verification');
        securityToken = JSON.stringify({
          type: 'local_captcha',
          captcha_id: localCaptchaData?.captcha_id,
          user_answer: localCaptchaData?.user_answer
        });
      } else {
        // Execute Google reCAPTCHA
        console.log('🔍 reCAPTCHA debug info:');
        console.log('  recaptchaLoaded:', recaptchaLoaded);
        console.log('  window.grecaptcha exists:', !!window.grecaptcha);
        console.log('  REACT_APP_RECAPTCHA_SITE_KEY:', getEnvVar('REACT_APP_RECAPTCHA_SITE_KEY'));
        
        if (recaptchaLoaded && window.grecaptcha && getEnvVar('REACT_APP_RECAPTCHA_SITE_KEY')) {
          console.log('✅ Executing reCAPTCHA...');
          try {
            securityToken = await new Promise((resolve, reject) => {
              window.grecaptcha.ready(() => {
                window.grecaptcha.execute(getEnvVar('REACT_APP_RECAPTCHA_SITE_KEY'), {
                  action: 'contact_form'
                }).then((token) => {
                  console.log('✅ reCAPTCHA token received:', token ? `${token.substring(0, 20)}...` : 'empty');
                  resolve(token);
                }).catch(reject);
              });
            });
          } catch (captchaError) {
            console.error('❌ reCAPTCHA execution failed:', captchaError);
            securityToken = '';
          }
        } else {
          console.log('⚠️ reCAPTCHA not available - skipping token generation');
        }
      }

      const backendUrl = getBackendUrl();
      const apiUrl = `${backendUrl}/api/contact/send-email`;
      console.log('Current origin:', window.location.origin);
      console.log('Sending request to:', apiUrl);
      
      const requestData = {
        name: formData.name,
        email: formData.email,
        projectType: 'Contact Form',
        budget: 'Not specified',
        timeline: 'Not specified', 
        message: formData.message,
        recaptcha_token: useLocalCaptcha ? '' : securityToken,
        local_captcha: useLocalCaptcha ? securityToken : ''
      };
      
      console.log('🎯 Request data being sent:', {
        ...requestData,
        recaptcha_token: requestData.recaptcha_token ? `${requestData.recaptcha_token.substring(0, 20)}...` : 'empty/null',
        local_captcha: requestData.local_captcha ? 'local_captcha_data' : 'empty'
      });
      console.log('📊 Security token length:', securityToken ? securityToken.length : 'null');
      
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData)
      });
      
      console.log('Response status:', response.status);
      console.log('Response headers:', response.headers);
      
      let result;
      const responseText = await response.text();
      console.log('Raw response:', responseText);
      
      try {
        result = JSON.parse(responseText);
        console.log('Parsed response data:', result);
      } catch (e) {
        console.error('Failed to parse response as JSON:', e);
        result = { success: false, message: 'Invalid server response' };
      }
      
      if (response.ok && result.success) {
        setStatus('Message sent successfully!');
        setFormData({ name: '', email: '', message: '' });
      } else {
        setStatus('Failed to send message. Please try again.');
      }
    } catch (error) {
      console.error('Error:', error);
      setStatus('Error sending message. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <section className="py-12 bg-slate-50">
      <div className="max-w-2xl mx-auto px-6">
        <div className="bg-white rounded-lg p-8 shadow-lg">
          <h2 className="text-2xl font-bold text-slate-800 mb-6">Contact Me</h2>
          
          {status && (
            <div className={`mb-4 p-3 rounded ${
              status.includes('successfully') 
                ? 'bg-green-100 text-green-700' 
                : status.includes('Error') || status.includes('Failed')
                ? 'bg-red-100 text-red-700'
                : 'bg-blue-100 text-blue-700'
            }`}>
              {status}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Name *
              </label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Your name"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Email *
              </label>
              <input
                type="email" 
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="your@email.com"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-2">
                Message *
              </label>
              <textarea
                name="message"
                value={formData.message}
                onChange={handleChange}
                required
                rows={4}
                className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Your message..."
              />
            </div>

            {/* Captcha Section */}
            {useLocalCaptcha ? (
              <LocalCaptcha
                onCaptchaChange={setLocalCaptchaData}
                isValid={localCaptchaValid}
                setIsValid={setLocalCaptchaValid}
              />
            ) : (
              <div className="bg-blue-50 p-3 rounded-lg border border-blue-200">
                <div className="text-sm text-blue-700">
                  🛡️ Protected by Google reCAPTCHA
                  {recaptchaLoaded ? (
                    <span className="text-green-600 ml-2">✅ Ready</span>
                  ) : (
                    <span className="text-yellow-600 ml-2">⏳ Loading...</span>
                  )}
                </div>
              </div>
            )}

            {/* Honeypot field - hidden from users */}
            <input
              type="text"
              name="website"
              value={formData.website}
              onChange={handleChange}
              style={{ display: 'none' }}
              tabIndex="-1"
              autoComplete="off"
            />

            <button
              type="submit"
              disabled={isSubmitting}
              className={`w-full flex items-center justify-center px-6 py-3 rounded-lg font-medium transition-colors ${
                isSubmitting
                  ? 'bg-slate-400 cursor-not-allowed'
                  : 'bg-blue-600 hover:bg-blue-700 text-white'
              }`}
            >
              {isSubmitting ? (
                'Sending...'
              ) : (
                <>
                  <Send className="mr-2" size={16} />
                  Send Message
                </>
              )}
            </button>
          </form>
        </div>
      </div>
    </section>
  );
};

export default SimpleContact;