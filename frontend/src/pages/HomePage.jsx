import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Play, Award, Briefcase, Building2 } from 'lucide-react';
import Layout from '../components/Layout';
import { portfolioData } from '../mock';

const iconMap = {
  Award,
  Briefcase,
  Building2
};

const HomePage = () => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [isVideoPlaying, setIsVideoPlaying] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  const { hero } = portfolioData;

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section with Video/Motion Background */}
        <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
          {/* Animated Background */}
          <div className="absolute inset-0">
            <img 
              src={hero.heroVideo} 
              alt="Digital Technology Innovation"
              className="w-full h-full object-cover transform scale-105 animate-pulse"
            />
            <div className="absolute inset-0 bg-gradient-to-br from-navy-900/90 via-charcoal-800/85 to-navy-900/95"></div>
            
            {/* Animated Overlay Elements */}
            <div className="absolute inset-0">
              <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-gold-400 rounded-full animate-ping"></div>
              <div className="absolute top-3/4 right-1/4 w-1 h-1 bg-gold-300 rounded-full animate-pulse delay-1000"></div>
              <div className="absolute bottom-1/4 left-1/3 w-1.5 h-1.5 bg-gold-500 rounded-full animate-ping delay-500"></div>
            </div>
          </div>

          {/* Content */}
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8 py-20">
            <div className="text-center">
              
              {/* Main Content */}
              <div className="mb-8">
                <h1 className="text-6xl lg:text-8xl font-light text-white mb-6 leading-tight font-serif animate-fade-in-up">
                  {hero.name}
                </h1>
                <h2 className="text-3xl lg:text-4xl font-light text-gold-400 mb-8 font-serif animate-fade-in-up delay-200">
                  {hero.title}
                </h2>
                <p className="text-2xl lg:text-3xl text-slate-300 font-light leading-relaxed mb-6 font-serif animate-fade-in-up delay-400">
                  {hero.tagline}
                </p>
              </div>
              
              <p className="text-xl text-slate-400 mb-12 leading-relaxed max-w-4xl mx-auto font-serif animate-fade-in-up delay-600">
                {hero.description}
              </p>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-8 mb-12 max-w-3xl mx-auto animate-fade-in-up delay-800">
                {hero.stats.map((stat, index) => {
                  const IconComponent = iconMap[stat.icon];
                  return (
                    <div key={index} className="text-center group">
                      <div className="flex items-center justify-center mb-3">
                        <div className="p-3 bg-gold-400/20 rounded-full group-hover:bg-gold-400/30 transition-colors duration-300">
                          <IconComponent className="text-gold-400" size={28} />
                        </div>
                      </div>
                      <div className="text-3xl font-bold text-white mb-2 font-serif">{stat.number}</div>
                      <div className="text-sm text-slate-400 font-serif">{stat.label}</div>
                    </div>
                  );
                })}
              </div>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row gap-6 justify-center items-center animate-fade-in-up delay-1000">
                <button
                  onClick={() => navigate('/about')}
                  className="group inline-flex items-center px-8 py-4 bg-gold-500 hover:bg-gold-600 text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 hover:shadow-2xl font-serif"
                >
                  Explore My Journey
                  <ArrowRight className="ml-3 group-hover:translate-x-1 transition-transform duration-300" size={20} />
                </button>
                
                <button
                  onClick={() => navigate('/projects')}
                  className="group inline-flex items-center px-8 py-4 bg-transparent border-2 border-gold-400 text-gold-400 hover:bg-gold-400 hover:text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
                >
                  <Play className="mr-3 group-hover:scale-110 transition-transform duration-300" size={20} />
                  View Projects
                </button>
              </div>
            </div>
          </div>

          {/* Scroll Indicator */}
          <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
            <div className="w-6 h-10 border-2 border-gold-400 rounded-full flex justify-center">
              <div className="w-1 h-3 bg-gold-400 rounded-full mt-2 animate-pulse"></div>
            </div>
          </div>
        </section>

        {/* Quick Overview Section */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Architectural Excellence Delivered
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Transforming enterprise landscapes through strategic architecture, innovative solutions, 
                and proven leadership across complex digital transformation initiatives.
              </p>
            </div>

            <div className="grid md:grid-cols-3 gap-8">
              <div className="text-center group hover:transform hover:scale-105 transition-all duration-300">
                <div className="p-6 bg-navy-50 rounded-xl border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-gold-500 mb-4">
                    <Building2 size={48} className="mx-auto" />
                  </div>
                  <h3 className="text-xl font-semibold text-navy-900 mb-3 font-serif">Enterprise Architecture</h3>
                  <p className="text-slate-600 leading-relaxed font-serif">
                    Strategic design and governance of complex enterprise systems with focus on scalability, 
                    security, and business alignment.
                  </p>
                </div>
              </div>

              <div className="text-center group hover:transform hover:scale-105 transition-all duration-300">
                <div className="p-6 bg-navy-50 rounded-xl border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-gold-500 mb-4">
                    <Award size={48} className="mx-auto" />
                  </div>
                  <h3 className="text-xl font-semibold text-navy-900 mb-3 font-serif">Digital Transformation</h3>
                  <p className="text-slate-600 leading-relaxed font-serif">
                    Leading organizations through comprehensive digital modernization initiatives 
                    with measurable business outcomes.
                  </p>
                </div>
              </div>

              <div className="text-center group hover:transform hover:scale-105 transition-all duration-300">
                <div className="p-6 bg-navy-50 rounded-xl border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-gold-500 mb-4">
                    <Briefcase size={48} className="mx-auto" />
                  </div>
                  <h3 className="text-xl font-semibold text-navy-900 mb-3 font-serif">Strategic Leadership</h3>
                  <p className="text-slate-600 leading-relaxed font-serif">
                    Proven track record of leading cross-functional teams and stakeholders 
                    through complex technology transformations.
                  </p>
                </div>
              </div>
            </div>

            <div className="text-center mt-16">
              <button
                onClick={() => navigate('/contact')}
                className="inline-flex items-center px-8 py-3 bg-navy-900 hover:bg-navy-800 text-white rounded-lg font-medium transition-all duration-300 hover:scale-105 font-serif"
              >
                Start a Conversation
                <ArrowRight className="ml-2 group-hover:translate-x-1 transition-transform duration-300" size={20} />
              </button>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default HomePage;