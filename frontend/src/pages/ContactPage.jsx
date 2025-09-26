import React, { useState, useEffect } from 'react';
import { Mail, Phone, MapPin, Clock, Award, Linkedin } from 'lucide-react';
import Layout from '../components/Layout';
import SimpleContact from '../components/SimpleContact';
import { portfolioData } from '../mock';

const ContactPage = () => {
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  const { contact } = portfolioData;

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section */}
        <section className="relative py-32 bg-gradient-to-br from-navy-900 via-charcoal-800 to-navy-900 overflow-hidden">
          <div className="absolute inset-0">
            <img 
              src={contact.backgroundImage} 
              alt="Professional Consultation"
              className="w-full h-full object-cover opacity-20"
            />
          </div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-8 font-serif">
                Let's Connect
              </h1>
              <p className="text-xl text-gold-300 max-w-4xl mx-auto leading-relaxed font-serif">
                Ready to discuss your next architecture challenge or digital transformation initiative? 
                I'd love to hear about your project and explore how we can work together.
              </p>
            </div>
          </div>
        </section>

        {/* Main Contact Section */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="grid lg:grid-cols-5 gap-16">
              {/* Contact Information - Left Side */}
              <div className="lg:col-span-2">
                <h2 className="text-3xl font-semibold text-navy-900 mb-8 font-serif">
                  Get in Touch
                </h2>

                <div className="space-y-8">
                  <div className="flex items-start space-x-4">
                    <div className="p-4 bg-gold-100 rounded-xl">
                      <Mail className="text-gold-600" size={28} />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-navy-900 mb-2 font-serif">Email</h3>
                      <a 
                        href={`mailto:${contact.email}`}
                        className="text-gold-600 hover:text-gold-700 transition-colors duration-200 font-serif text-lg"
                      >
                        {contact.email}
                      </a>
                      <p className="text-slate-600 text-sm mt-2 font-serif">
                        Preferred method for detailed discussions
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <div className="p-4 bg-gold-100 rounded-xl">
                      <Phone className="text-gold-600" size={28} />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-navy-900 mb-2 font-serif">Phone</h3>
                      <a 
                        href={`tel:${contact.phone}`}
                        className="text-gold-600 hover:text-gold-700 transition-colors duration-200 font-serif text-lg"
                      >
                        {contact.phone}
                      </a>
                      <p className="text-slate-600 text-sm mt-2 font-serif">
                        {contact.workingHours}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <div className="p-4 bg-gold-100 rounded-xl">
                      <MapPin className="text-gold-600" size={28} />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-navy-900 mb-2 font-serif">Location</h3>
                      <p className="text-slate-600 font-serif text-lg">{contact.location}</p>
                      <p className="text-slate-600 text-sm mt-2 font-serif">
                        Available for on-site and remote engagements
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <div className="p-4 bg-gold-100 rounded-xl">
                      <Linkedin className="text-gold-600" size={28} />
                    </div>
                    <div>
                      <h3 className="text-xl font-semibold text-navy-900 mb-2 font-serif">LinkedIn</h3>
                      <a 
                        href={contact.linkedin}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-gold-600 hover:text-gold-700 transition-colors duration-200 font-serif text-lg"
                      >
                        Connect on LinkedIn
                      </a>
                      <p className="text-slate-600 text-sm mt-2 font-serif">
                        Professional network and updates
                      </p>
                    </div>
                  </div>
                </div>

                {/* Availability Card */}
                <div className="mt-12 p-8 bg-gradient-to-br from-gold-50 to-gold-100 rounded-2xl border border-gold-200">
                  <div className="flex items-center mb-4">
                    <Award className="text-gold-600 mr-3" size={24} />
                    <h3 className="text-xl font-semibold text-navy-900 font-serif">Current Availability</h3>
                  </div>
                  <p className="text-gold-800 mb-4 font-serif">{contact.availability}</p>
                  <div className="flex items-center text-sm text-gold-700">
                    <Clock className="mr-2" size={16} />
                    <span className="font-serif">Response time: {contact.responseTime}</span>
                  </div>
                </div>
              </div>

              {/* Contact Form - Right Side */}
              <div className="lg:col-span-3">
                <SimpleContact />
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default ContactPage;