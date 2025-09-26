import React, { useState } from 'react';
import { ExternalLink, Code, Award } from 'lucide-react';

const Projects = ({ data }) => {
  const [selectedCategory, setSelectedCategory] = useState('All');
  
  const categories = ['All', ...new Set(data.map(project => project.category))];
  
  const filteredProjects = selectedCategory === 'All' 
    ? data 
    : data.filter(project => project.category === selectedCategory);

  return (
    <section id="projects" className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-slate-800 mb-6">
            Featured Projects
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto">
            Showcasing major architectural achievements and digital transformation initiatives 
            that have driven business value and innovation.
          </p>
        </div>

        {/* Category Filter */}
        <div className="flex flex-wrap justify-center gap-4 mb-12">
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-6 py-2 rounded-full font-medium transition-all duration-300 ${
                selectedCategory === category
                  ? 'bg-indigo-600 text-white shadow-lg'
                  : 'bg-white text-slate-700 hover:bg-indigo-100 border border-slate-200'
              }`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Projects Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredProjects.map((project) => (
            <div 
              key={project.id}
              className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 group border border-slate-200"
            >
              {/* Project Image */}
              <div className="relative h-48 overflow-hidden">
                <img 
                  src={project.image} 
                  alt={project.title}
                  className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent"></div>
                <div className="absolute top-4 right-4">
                  <span className="px-3 py-1 bg-white/90 text-slate-700 rounded-full text-xs font-medium">
                    {project.category}
                  </span>
                </div>
              </div>

              {/* Project Content */}
              <div className="p-6">
                <h3 className="text-xl font-bold text-slate-800 mb-3 group-hover:text-indigo-600 transition-colors duration-200">
                  {project.title}
                </h3>
                
                <p className="text-slate-600 mb-4 leading-relaxed">
                  {project.description}
                </p>

                {/* Technologies */}
                <div className="mb-4">
                  <div className="flex flex-wrap gap-2">
                    {project.technologies.slice(0, 3).map((tech, index) => (
                      <span 
                        key={index}
                        className="px-2 py-1 bg-slate-100 text-slate-600 rounded text-xs font-medium"
                      >
                        {tech}
                      </span>
                    ))}
                    {project.technologies.length > 3 && (
                      <span className="px-2 py-1 bg-indigo-100 text-indigo-600 rounded text-xs font-medium">
                        +{project.technologies.length - 3} more
                      </span>
                    )}
                  </div>
                </div>

                {/* Outcomes */}
                <div className="space-y-2 mb-4">
                  {project.outcomes.map((outcome, index) => (
                    <div key={index} className="flex items-center text-sm text-slate-600">
                      <Award className="text-green-500 mr-2" size={14} />
                      <span>{outcome}</span>
                    </div>
                  ))}
                </div>

                {/* Action Button */}
                <div className="flex items-center justify-between">
                  <button className="flex items-center text-indigo-600 hover:text-indigo-700 font-medium transition-colors duration-200">
                    <Code className="mr-2" size={16} />
                    View Details
                  </button>
                  <button className="p-2 text-slate-400 hover:text-indigo-600 transition-colors duration-200">
                    <ExternalLink size={16} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Additional Info */}
        <div className="mt-16 text-center">
          <div className="bg-white rounded-2xl p-8 shadow-lg border border-slate-200 max-w-4xl mx-auto">
            <h3 className="text-2xl font-semibold text-slate-800 mb-4">
              Ready for Your Next Challenge?
            </h3>
            <p className="text-slate-600 leading-relaxed mb-6">
              These projects represent just a fraction of my architectural portfolio. 
              I'm passionate about tackling complex enterprise challenges and driving digital transformation.
            </p>
            <button 
              onClick={() => document.querySelector('#contact')?.scrollIntoView({ behavior: 'smooth' })}
              className="inline-flex items-center px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium transition-all duration-300 hover:scale-105"
            >
              Let's Discuss Your Project
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Projects;