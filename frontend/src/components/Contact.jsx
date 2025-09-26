import React, { useState } from 'react';
import { Mail, Phone, MapPin, Send, Linkedin, Award, Briefcase, Clock, DollarSign } from 'lucide-react';
import { useToast } from '../hooks/use-toast';
import { contactService } from '../services/contactService';

const Contact = ({ data }) => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    company: '',
    role: '',
    projectType: '',
    budget: '',
    timeline: '',
    message: ''
  });
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { toast } = useToast();

  const projectTypes = [
    'Enterprise Architecture Assessment',
    'Digital Transformation',
    'Cloud Migration Strategy',
    'CIAM/IAM Implementation',
    'API-First Design & Implementation',
    'Microservices Architecture',
    'DevOps & CI/CD Implementation',
    'Security Architecture Review',
    'Architecture Governance Setup',
    'Other - Please specify in message'
  ];

  const budgetRanges = [
    'Under £25k',
    '£25k - £50k',
    '£50k - £100k',
    '£100k - £250k',
    '£250k - £500k',
    '£500k+',
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

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (isSubmitting) return;
    
    setIsSubmitting(true);
    
    try {
      // Validate required fields
      if (!formData.name.trim() || !formData.email.trim() || !formData.message.trim()) {
        toast({
          title: "Validation Error",
          description: "Please fill in all required fields (Name, Email, Message).",
          variant: "destructive",
        });
        return;
      }

      // Submit form via contact service
      const result = await contactService.submitContactForm(formData);
      
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
          message: ''
        });
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
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <section id="contact" className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-6">
            Let's Connect
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Ready to discuss your next architecture challenge or digital transformation initiative? 
            I'd love to hear about your project and explore how we can work together.
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-12">
          {/* Contact Information */}
          <div>
            <h3 className="text-2xl font-semibold text-slate-800 mb-8">
              Get in Touch
            </h3>

            <div className="space-y-6">
              <div className="flex items-center space-x-4">
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

              <div className="flex items-center space-x-4">
                <div className="p-3 bg-indigo-100 rounded-lg">
                  <Phone className="text-indigo-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">Phone</h4>
                  <a 
                    href={`tel:${data.phone}`}
                    className="text-indigo-600 hover:text-indigo-700 transition-colors duration-200"
                  >
                    {data.phone}
                  </a>
                </div>
              </div>

              <div className="flex items-center space-x-4">
                <div className="p-3 bg-indigo-100 rounded-lg">
                  <MapPin className="text-indigo-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">Location</h4>
                  <p className="text-slate-600">{data.location}</p>
                </div>
              </div>

              <div className="flex items-center space-x-4">
                <div className="p-3 bg-indigo-100 rounded-lg">
                  <Linkedin className="text-indigo-600" size={24} />
                </div>
                <div>
                  <h4 className="font-semibold text-slate-800">LinkedIn</h4>
                  <a 
                    href={data.linkedin}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-indigo-600 hover:text-indigo-700 transition-colors duration-200"
                  >
                    Connect on LinkedIn
                  </a>
                </div>
              </div>
            </div>

            {/* Availability */}
            <div className="mt-8 p-6 bg-white rounded-xl border border-slate-200">
              <div className="flex items-center mb-3">
                <Award className="text-green-500 mr-3" size={20} />
                <h4 className="font-semibold text-slate-800">Availability</h4>
              </div>
              <p className="text-slate-600 mb-2">{data.availability}</p>
              <div className="text-sm text-slate-500">
                <p><strong>Working Hours:</strong> {data.workingHours}</p>
                <p><strong>Response Time:</strong> {data.responseTime}</p>
              </div>
            </div>

            {/* Quick Stats */}
            <div className="mt-6 grid grid-cols-3 gap-4">
              <div className="text-center p-4 bg-white rounded-lg border border-slate-200">
                <div className="text-2xl font-bold text-indigo-600">26+</div>
                <div className="text-sm text-slate-600">Years Experience</div>
              </div>
              <div className="text-center p-4 bg-white rounded-lg border border-slate-200">
                <div className="text-2xl font-bold text-indigo-600">50+</div>
                <div className="text-sm text-slate-600">Projects Delivered</div>
              </div>
              <div className="text-center p-4 bg-white rounded-lg border border-slate-200">
                <div className="text-2xl font-bold text-indigo-600">10+</div>
                <div className="text-sm text-slate-600">Industry Sectors</div>
              </div>
            </div>
          </div>

          {/* Enhanced Contact Form */}
          <div>
            <div className="bg-white rounded-xl p-8 shadow-lg border border-slate-200">
              <h3 className="text-2xl font-semibold text-slate-800 mb-6">
                Send a Message
              </h3>
              <p className="text-slate-600 mb-6 text-sm">
                Complete the form below for a detailed project discussion. All fields marked with * are required.
              </p>

              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Name and Email Row */}
                <div className="grid md:grid-cols-2 gap-4">
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
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                      placeholder="Your full name"
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
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                      placeholder="your.email@company.com"
                    />
                  </div>
                </div>

                {/* Company and Role Row */}
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      Company
                    </label>
                    <input
                      type="text"
                      name="company"
                      value={formData.company}
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                      placeholder="Your company name"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      Your Role
                    </label>
                    <input
                      type="text"
                      name="role"
                      value={formData.role}
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                      placeholder="e.g., CTO, IT Director"
                    />
                  </div>
                </div>

                {/* Project Type */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    <Briefcase className="inline w-4 h-4 mr-1" />
                    Project Type
                  </label>
                  <select
                    name="projectType"
                    value={formData.projectType}
                    onChange={handleChange}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                  >
                    <option value="">Select project type...</option>
                    {projectTypes.map(type => (
                      <option key={type} value={type}>{type}</option>
                    ))}
                  </select>
                </div>

                {/* Budget and Timeline Row */}
                <div className="grid md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      <DollarSign className="inline w-4 h-4 mr-1" />
                      Budget Range
                    </label>
                    <select
                      name="budget"
                      value={formData.budget}
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                    >
                      <option value="">Select budget range...</option>
                      {budgetRanges.map(budget => (
                        <option key={budget} value={budget}>{budget}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-2">
                      <Clock className="inline w-4 h-4 mr-1" />
                      Timeline
                    </label>
                    <select
                      name="timeline"
                      value={formData.timeline}
                      onChange={handleChange}
                      className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200"
                    >
                      <option value="">Select timeline...</option>
                      {timelineOptions.map(timeline => (
                        <option key={timeline} value={timeline}>{timeline}</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Message */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-2">
                    Project Details *
                  </label>
                  <textarea
                    name="message"
                    value={formData.message}
                    onChange={handleChange}
                    required
                    rows={5}
                    className="w-full px-4 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all duration-200 resize-none"
                    placeholder="Please describe your project, challenges, and specific requirements. Include any technical constraints, current architecture, and expected outcomes..."
                  />
                  <div className="text-xs text-slate-500 mt-1">
                    {formData.message.length}/2000 characters
                  </div>
                </div>

                {/* Submit Button */}
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className={`w-full flex items-center justify-center px-6 py-3 rounded-lg font-medium transition-all duration-300 ${
                    isSubmitting
                      ? 'bg-slate-400 cursor-not-allowed'
                      : 'bg-indigo-600 hover:bg-indigo-700 hover:scale-105'
                  } text-white`}
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Sending Message...
                    </>
                  ) : (
                    <>
                      <Send className="mr-2" size={16} />
                      Send Message
                    </>
                  )}
                </button>

                <p className="text-xs text-slate-500 text-center">
                  By submitting this form, you'll receive an automatic confirmation email. 
                  I typically respond to inquiries within 1-2 business days.
                </p>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Contact;