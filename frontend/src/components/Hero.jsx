import React from 'react';
import { ArrowDown, Award, Globe, Users } from 'lucide-react';

const Hero = ({ data }) => {
  const scrollToAbout = () => {
    document.querySelector('#about')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <section id="hero" className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image with Overlay */}
      <div className="absolute inset-0">
        <img 
          src={data.heroImage} 
          alt="Digital Architecture Background"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-br from-slate-900/90 via-indigo-900/85 to-purple-900/90"></div>
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8 py-20">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Text Content */}
          <div className="text-center lg:text-left">
            <div className="mb-6">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-4 leading-tight">
                {data.name}
              </h1>
              <h2 className="text-2xl lg:text-3xl font-light text-indigo-200 mb-6">
                {data.title}
              </h2>
              <p className="text-xl lg:text-2xl text-slate-300 font-light leading-relaxed">
                {data.tagline}
              </p>
            </div>
            
            <p className="text-lg text-slate-400 mb-8 leading-relaxed max-w-2xl">
              {data.description}
            </p>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-8 mb-8">
              <div className="text-center">
                <div className="flex items-center justify-center mb-2">
                  <Award className="text-indigo-400" size={24} />
                </div>
                <div className="text-2xl font-bold text-white">26+</div>
                <div className="text-sm text-slate-400">Years Experience</div>
              </div>
              <div className="text-center">
                <div className="flex items-center justify-center mb-2">
                  <Globe className="text-indigo-400" size={24} />
                </div>
                <div className="text-2xl font-bold text-white">50+</div>
                <div className="text-sm text-slate-400">Projects Delivered</div>
              </div>
              <div className="text-center">
                <div className="flex items-center justify-center mb-2">
                  <Users className="text-indigo-400" size={24} />
                </div>
                <div className="text-2xl font-bold text-white">10+</div>
                <div className="text-sm text-slate-400">Industry Sectors</div>
              </div>
            </div>

            {/* CTA Button */}
            <button
              onClick={scrollToAbout}
              className="inline-flex items-center px-8 py-3 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-all duration-300 hover:scale-105 hover:shadow-xl"
            >
              Explore My Work
              <ArrowDown className="ml-2" size={20} />
            </button>
          </div>

          {/* Image/Visual Element */}
          <div className="relative lg:block hidden">
            <div className="relative">
              <img 
                src={data.profileImage} 
                alt="Architecture Excellence"
                className="w-full h-96 object-cover rounded-2xl shadow-2xl"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-indigo-900/50 to-transparent rounded-2xl"></div>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll Indicator */}
      <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <ArrowDown className="text-white/60" size={24} />
      </div>
    </section>
  );
};

export default Hero;