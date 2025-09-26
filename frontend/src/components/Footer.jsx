import React from 'react';
import { Award, Mail, Phone, MapPin, Heart } from 'lucide-react';
import { portfolioData } from '../mock';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  const quickLinks = [
    { name: 'About', href: '#about' },
    { name: 'Skills', href: '#skills' },
    { name: 'Experience', href: '#experience' },
    { name: 'Projects', href: '#projects' }
  ];

  const scrollToSection = (href) => {
    document.querySelector(href)?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <footer className="bg-slate-800 text-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-8 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* About Section */}
          <div className="lg:col-span-2">
            <h3 className="text-2xl font-bold mb-4">Kamal Singh</h3>
            <p className="text-slate-300 leading-relaxed mb-6">
              IT Portfolio Architect with 26+ years of expertise in E2E Architecture 
              and Digital Transformation, driving business growth through innovative, 
              cost-effective architectural solutions.
            </p>
            
            {/* Certifications */}
            <div className="space-y-2">
              <h4 className="font-semibold text-slate-200 mb-3">Key Certifications</h4>
              {portfolioData.certifications.slice(0, 3).map((cert, index) => (
                <div key={index} className="flex items-center text-sm text-slate-300">
                  <Award className="text-indigo-400 mr-2" size={14} />
                  <span>{cert}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="font-semibold text-slate-200 mb-4">Quick Links</h4>
            <ul className="space-y-3">
              {quickLinks.map((link) => (
                <li key={link.name}>
                  <button
                    onClick={() => scrollToSection(link.href)}
                    className="text-slate-300 hover:text-indigo-400 transition-colors duration-200 text-sm"
                  >
                    {link.name}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="font-semibold text-slate-200 mb-4">Contact</h4>
            <div className="space-y-3">
              <div className="flex items-center text-sm text-slate-300">
                <Mail className="text-indigo-400 mr-2" size={14} />
                <a 
                  href={`mailto:${portfolioData.contact.email}`}
                  className="hover:text-indigo-400 transition-colors duration-200"
                >
                  {portfolioData.contact.email}
                </a>
              </div>
              
              <div className="flex items-center text-sm text-slate-300">
                <Phone className="text-indigo-400 mr-2" size={14} />
                <a 
                  href={`tel:${portfolioData.contact.phone}`}
                  className="hover:text-indigo-400 transition-colors duration-200"
                >
                  {portfolioData.contact.phone}
                </a>
              </div>
              
              <div className="flex items-start text-sm text-slate-300">
                <MapPin className="text-indigo-400 mr-2 mt-0.5" size={14} />
                <span>United Kingdom</span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-slate-700 mt-12 pt-8">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="text-sm text-slate-400 mb-4 md:mb-0">
              © {currentYear} Kamal Singh. All rights reserved.
            </div>
            
            <div className="flex items-center text-sm text-slate-400">
              <span>Built with</span>
              <Heart className="text-red-400 mx-1" size={14} fill="currentColor" />
              <span>for architectural excellence</span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;