import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { Menu, X } from 'lucide-react';

const Layout = ({ children }) => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { name: 'Home', path: '/' },
    { name: 'About', path: '/about' },
    { name: 'Skills', path: '/skills' },
    { name: 'Experience', path: '/experience' },
    { name: 'Projects', path: '/projects' },
    { name: 'Contact', path: '/contact' }
  ];

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleNavigation = (path) => {
    navigate(path);
    setIsMobileMenuOpen(false);
  };

  const isActivePage = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        isScrolled 
          ? 'bg-navy-900/95 backdrop-blur-md shadow-lg border-b border-gold-200/20' 
          : 'bg-navy-900/90 backdrop-blur-sm'
      }`}>
        <div className="max-w-7xl mx-auto px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Company Logo */}
            <div className="flex-shrink-0">
              <button 
                onClick={() => handleNavigation('/')}
                className="flex items-center hover:opacity-80 transition-opacity duration-200"
              >
                <img 
                  src="/images/logo/company-logo.svg" 
                  alt="ARCHSOL IT Solutions - Enterprise Architecture & Digital Transformation"
                  className="h-10 w-auto"
                />
              </button>
            </div>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex space-x-8">
              {navItems.map((item) => (
                <button
                  key={item.name}
                  onClick={() => handleNavigation(item.path)}
                  className={`font-serif font-medium transition-all duration-200 hover:-translate-y-0.5 transform ${
                    isActivePage(item.path)
                      ? 'text-gold-400 border-b-2 border-gold-400'
                      : 'text-slate-200 hover:text-gold-300'
                  }`}
                >
                  {item.name}
                </button>
              ))}
            </nav>

            {/* Mobile Menu Button */}
            <div className="md:hidden">
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="text-slate-200 hover:text-gold-300 transition-colors duration-200"
              >
                {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
            </div>
          </div>

          {/* Mobile Navigation */}
          {isMobileMenuOpen && (
            <div className="md:hidden bg-navy-900/95 backdrop-blur-md border-t border-gold-200/20">
              <nav className="px-4 py-4 space-y-2">
                {navItems.map((item) => (
                  <button
                    key={item.name}
                    onClick={() => handleNavigation(item.path)}
                    className={`block w-full text-left px-3 py-2 rounded-md transition-colors duration-200 font-serif ${
                      isActivePage(item.path)
                        ? 'text-gold-400 bg-gold-400/10'
                        : 'text-slate-200 hover:text-gold-300 hover:bg-slate-800/50'
                    }`}
                  >
                    {item.name}
                  </button>
                ))}
              </nav>
            </div>
          )}
        </div>
      </header>

      {/* Main Content */}
      <main className="pt-16">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-navy-900 text-slate-200">
        <div className="max-w-7xl mx-auto px-6 lg:px-8 py-16">
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {/* About Section */}
            <div className="lg:col-span-2">
              <h3 className="text-2xl font-bold mb-4 text-gold-400 font-serif">Kamal Singh</h3>
              <p className="text-slate-300 leading-relaxed mb-6 font-serif">
                IT Portfolio Architect with 26+ years of expertise in E2E Architecture 
                and Digital Transformation, driving business growth through innovative, 
                cost-effective architectural solutions.
              </p>
            </div>

            {/* Quick Links */}
            <div>
              <h4 className="font-semibold text-gold-400 mb-4 font-serif">Quick Links</h4>
              <ul className="space-y-3">
                {navItems.slice(1).map((item) => (
                  <li key={item.name}>
                    <button
                      onClick={() => handleNavigation(item.path)}
                      className="text-slate-300 hover:text-gold-300 transition-colors duration-200 text-sm font-serif"
                    >
                      {item.name}
                    </button>
                  </li>
                ))}
              </ul>
            </div>

            {/* Contact Info */}
            <div>
              <h4 className="font-semibold text-gold-400 mb-4 font-serif">Contact</h4>
              <div className="space-y-3 text-sm text-slate-300 font-serif">
                <div>chkamalsingh@yahoo.com</div>
                <div>07908 521 588</div>
                <div>Amersham, United Kingdom</div>
              </div>
            </div>
          </div>

          {/* Bottom Bar */}
          <div className="border-t border-slate-700 mt-12 pt-8">
            <div className="flex flex-col md:flex-row justify-between items-center">
              <div className="text-sm text-slate-400 mb-4 md:mb-0 font-serif">
                © 2024 Kamal Singh. All rights reserved.
              </div>
              
              <div className="flex items-center text-sm text-slate-400 font-serif">
                <span>Crafted for architectural excellence</span>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Layout;