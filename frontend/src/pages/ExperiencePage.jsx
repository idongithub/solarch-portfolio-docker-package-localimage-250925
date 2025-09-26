import React, { useEffect, useState } from 'react';
import { Calendar, Building, CheckCircle, MapPin, TrendingUp } from 'lucide-react';
import Layout from '../components/Layout';
import { portfolioData } from '../mock';

const ExperiencePage = () => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [selectedExperience, setSelectedExperience] = useState(null);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  const { experience } = portfolioData;

  const getTypeColor = (type) => {
    switch (type) {
      case 'current':
        return 'bg-green-100 text-green-700 border-green-300';
      case 'recent':
        return 'bg-gold-100 text-gold-700 border-gold-300';
      default:
        return 'bg-slate-100 text-slate-700 border-slate-300';
    }
  };

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section */}
        <section className="relative py-32 bg-gradient-to-br from-navy-900 via-charcoal-800 to-navy-900 overflow-hidden">
          <div className="absolute inset-0">
            <img 
              src={experience.backgroundImage} 
              alt="Corporate Excellence"
              className="w-full h-full object-cover opacity-20"
            />
          </div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-8 font-serif">
                {experience.title}
              </h1>
              <p className="text-xl text-gold-300 max-w-4xl mx-auto leading-relaxed font-serif">
                {experience.subtitle}
              </p>
            </div>
          </div>
        </section>

        {/* Timeline Section */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="relative">
              {/* Timeline Line */}
              <div className="absolute left-1/2 transform -translate-x-px h-full w-0.5 bg-gold-300 hidden lg:block"></div>

              <div className="space-y-16">
                {experience.timeline.map((exp, index) => (
                  <div 
                    key={exp.id}
                    className={`relative flex items-center ${
                      index % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'
                    } flex-col lg:gap-16 gap-8`}
                  >
                    {/* Timeline Dot */}
                    <div className="absolute left-1/2 transform -translate-x-1/2 w-6 h-6 bg-gold-500 rounded-full border-4 border-white shadow-lg z-10 hidden lg:block"></div>

                    {/* Content Card */}
                    <div className={`lg:w-1/2 w-full ${index % 2 === 0 ? '' : 'lg:text-right'}`}>
                      <div 
                        className={`bg-white rounded-xl p-8 shadow-xl hover:shadow-2xl transition-all duration-300 border-2 cursor-pointer ${
                          selectedExperience === index 
                            ? 'border-gold-400 transform scale-105' 
                            : 'border-navy-200 hover:border-gold-300 hover:-translate-y-1'
                        }`}
                        onClick={() => setSelectedExperience(selectedExperience === index ? null : index)}
                      >
                        {/* Header */}
                        <div className="mb-6">
                          <div className="flex items-center mb-3 justify-between">
                            <div className="flex items-center">
                              <Calendar className="text-gold-500 mr-2" size={18} />
                              <span className={`text-sm font-medium px-3 py-1 rounded-full border font-serif ${getTypeColor(exp.type)}`}>
                                {exp.period}
                              </span>
                            </div>
                            <div className="flex items-center text-slate-500">
                              <MapPin size={16} className="mr-1" />
                              <span className="text-sm font-serif">{exp.location}</span>
                            </div>
                          </div>
                          <h3 className="text-3xl font-bold text-navy-900 mb-2 font-serif">
                            {exp.title}
                          </h3>
                          <div className="flex items-center text-slate-600 mb-4">
                            <Building className="mr-2" size={18} />
                            <span className="font-medium text-lg font-serif">{exp.company}</span>
                          </div>
                          <p className="text-slate-600 leading-relaxed font-serif">
                            {exp.description}
                          </p>
                        </div>

                        {/* Achievements */}
                        <div className="space-y-4 mb-6">
                          <h4 className="font-semibold text-navy-900 mb-3 font-serif">Key Achievements:</h4>
                          {exp.achievements.slice(0, selectedExperience === index ? exp.achievements.length : 2).map((achievement, achievementIndex) => (
                            <div key={achievementIndex} className="flex items-start space-x-3">
                              <CheckCircle className="text-green-500 mt-0.5 flex-shrink-0" size={18} />
                              <span className="text-slate-600 text-sm leading-relaxed font-serif">
                                {achievement}
                              </span>
                            </div>
                          ))}
                          {selectedExperience !== index && exp.achievements.length > 2 && (
                            <div className="text-gold-600 text-sm font-medium font-serif">
                              +{exp.achievements.length - 2} more achievements
                            </div>
                          )}
                        </div>

                        {/* Impact */}
                        {selectedExperience === index && exp.impact && (
                          <div className="mb-6 p-4 bg-gold-50 rounded-lg border border-gold-200">
                            <div className="flex items-center mb-2">
                              <TrendingUp className="text-gold-600 mr-2" size={18} />
                              <h4 className="font-semibold text-gold-800 font-serif">Business Impact:</h4>
                            </div>
                            <p className="text-gold-700 font-serif">{exp.impact}</p>
                          </div>
                        )}

                        {/* Technologies */}
                        <div className="mb-4">
                          <h4 className="font-semibold text-navy-900 mb-3 font-serif">Technologies:</h4>
                          <div className="flex flex-wrap gap-2">
                            {exp.technologies.map((tech, techIndex) => (
                              <span 
                                key={techIndex}
                                className="px-3 py-1 bg-navy-100 text-navy-700 rounded-full text-xs font-medium hover:bg-gold-100 hover:text-gold-700 transition-colors duration-200 font-serif"
                              >
                                {tech}
                              </span>
                            ))}
                          </div>
                        </div>

                        {/* Expand Indicator */}
                        <div className="text-center pt-4 border-t border-slate-200">
                          <span className="text-xs text-slate-500 font-serif">
                            {selectedExperience === index ? 'Click to collapse' : 'Click to expand details'}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Spacer for desktop */}
                    <div className="lg:w-1/2 hidden lg:block"></div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Career Summary */}
        <section className="py-24 bg-navy-50">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Career Highlights
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                A proven track record of delivering enterprise-scale transformations across multiple industries and technology domains.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              <div className="text-center group">
                <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-navy-200 group-hover:border-gold-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">26+</div>
                  <div className="text-slate-600 font-serif">Years of Leadership</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-navy-200 group-hover:border-gold-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">50+</div>
                  <div className="text-slate-600 font-serif">Major Projects</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-navy-200 group-hover:border-gold-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">15+</div>
                  <div className="text-slate-600 font-serif">Industry Sectors</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-navy-200 group-hover:border-gold-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">100+</div>
                  <div className="text-slate-600 font-serif">Team Members Led</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="py-24 bg-gradient-to-br from-navy-900 to-charcoal-800">
          <div className="max-w-7xl mx-auto px-6 lg:px-8 text-center">
            <h2 className="text-4xl lg:text-5xl font-light text-white mb-8 font-serif">
              Ready to Add Value to Your Organization?
            </h2>
            <p className="text-xl text-slate-300 mb-12 max-w-3xl mx-auto font-serif">
              Leverage decades of proven experience in enterprise architecture and digital transformation leadership.
            </p>
            <div className="flex flex-col sm:flex-row gap-6 justify-center">
              <button
                onClick={() => window.location.href = '/contact'}
                className="inline-flex items-center px-8 py-4 bg-gold-500 hover:bg-gold-600 text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
              >
                Discuss Opportunities
              </button>
              <button
                onClick={() => window.location.href = '/projects'}
                className="inline-flex items-center px-8 py-4 bg-transparent border-2 border-gold-400 text-gold-400 hover:bg-gold-400 hover:text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
              >
                View Project Portfolio
              </button>
            </div>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default ExperiencePage;