import React from 'react';
import { Calendar, Building, CheckCircle } from 'lucide-react';

const Experience = ({ data }) => {
  return (
    <section id="experience" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-6">
            Professional Experience
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Leading digital transformation and architecture initiatives across 
            enterprise organizations for over two decades.
          </p>
        </div>

        <div className="relative">
          {/* Timeline Line */}
          <div className="absolute left-1/2 transform -translate-x-px h-full w-0.5 bg-indigo-200 hidden lg:block"></div>

          <div className="space-y-12">
            {data.map((experience, index) => (
              <div 
                key={experience.id}
                className={`relative flex items-center ${
                  index % 2 === 0 ? 'lg:flex-row' : 'lg:flex-row-reverse'
                } flex-col lg:gap-16 gap-8`}
              >
                {/* Timeline Dot */}
                <div className="absolute left-1/2 transform -translate-x-1/2 w-4 h-4 bg-indigo-600 rounded-full border-4 border-white shadow-lg z-10 hidden lg:block"></div>

                {/* Content Card */}
                <div className={`lg:w-1/2 w-full ${index % 2 === 0 ? '' : 'lg:text-right'}`}>
                  <div className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 group hover:-translate-y-1">
                    {/* Header */}
                    <div className="mb-6">
                      <div className="flex items-center mb-2">
                        <Calendar className="text-indigo-600 mr-2" size={16} />
                        <span className={`text-sm font-medium px-3 py-1 rounded-full ${
                          experience.type === 'current' 
                            ? 'bg-green-100 text-green-700' 
                            : 'bg-indigo-100 text-indigo-700'
                        }`}>
                          {experience.period}
                        </span>
                      </div>
                      <h3 className="text-2xl font-bold text-slate-800 mb-2">
                        {experience.title}
                      </h3>
                      <div className="flex items-center text-slate-600">
                        <Building className="mr-2" size={16} />
                        <span className="font-medium">{experience.company}</span>
                      </div>
                    </div>

                    {/* Achievements */}
                    <div className="space-y-4">
                      <h4 className="font-semibold text-slate-800 mb-3">Key Achievements:</h4>
                      {experience.achievements.map((achievement, achievementIndex) => (
                        <div key={achievementIndex} className="flex items-start space-x-3">
                          <CheckCircle className="text-green-500 mt-0.5 flex-shrink-0" size={16} />
                          <span className="text-slate-600 text-sm leading-relaxed">
                            {achievement}
                          </span>
                        </div>
                      ))}
                    </div>

                    {/* Technologies */}
                    <div className="mt-6">
                      <h4 className="font-semibold text-slate-800 mb-3">Technologies:</h4>
                      <div className="flex flex-wrap gap-2">
                        {experience.technologies.map((tech, techIndex) => (
                          <span 
                            key={techIndex}
                            className="px-3 py-1 bg-slate-100 text-slate-700 rounded-full text-xs font-medium hover:bg-indigo-100 hover:text-indigo-700 transition-colors duration-200"
                          >
                            {tech}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Spacer for desktop */}
                <div className="lg:w-1/2 hidden lg:block"></div>
              </div>
            ))}
          </div>
        </div>

        {/* View More Button */}
        <div className="text-center mt-12">
          <button 
            onClick={() => document.querySelector('#projects')?.scrollIntoView({ behavior: 'smooth' })}
            className="inline-flex items-center px-8 py-3 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-all duration-300 hover:scale-105"
          >
            View Projects
          </button>
        </div>
      </div>
    </section>
  );
};

export default Experience;