import React from 'react';
import { CheckCircle, Target, Lightbulb } from 'lucide-react';

const About = ({ data }) => {
  return (
    <section id="about" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Text Content */}
          <div>
            <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-8">
              About Me
            </h2>
            
            <div className="space-y-8">
              <div className="flex items-start space-x-4">
                <CheckCircle className="text-indigo-600 mt-1 flex-shrink-0" size={24} />
                <div>
                  <h3 className="text-xl font-semibold text-slate-800 mb-3">Experience & Expertise</h3>
                  <p className="text-slate-600 leading-relaxed">
                    {data.summary}
                  </p>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <Target className="text-indigo-600 mt-1 flex-shrink-0" size={24} />
                <div>
                  <h3 className="text-xl font-semibold text-slate-800 mb-3">Visionary Approach</h3>
                  <p className="text-slate-600 leading-relaxed">
                    {data.vision}
                  </p>
                </div>
              </div>

              <div className="flex items-start space-x-4">
                <Lightbulb className="text-indigo-600 mt-1 flex-shrink-0" size={24} />
                <div>
                  <h3 className="text-xl font-semibold text-slate-800 mb-3">Innovation Focus</h3>
                  <p className="text-slate-600 leading-relaxed">
                    {data.passion}
                  </p>
                </div>
              </div>
            </div>

            {/* Call to Action */}
            <div className="mt-10">
              <button 
                onClick={() => document.querySelector('#contact')?.scrollIntoView({ behavior: 'smooth' })}
                className="inline-flex items-center px-6 py-3 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-medium transition-all duration-300 hover:scale-105"
              >
                Let's Connect
              </button>
            </div>
          </div>

          {/* Visual Element */}
          <div className="relative">
            <img 
              src={data.backgroundImage} 
              alt="Digital Architecture Innovation"
              className="w-full h-96 object-cover rounded-2xl shadow-xl"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-indigo-900/30 to-transparent rounded-2xl"></div>
            
            {/* Floating Stats */}
            <div className="absolute -bottom-6 -left-6 bg-white rounded-xl shadow-lg p-6 border border-slate-200">
              <div className="text-center">
                <div className="text-2xl font-bold text-indigo-600">26+</div>
                <div className="text-sm text-slate-600">Years of Excellence</div>
              </div>
            </div>
            
            <div className="absolute -top-6 -right-6 bg-white rounded-xl shadow-lg p-6 border border-slate-200">
              <div className="text-center">
                <div className="text-2xl font-bold text-indigo-600">E2E</div>
                <div className="text-sm text-slate-600">Architecture</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;