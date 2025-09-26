import React from 'react';
import { Building2, Cloud, Network, Shield, Users, Briefcase, Brain } from 'lucide-react';

const iconMap = {
  Building2,
  Cloud,  
  Network,
  Shield,
  Users,
  Briefcase,
  Brain
};

const Skills = ({ data }) => {
  return (
    <section id="skills" className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-6">
            Core Competencies
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Comprehensive expertise across enterprise architecture, cloud technologies, 
            and digital transformation initiatives.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {data.categories.map((category, index) => {
            const IconComponent = iconMap[category.icon];
            
            return (
              <div 
                key={index}
                className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 group border border-slate-200"
              >
                <div className="flex items-center mb-6">
                  <div className="p-3 bg-indigo-100 rounded-lg mr-4 group-hover:bg-indigo-200 transition-colors duration-300">
                    <IconComponent className="text-indigo-600" size={24} />
                  </div>
                  <h3 className="text-xl font-semibold text-slate-800">
                    {category.title}
                  </h3>
                </div>
                
                <div className="space-y-3">
                  {category.skills.map((skill, skillIndex) => (
                    <div 
                      key={skillIndex}
                      className="flex items-center text-slate-600 hover:text-indigo-600 transition-colors duration-200"
                    >
                      <div className="w-2 h-2 bg-indigo-400 rounded-full mr-3 group-hover:bg-indigo-600 transition-colors duration-300"></div>
                      <span className="text-sm font-medium">{skill}</span>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>

        {/* Additional Info */}
        <div className="mt-16 text-center">
          <div className="bg-white rounded-2xl p-8 shadow-lg border border-slate-200 max-w-4xl mx-auto">
            <h3 className="text-2xl font-semibold text-slate-800 mb-4">
              Industry Expertise
            </h3>
            <p className="text-slate-600 leading-relaxed">
              Deep domain knowledge across Banking & Finance, Insurance, Retail, eCommerce, 
              Public Sector, Utilities, Aviation, and more. Successfully delivered enterprise-wide 
              digital transformation initiatives across multi-vendor, large and complex organizations.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Skills;