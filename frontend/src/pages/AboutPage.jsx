import React, { useEffect, useState } from 'react';
import { CheckCircle, Target, Lightbulb, Zap, Award, Globe } from 'lucide-react';
import Layout from '../components/Layout';
import { portfolioData } from '../mock';

const iconMap = {
  Zap,
  Award,
  Globe
};

const AboutPage = () => {
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  const { about } = portfolioData;

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section */}
        <section className="relative py-32 bg-gradient-to-br from-navy-900 via-charcoal-800 to-navy-900 overflow-hidden">
          <div className="absolute inset-0">
            <img 
              src={about.backgroundImage} 
              alt="Professional Technology Environment"
              className="w-full h-full object-cover opacity-20"
            />
          </div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-8 font-serif">
                {about.title}
              </h1>
              <p className="text-xl text-gold-300 max-w-4xl mx-auto leading-relaxed font-serif">
                Discover the journey of an experienced architecture leader dedicated to 
                transforming enterprises through strategic vision and technical excellence.
              </p>
            </div>
          </div>
        </section>

        {/* Main Content */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              {/* Text Content */}
              <div>
                <div className="space-y-8">
                  <div className="flex items-start space-x-4">
                    <CheckCircle className="text-gold-500 mt-1 flex-shrink-0" size={28} />
                    <div>
                      <h3 className="text-2xl font-semibold text-navy-900 mb-4 font-serif">Experience & Expertise</h3>
                      <p className="text-slate-600 leading-relaxed text-lg font-serif">
                        {about.summary}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <Target className="text-gold-500 mt-1 flex-shrink-0" size={28} />
                    <div>
                      <h3 className="text-2xl font-semibold text-navy-900 mb-4 font-serif">Visionary Approach</h3>
                      <p className="text-slate-600 leading-relaxed text-lg font-serif">
                        {about.vision}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    <Lightbulb className="text-gold-500 mt-1 flex-shrink-0" size={28} />
                    <div>
                      <h3 className="text-2xl font-semibold text-navy-900 mb-4 font-serif">Innovation Focus</h3>
                      <p className="text-slate-600 leading-relaxed text-lg font-serif">
                        {about.passion}
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Visual Element */}
              <div className="relative">
                <img 
                  src={about.backgroundImage} 
                  alt="Technology Innovation Leadership"
                  className="w-full h-96 object-cover rounded-2xl shadow-2xl"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-navy-900/30 to-transparent rounded-2xl"></div>
                
                {/* Floating Achievement Cards */}
                <div className="absolute -bottom-8 -left-8 bg-white rounded-xl shadow-2xl p-6 border-l-4 border-gold-500">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-navy-900 font-serif">26+</div>
                    <div className="text-sm text-slate-600 font-serif">Years of Excellence</div>
                  </div>
                </div>
                
                <div className="absolute -top-8 -right-8 bg-white rounded-xl shadow-2xl p-6 border-l-4 border-gold-500">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-navy-900 font-serif">E2E</div>
                    <div className="text-sm text-slate-600 font-serif">Architecture</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Achievements Section */}
        <section className="py-24 bg-navy-50">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Key Achievements
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Measurable impact across enterprise transformations and strategic initiatives.
              </p>
            </div>

            <div className="grid md:grid-cols-3 gap-8">
              {about.achievements.map((achievement, index) => {
                const IconComponent = iconMap[achievement.icon];
                return (
                  <div 
                    key={index}
                    className="text-center group hover:transform hover:scale-105 transition-all duration-300"
                  >
                    <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 border border-navy-200 group-hover:border-gold-300">
                      <div className="flex items-center justify-center mb-6">
                        <div className="p-4 bg-gold-100 rounded-full group-hover:bg-gold-200 transition-colors duration-300">
                          <IconComponent className="text-gold-600" size={32} />
                        </div>
                      </div>
                      <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">
                        {achievement.number}
                      </div>
                      <div className="text-slate-600 font-serif font-medium">
                        {achievement.label}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Philosophy Section */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="max-w-4xl mx-auto text-center">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-8 font-serif">
                Leadership Philosophy
              </h2>
              <blockquote className="text-2xl text-slate-600 italic leading-relaxed mb-8 font-serif">
                "Architecture is not just about technology—it's about understanding business needs, 
                anticipating future requirements, and creating sustainable solutions that drive 
                measurable business value."
              </blockquote>
              <div className="text-gold-600 font-semibold font-serif">— Kamal Singh</div>
            </div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="py-24 bg-gradient-to-br from-navy-900 to-charcoal-800">
          <div className="max-w-7xl mx-auto px-6 lg:px-8 text-center">
            <h2 className="text-4xl lg:text-5xl font-light text-white mb-8 font-serif">
              Ready to Transform Your Enterprise?
            </h2>
            <p className="text-xl text-slate-300 mb-12 max-w-3xl mx-auto font-serif">
              Let's discuss how strategic architecture and proven leadership can drive 
              your digital transformation initiatives.
            </p>
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <button
                onClick={() => window.location.href = '/contact'}
                className="inline-flex items-center px-8 py-4 bg-gold-500 hover:bg-gold-600 text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
              >
                Start a Conversation
              </button>
              <button
                onClick={() => window.location.href = '/projects'}
                className="inline-flex items-center px-8 py-4 bg-transparent border-2 border-gold-400 text-gold-400 hover:bg-gold-400 hover:text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
              >
                View My Work
              </button>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default AboutPage;