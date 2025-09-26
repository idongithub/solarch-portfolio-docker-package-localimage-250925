import React, { useState, useEffect, useCallback } from 'react';
import { Mail, Phone, MapPin, Send, Linkedin, Award, Briefcase, Clock, DollarSign, CheckCircle, XCircle, AlertCircle, Upload, Download } from 'lucide-react';
import { useToast } from '../hooks/use-toast';
import { contactService } from '../services/contactService';

const ContactEnhanced = ({ data }) => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    company: '',
    role: '',
    projectType: '',
    budget: '',
    timeline: '',
    message: '',
    attachments: []
  });
  
  const [validationErrors, setValidationErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitProgress, setSubmitProgress] = useState(0);
  const [fieldTouched, setFieldTouched] = useState({});
  const { toast } = useToast();

  const projectTypes = [
    'Enterprise Architecture Assessment',
    'Digital Transformation Strategy',
    'Cloud Migration & Modernization',
    'CIAM/IAM Implementation',
    'API-First Design & Implementation',
    'Microservices Architecture',
    'DevOps & CI/CD Implementation',
    'Security Architecture Review',
    'Architecture Governance Setup',
    'Gen AI & Agentic AI Integration',
    'Data Architecture & Analytics',
    'Other - Please specify in message'
  ];

  const budgetRanges = [
    'Under £25k',
    '£25k - £50k',
    '£50k - £100k',
    '£100k - £250k',
    '£250k - £500k',
    '£500k - £1M',
    '£1M+',
    'To be discussed'
  ];

  const timelineOptions = [
    'Immediate (within 1 month)',
    '1-3 months',
    '3-6 months',
    '6-12 months',
    '12+ months',
    'To be discussed'
  ];

  // Real-time validation
  const validateField = useCallback((name, value) => {
    const errors = {};

    switch (name) {
      case 'name':
        if (!value.trim()) {
          errors.name = 'Name is required';
        } else if (value.trim().length < 2) {
          errors.name = 'Name must be at least 2 characters';
        } else if (value.trim().length > 100) {
          errors.name = 'Name must be less than 100 characters';
        }
        break;

      case 'email':
        if (!value.trim()) {
          errors.email = 'Email is required';
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          errors.email = 'Please enter a valid email address';
        }
        break;

      case 'message':
        if (!value.trim()) {
          errors.message = 'Message is required';
        } else if (value.trim().length < 10) {
          errors.message = 'Message must be at least 10 characters';
        } else if (value.trim().length > 2000) {
          errors.message = 'Message must be less than 2000 characters';
        }
        break;

      case 'company':
        if (value && value.length > 100) {
          errors.company = 'Company name must be less than 100 characters';
        }
        break;

      case 'role':
        if (value && value.length > 100) {
          errors.role = 'Role must be less than 100 characters';
        }
        break;

      default:
        break;
    }

    return errors;
  }, []);

  // Validate form data in real-time
  useEffect(() => {
    const errors = {};
    Object.keys(formData).forEach(field => {
      if (fieldTouched[field]) {
        const fieldErrors = validateField(field, formData[field]);
        Object.assign(errors, fieldErrors);
      }
    });
    setValidationErrors(errors);
  }, [formData, fieldTouched, validateField]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (isSubmitting) return;
    
    // Mark all fields as touched for validation
    const allFieldsTouched = Object.keys(formData).reduce((acc, field) => {
      acc[field] = true;
      return acc;
    }, {});
    setFieldTouched(allFieldsTouched);

    // Validate all fields
    const allErrors = {};
    Object.keys(formData).forEach(field => {
      const fieldErrors = validateField(field, formData[field]);
      Object.assign(allErrors, fieldErrors);
    });

    if (Object.keys(allErrors).length > 0) {
      setValidationErrors(allErrors);
      toast({
        title: "Validation Error",
        description: "Please fix the errors in the form before submitting.",
        variant: "destructive",
      });
      return;
    }
    
    setIsSubmitting(true);
    setSubmitProgress(0);
    
    try {
      // Simulate progress for better UX
      const progressInterval = setInterval(() => {
        setSubmitProgress(prev => Math.min(prev + 10, 90));
      }, 100);

      // Submit form via contact service
      const result = await contactService.submitContactForm(formData);
      
      clearInterval(progressInterval);
      setSubmitProgress(100);
      
      if (result.success) {
        toast({
          title: "Message Sent Successfully! ✅",
          description: "Thank you for your inquiry. You'll receive a confirmation email shortly, and I'll respond within 1-2 business days.",
        });
        
        // Reset form
        setFormData({
          name: '',
          email: '',
          company: '',
          role: '',
          projectType: '',
          budget: '',
          timeline: '',
          message: '',
          attachments: []
        });
        setFieldTouched({});
        setValidationErrors({});
      } else {
        toast({
          title: "Failed to Send Message",
          description: result.error || "Please try again or contact me directly via email.",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error('Form submission error:', error);
      toast({
        title: "Unexpected Error",
        description: "An unexpected error occurred. Please try again or contact me directly.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
      setSubmitProgress(0);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Mark field as touched
    setFieldTouched(prev => ({
      ...prev,
      [name]: true
    }));
  };

  const handleFileUpload = (e) => {
    const files = Array.from(e.target.files);
    const maxSize = 5 * 1024 * 1024; // 5MB
    const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    
    const validFiles = files.filter(file => {
      if (file.size > maxSize) {
        toast({
          title: "File Too Large",
          description: `${file.name} is larger than 5MB. Please choose a smaller file.`,
          variant: "destructive",
        });
        return false;
      }
      
      if (!allowedTypes.includes(file.type)) {
        toast({
          title: "Invalid File Type",
          description: `${file.name} is not a supported file type. Please upload PDF or Word documents only.`,
          variant: "destructive",
        });
        return false;
      }
      
      return true;
    });

    setFormData(prev => ({
      ...prev,
      attachments: [...prev.attachments, ...validFiles]
    }));
  };

  const removeAttachment = (index) => {
    setFormData(prev => ({
      ...prev,
      attachments: prev.attachments.filter((_, i) => i !== index)
    }));
  };

  const getFieldValidationIcon = (fieldName) => {
    if (!fieldTouched[fieldName]) return null;
    
    if (validationErrors[fieldName]) {
      return <XCircle className="text-red-500" size={20} />;
    } else if (formData[fieldName]) {
      return <CheckCircle className="text-green-500" size={20} />;
    }
    
    return null;
  };

  const getFieldBorderClass = (fieldName) => {
    if (!fieldTouched[fieldName]) return 'border-slate-300';
    
    if (validationErrors[fieldName]) {
      return 'border-red-500 focus:border-red-500';
    } else if (formData[fieldName]) {
      return 'border-green-500 focus:border-green-500';
    }
    
    return 'border-slate-300';
  };

  return (
    <section id="contact" className="py-24 bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-6">
            Let's Connect & Collaborate
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Ready to discuss your next architecture challenge or digital transformation initiative? 
            I'd love to hear about your project and explore how we can work together to achieve your goals.
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-12">
          {/* Contact Information */}
          <div className="bg-white rounded-2xl p-8 shadow-lg">
            <h3 className="text-2xl font-semibold text-slate-800 mb-8">
              Get in Touch
            </h3>

            <div className="space-y-6">
              <div className="flex items-center space-x-4 p-4 bg-slate-50 rounded-lg hover:bg-slate-100 transition-colors">
                <div className="p-3 bg-indigo-100 rounded-lg">
                  <Mail className="text-indigo-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">Email</h4>
                  <a 
                    href={`mailto:${data.email}`}
                    className="text-indigo-600 hover:text-indigo-700 transition-colors duration-200"
                  >
                    {data.email}
                  </a>
                </div>
              </div>

              <div className="flex items-center space-x-4 p-4 bg-slate-50 rounded-lg hover:bg-slate-100 transition-colors">
                <div className="p-3 bg-green-100 rounded-lg">
                  <Linkedin className="text-green-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">LinkedIn</h4>
                  <a 
                    href={data.linkedin}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-green-600 hover:text-green-700 transition-colors duration-200"
                  >
                    Connect on LinkedIn
                  </a>
                </div>
              </div>

              <div className="flex items-center space-x-4 p-4 bg-slate-50 rounded-lg">
                <div className="p-3 bg-blue-100 rounded-lg">
                  <MapPin className="text-blue-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">Location</h4>
                  <p className="text-slate-600">{data.location}</p>
                </div>
              </div>
            </div>

            {/* Response Time Info */}
            <div className="mt-8 p-6 bg-indigo-50 rounded-lg border border-indigo-200">
              <div className="flex items-center space-x-3 mb-4">
                <Clock className="text-indigo-600" size={24} />
                <h4 className="font-semibold text-indigo-800">Response Time</h4>
              </div>
              <p className="text-indigo-700">
                I typically respond to inquiries within <strong>1-2 business days</strong>. 
                For urgent matters, please mention it in your message.
              </p>
            </div>

            {/* Expertise Areas */}
            <div className="mt-8">
              <h4 className="font-semibold text-slate-800 mb-4 flex items-center">
                <Award className="mr-2 text-indigo-600" size={20} />
                Key Expertise Areas
              </h4>
              <div className="flex flex-wrap gap-2">
                {['Enterprise Architecture', 'Digital Transformation', 'Cloud Strategy', 'Gen AI Integration', 'Security Architecture'].map((skill) => (
                  <span key={skill} className="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm font-medium">
                    {skill}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Enhanced Contact Form */}
          <div className="bg-white rounded-2xl p-8 shadow-lg">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid md:grid-cols-2 gap-6">
                {/* Name Field */}
                <div>
                  <label htmlFor="name" className="block text-sm font-semibold text-slate-700 mb-2">
                    Full Name *
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      id="name"
                      name="name"
                      value={formData.name}
                      onChange={handleChange}
                      className={`w-full px-4 py-3 border ${getFieldBorderClass('name')} rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors pr-12`}
                      placeholder="Enter your full name"
                    />
                    <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                      {getFieldValidationIcon('name')}
                    </div>
                  </div>
                  {validationErrors.name && (
                    <p className="text-red-500 text-sm mt-1 flex items-center">
                      <AlertCircle size={16} className="mr-1" />
                      {validationErrors.name}
                    </p>
                  )}
                </div>

                {/* Email Field */}
                <div>
                  <label htmlFor="email" className="block text-sm font-semibold text-slate-700 mb-2">
                    Email Address *
                  </label>
                  <div className="relative">
                    <input
                      type="email"
                      id="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      className={`w-full px-4 py-3 border ${getFieldBorderClass('email')} rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors pr-12`}
                      placeholder="your.email@company.com"
                    />
                    <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                      {getFieldValidationIcon('email')}
                    </div>
                  </div>
                  {validationErrors.email && (
                    <p className="text-red-500 text-sm mt-1 flex items-center">
                      <AlertCircle size={16} className="mr-1" />
                      {validationErrors.email}
                    </p>
                  )}
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-6">
                {/* Company Field */}
                <div>
                  <label htmlFor="company" className="block text-sm font-semibold text-slate-700 mb-2">
                    Company/Organization
                  </label>
                  <div className="relative">
                    <input
                      type="text"
                      id="company"
                      name="company"
                      value={formData.company}
                      onChange={handleChange}
                      className={`w-full px-4 py-3 border ${getFieldBorderClass('company')} rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors pr-12`}
                      placeholder="Your company name"
                    />
                    <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                      {getFieldValidationIcon('company')}
                    </div>
                  </div>
                  {validationErrors.company && (
                    <p className="text-red-500 text-sm mt-1 flex items-center">
                      <AlertCircle size={16} className="mr-1" />
                      {validationErrors.company}
                    </p>
                  )}
                </div>

                {/* Role Field */}
                <div>
                  <label htmlFor="role" className="block text-sm font-semibold text-slate-700 mb-2">
                    Your Role
                  </label>
                  <div className="relative">
                    <input
                      type="text" 
                      id="role"
                      name="role"
                      value={formData.role}
                      onChange={handleChange}
                      className={`w-full px-4 py-3 border ${getFieldBorderClass('role')} rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors pr-12`}
                      placeholder="e.g., CTO, IT Director, Project Manager"
                    />
                    <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                      {getFieldValidationIcon('role')}
                    </div>
                  </div>
                  {validationErrors.role && (
                    <p className="text-red-500 text-sm mt-1 flex items-center">
                      <AlertCircle size={16} className="mr-1" />
                      {validationErrors.role}
                    </p>
                  )}
                </div>
              </div>

              {/* Project Type */}
              <div>
                <label htmlFor="projectType" className="block text-sm font-semibold text-slate-700 mb-2 flex items-center">
                  <Briefcase className="mr-2" size={16} />
                  Project Type
                </label>
                <select
                  id="projectType"
                  name="projectType"
                  value={formData.projectType}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                >
                  <option value="">Select project type...</option>
                  {projectTypes.map((type) => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
              </div>

              <div className="grid md:grid-cols-2 gap-6">
                {/* Budget */}
                <div>
                  <label htmlFor="budget" className="block text-sm font-semibold text-slate-700 mb-2 flex items-center">
                    <DollarSign className="mr-2" size={16} />
                    Project Budget
                  </label>
                  <select
                    id="budget"
                    name="budget"
                    value={formData.budget}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                  >
                    <option value="">Select budget range...</option>
                    {budgetRanges.map((range) => (
                      <option key={range} value={range}>{range}</option>
                    ))}
                  </select>
                </div>

                {/* Timeline */}
                <div>
                  <label htmlFor="timeline" className="block text-sm font-semibold text-slate-700 mb-2 flex items-center">
                    <Clock className="mr-2" size={16} />
                    Timeline
                  </label>
                  <select
                    id="timeline"
                    name="timeline"
                    value={formData.timeline}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors"
                  >
                    <option value="">Select timeline...</option>
                    {timelineOptions.map((option) => (
                      <option key={option} value={option}>{option}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* File Upload */}
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center">
                  <Upload className="mr-2" size={16} />
                  Attachments (Optional)
                </label>
                <div className="border-2 border-dashed border-slate-300 rounded-lg p-6 text-center hover:border-indigo-400 transition-colors">
                  <input
                    type="file"
                    multiple
                    accept=".pdf,.doc,.docx"
                    onChange={handleFileUpload}
                    className="hidden"
                    id="file-upload"
                  />
                  <label htmlFor="file-upload" className="cursor-pointer">
                    <Upload className="mx-auto mb-2 text-slate-400" size={32} />
                    <p className="text-slate-600">Click to upload documents</p>
                    <p className="text-sm text-slate-500 mt-1">PDF, DOC, DOCX up to 5MB each</p>
                  </label>
                </div>
                
                {/* Display uploaded files */}
                {formData.attachments.length > 0 && (
                  <div className="mt-4 space-y-2">
                    {formData.attachments.map((file, index) => (
                      <div key={index} className="flex items-center justify-between bg-slate-50 p-3 rounded-lg">
                        <span className="text-sm text-slate-700">{file.name}</span>
                        <button
                          type="button"
                          onClick={() => removeAttachment(index)}
                          className="text-red-500 hover:text-red-700"
                        >
                          <XCircle size={16} />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Message */}
              <div>
                <label htmlFor="message" className="block text-sm font-semibold text-slate-700 mb-2">
                  Project Details & Message *
                </label>
                <div className="relative">
                  <textarea
                    id="message"
                    name="message"
                    value={formData.message}
                    onChange={handleChange}
                    rows={6}
                    className={`w-full px-4 py-3 border ${getFieldBorderClass('message')} rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-colors resize-vertical`}
                    placeholder="Please describe your project requirements, challenges you're facing, and how I can help you achieve your goals..."
                  />
                  <div className="absolute right-3 top-3">
                    {getFieldValidationIcon('message')}
                  </div>
                </div>
                <div className="flex justify-between items-center mt-2">
                  {validationErrors.message && (
                    <p className="text-red-500 text-sm flex items-center">
                      <AlertCircle size={16} className="mr-1" />
                      {validationErrors.message}
                    </p>
                  )}
                  <p className="text-sm text-slate-500 ml-auto">
                    {formData.message.length}/2000 characters
                  </p>
                </div>
              </div>

              {/* Submit Button */}
              <div>
                <button
                  type="submit"
                  disabled={isSubmitting || Object.keys(validationErrors).length > 0}
                  className="w-full bg-indigo-600 text-white py-4 px-6 rounded-lg font-semibold hover:bg-indigo-700 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center space-x-2"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                      <span>Sending Message...</span>
                    </>
                  ) : (
                    <>
                      <Send size={20} />
                      <span>Send Message</span>
                    </>
                  )}
                </button>
                
                {/* Progress Bar */}
                {isSubmitting && (
                  <div className="mt-3">
                    <div className="bg-slate-200 rounded-full h-2">
                      <div 
                        className="bg-indigo-600 h-2 rounded-full transition-all duration-300"
                        style={{ width: `${submitProgress}%` }}
                      ></div>
                    </div>
                    <p className="text-sm text-slate-600 mt-1 text-center">
                      {submitProgress < 90 ? 'Validating form...' : submitProgress < 100 ? 'Sending email...' : 'Complete!'}
                    </p>
                  </div>
                )}
              </div>

              {/* Privacy Notice */}
              <div className="text-sm text-slate-500 bg-slate-50 p-4 rounded-lg">
                <p className="flex items-start">
                  <AlertCircle size={16} className="mr-2 mt-0.5 flex-shrink-0" />
                  Your information is kept confidential and will only be used to respond to your inquiry. 
                  I do not share contact details with third parties.
                </p>
              </div>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
};

export default ContactEnhanced;