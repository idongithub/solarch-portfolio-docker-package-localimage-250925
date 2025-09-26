// Analytics Service for tracking user interactions and performance
// Phase 2 Enhancement: User behavior tracking and performance monitoring

class AnalyticsService {
  constructor() {
    this.isEnabled = process.env.NODE_ENV === 'production';
    this.events = [];
    this.sessionId = this.generateSessionId();
    this.startTime = Date.now();
    
    // Initialize analytics if enabled
    if (this.isEnabled) {
      this.initializeAnalytics();
    }
  }

  generateSessionId() {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  initializeAnalytics() {
    // Skip analytics initialization for local IP address access only
    // Keep analytics enabled for domain access (portfolio.architecturesolutions.co.uk)
    const isLocalIPAccess = window.location.hostname === 'localhost' || 
                           window.location.hostname.includes('192.168.');
    
    if (isLocalIPAccess) {
      console.log('📊 Analytics disabled for local IP access:', window.location.hostname);
      return;
    }
    
    console.log('📊 Analytics enabled for domain access:', window.location.hostname);
    
    // Initialize Google Analytics 4 if GA_MEASUREMENT_ID is available
    if (process.env.REACT_APP_GA_MEASUREMENT_ID) {
      this.initializeGA4();
    }

    // Track page load performance
    this.trackPageLoad();
    
    // Set up automatic performance monitoring
    this.setupPerformanceMonitoring();
  }

  initializeGA4() {
    const measurementId = process.env.REACT_APP_GA_MEASUREMENT_ID;
    
    // Load Google Analytics 4
    const script = document.createElement('script');
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`;
    document.head.appendChild(script);

    // Initialize gtag
    window.dataLayer = window.dataLayer || [];
    function gtag(){window.dataLayer.push(arguments);}
    window.gtag = gtag;
    gtag('js', new Date());
    gtag('config', measurementId, {
      page_title: document.title,
      page_location: window.location.href
    });

    console.log('📊 Google Analytics 4 initialized:', measurementId);
  }

  setupPerformanceMonitoring() {
    // Monitor Core Web Vitals
    if ('web-vital' in window) {
      import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
        getCLS(this.onPerfEntry.bind(this));
        getFID(this.onPerfEntry.bind(this));
        getFCP(this.onPerfEntry.bind(this));
        getLCP(this.onPerfEntry.bind(this));
        getTTFB(this.onPerfEntry.bind(this));
      });
    }

    // Monitor resource loading
    if ('PerformanceObserver' in window) {
      const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (entry.entryType === 'navigation') {
            this.trackEvent('performance', 'navigation', {
              loadTime: entry.loadEventEnd - entry.loadEventStart,
              domContentLoaded: entry.domContentLoadedEventEnd - entry.domContentLoadedEventStart,
              firstByte: entry.responseStart - entry.requestStart
            });
          }
        }
      });
      observer.observe({entryTypes: ['navigation']});
    }
  }

  onPerfEntry(entry) {
    this.trackEvent('performance', 'web_vital', {
      name: entry.name,
      value: entry.value,
      rating: entry.rating
    });
  }

  trackPageView(page, title = null) {
    const event = {
      type: 'page_view',
      page,
      title: title || document.title,
      timestamp: Date.now(),
      sessionId: this.sessionId,
      userAgent: navigator.userAgent,
      referrer: document.referrer,
      url: window.location.href
    };

    this.events.push(event);

    // Send to Google Analytics if available
    if (window.gtag && this.isEnabled) {
      window.gtag('config', process.env.REACT_APP_GA_MEASUREMENT_ID, {
        page_title: title,
        page_location: window.location.href
      });
    }

    console.log('📊 Page view tracked:', event);
  }

  trackEvent(category, action, properties = {}) {
    const event = {
      type: 'event',
      category,
      action,
      properties,
      timestamp: Date.now(),
      sessionId: this.sessionId,
      url: window.location.href
    };

    this.events.push(event);

    // Send to Google Analytics if available
    if (window.gtag && this.isEnabled) {
      window.gtag('event', action, {
        event_category: category,
        event_label: properties.label,
        value: properties.value,
        custom_parameter_1: properties.custom1,
        custom_parameter_2: properties.custom2
      });
    }

    console.log('📊 Event tracked:', event);
  }

  trackContactFormSubmission(formData, success = true) {
    this.trackEvent('contact', 'form_submission', {
      success,
      projectType: formData.projectType,
      budget: formData.budget,
      timeline: formData.timeline,
      hasCompany: !!formData.company,
      hasRole: !!formData.role,
      messageLength: formData.message?.length || 0,
      attachmentCount: formData.attachments?.length || 0
    });
  }

  trackContactFormField(fieldName, action) {
    this.trackEvent('contact', 'form_field_interaction', {
      field: fieldName,
      action, // 'focus', 'blur', 'error', 'valid'
      timestamp: Date.now()
    });
  }

  trackProjectView(projectTitle, projectCategory) {
    this.trackEvent('portfolio', 'project_view', {
      title: projectTitle,
      category: projectCategory,
      section: 'projects'
    });
  }

  trackSkillInteraction(skillName, skillCategory) {
    this.trackEvent('portfolio', 'skill_interaction', {
      skill: skillName,
      category: skillCategory,
      section: 'skills'
    });
  }

  trackDownload(fileName, fileType) {
    this.trackEvent('engagement', 'download', {
      fileName,
      fileType,
      section: window.location.pathname
    });
  }

  trackExternalLink(url, linkText) {
    this.trackEvent('engagement', 'external_link', {
      url,
      linkText,
      section: window.location.pathname
    });
  }

  trackPageLoad() {
    const loadTime = Date.now() - this.startTime;
    this.trackEvent('performance', 'page_load', {
      loadTime,
      page: window.location.pathname
    });
  }

  trackUserEngagement() {
    const timeOnPage = Date.now() - this.startTime;
    const scrollDepth = Math.round((window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100);
    
    this.trackEvent('engagement', 'user_activity', {
      timeOnPage,
      scrollDepth,
      interactions: this.events.filter(e => e.category === 'interaction').length
    });
  }

  trackError(error, errorInfo = {}) {
    this.trackEvent('error', 'javascript_error', {
      message: error.message,
      stack: error.stack,
      url: window.location.href,
      userAgent: navigator.userAgent,
      ...errorInfo
    });

    // Send to Google Analytics as exception
    if (window.gtag && this.isEnabled) {
      window.gtag('event', 'exception', {
        description: error.message,
        fatal: false
      });
    }
  }

  // Get analytics summary for debugging
  getAnalyticsSummary() {
    const timeOnSite = Date.now() - this.startTime;
    const eventsByCategory = this.events.reduce((acc, event) => {
      acc[event.category] = (acc[event.category] || 0) + 1;
      return acc;
    }, {});

    return {
      sessionId: this.sessionId,
      timeOnSite,
      totalEvents: this.events.length,
      eventsByCategory,
      isEnabled: this.isEnabled,
      hasGA4: !!window.gtag
    };
  }

  // Export events for debugging or manual analysis
  exportEvents() {
    return {
      sessionId: this.sessionId,
      startTime: this.startTime,
      events: this.events,
      summary: this.getAnalyticsSummary()
    };
  }
}

// Create singleton instance
export const analyticsService = new AnalyticsService();

// Set up automatic page unload tracking
window.addEventListener('beforeunload', () => {
  analyticsService.trackUserEngagement();
});

// Set up error tracking
window.addEventListener('error', (event) => {
  analyticsService.trackError(event.error, {
    filename: event.filename,
    lineno: event.lineno,
    colno: event.colno
  });
});

// Set up unhandled promise rejection tracking
window.addEventListener('unhandledrejection', (event) => {
  analyticsService.trackError(new Error('Unhandled Promise Rejection'), {
    reason: event.reason
  });
});

export default analyticsService;