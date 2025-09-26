import React, { useEffect, useState } from 'react';
import { ExternalLink, Code, Award, Clock, Users, Target, Star } from 'lucide-react';
import Layout from '../components/Layout';
import { portfolioData } from '../mock';

const ProjectsPage = () => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [selectedProject, setSelectedProject] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('All');

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  const { projects } = portfolioData;
  
  const categories = ['All', ...new Set(projects.featured.map(project => project.category))];
  
  const filteredProjects = selectedCategory === 'All' 
    ? projects.featured 
    : projects.featured.filter(project => project.category === selectedCategory);

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section */}
        <section className="relative py-32 bg-gradient-to-br from-navy-900 via-charcoal-800 to-navy-900 overflow-hidden">
          <div className="absolute inset-0">
            <img 
              src={projects.backgroundImage} 
              alt="Innovation Excellence"
              className="w-full h-full object-cover opacity-20"
            />
          </div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-8 font-serif">
                {projects.title}
              </h1>
              <p className="text-xl text-gold-300 max-w-4xl mx-auto leading-relaxed font-serif">
                {projects.subtitle}
              </p>
            </div>
          </div>
        </section>

        {/* Category Filter */}
        <section className="py-12 bg-white border-b border-slate-200">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="flex flex-wrap justify-center gap-4">
              {categories.map((category) => (
                <button
                  key={category}
                  onClick={() => setSelectedCategory(category)}
                  className={`px-6 py-3 rounded-full font-medium transition-all duration-300 font-serif ${
                    selectedCategory === category
                      ? 'bg-gold-500 text-white shadow-lg transform scale-105'
                      : 'bg-white text-navy-700 hover:bg-gold-100 border-2 border-navy-200 hover:border-gold-300 hover:transform hover:scale-105'
                  }`}
                >
                  {category}
                </button>
              ))}
            </div>
          </div>
        </section>

        {/* Projects Grid */}
        <section className="py-24 bg-slate-50">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="grid lg:grid-cols-2 gap-12">
              {filteredProjects.map((project) => (
                <div 
                  key={project.id}
                  className={`group transition-all duration-300 ${
                    selectedProject === project.id ? 'transform scale-105 z-10' : ''
                  }`}
                >
                  <div className={`bg-white rounded-2xl overflow-hidden shadow-xl hover:shadow-2xl transition-all duration-300 border-2 ${
                    selectedProject === project.id 
                      ? 'border-gold-400' 
                      : 'border-navy-200 hover:border-gold-300'
                  }`}>
                    {/* Project Image */}
                    <div className="relative h-64 overflow-hidden">
                      <img 
                        src={project.image} 
                        alt={project.title}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-navy-900/60 to-transparent"></div>
                      
                      {/* Category Badge */}
                      <div className="absolute top-6 left-6">
                        <span className="px-4 py-2 bg-gold-500/90 text-white rounded-full text-sm font-semibold font-serif backdrop-blur-sm">
                          {project.category}
                        </span>
                      </div>

                      {/* Featured Badge */}
                      {project.featured && (
                        <div className="absolute top-6 right-6">
                          <span className="px-3 py-1 bg-white/90 text-navy-900 rounded-full text-xs font-semibold font-serif backdrop-blur-sm">
                            Featured
                          </span>
                        </div>
                      )}
                    </div>

                    {/* Project Content */}
                    <div className="p-8">
                      {/* Header */}
                      <div className="mb-6">
                        <div className="flex items-center justify-between mb-4">
                          <h3 className="text-2xl font-bold text-navy-900 group-hover:text-gold-600 transition-colors duration-200 font-serif">
                            {project.title}
                          </h3>
                          <button
                            onClick={() => setSelectedProject(selectedProject === project.id ? null : project.id)}
                            className="p-2 text-slate-400 hover:text-gold-600 transition-colors duration-200"
                          >
                            <ExternalLink size={20} />
                          </button>
                        </div>
                        
                        <div className="flex items-center gap-4 text-sm text-slate-600 mb-4">
                          <div className="flex items-center">
                            <Users className="mr-1" size={16} />
                            <span className="font-serif">{project.client}</span>
                          </div>
                          <div className="flex items-center">
                            <Clock className="mr-1" size={16} />
                            <span className="font-serif">{project.duration}</span>
                          </div>
                        </div>
                      </div>

                      {/* Description */}
                      <p className="text-slate-600 mb-6 leading-relaxed font-serif">
                        {project.description}
                      </p>

                      {/* Expanded Content */}
                      {selectedProject === project.id && (
                        <div className="space-y-6 mb-6">
                          {/* Challenge */}
                          <div className="p-4 bg-slate-50 rounded-lg border border-slate-200">
                            <h4 className="font-semibold text-navy-900 mb-2 font-serif">Challenge:</h4>
                            <p className="text-slate-600 font-serif">{project.challenge}</p>
                          </div>

                          {/* Solution */}
                          <div className="p-4 bg-gold-50 rounded-lg border border-gold-200">
                            <h4 className="font-semibold text-gold-800 mb-2 font-serif">Solution:</h4>
                            <p className="text-gold-700 font-serif">{project.solution}</p>
                          </div>
                        </div>
                      )}

                      {/* Technologies */}
                      <div className="mb-6">
                        <h4 className="font-semibold text-navy-900 mb-3 font-serif">Technologies:</h4>
                        <div className="flex flex-wrap gap-2">
                          {project.technologies.map((tech, index) => (
                            <span 
                              key={index}
                              className="px-3 py-1 bg-navy-100 text-navy-700 rounded-full text-xs font-medium hover:bg-gold-100 hover:text-gold-700 transition-colors duration-200 font-serif"
                            >
                              {tech}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Outcomes */}
                      <div className="space-y-3 mb-6">
                        <h4 className="font-semibold text-navy-900 flex items-center font-serif">
                          <Target className="mr-2 text-green-500" size={18} />
                          Key Outcomes:
                        </h4>
                        {project.outcomes.map((outcome, index) => (
                          <div key={index} className="flex items-center text-sm text-slate-600">
                            <Award className="text-green-500 mr-3 flex-shrink-0" size={16} />
                            <span className="font-serif">{outcome}</span>
                          </div>
                        ))}
                      </div>

                      {/* Action Buttons */}
                      <div className="flex items-center justify-between pt-4 border-t border-slate-200">
                        <button 
                          onClick={() => setSelectedProject(selectedProject === project.id ? null : project.id)}
                          className="flex items-center text-gold-600 hover:text-gold-700 font-medium transition-colors duration-200 font-serif"
                        >
                          <Code className="mr-2" size={16} />
                          {selectedProject === project.id ? 'Show Less' : 'View Details'}
                        </button>
                        
                        <div className="text-xs text-slate-500 font-serif">
                          Click for detailed analysis
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Project Stats */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Project Portfolio Impact
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Measurable business outcomes across major transformation initiatives.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
              <div className="text-center group">
                <div className="bg-navy-50 rounded-xl p-8 border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">60%</div>
                  <div className="text-slate-600 font-serif">Average Cost Reduction</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-navy-50 rounded-xl p-8 border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">99.9%</div>
                  <div className="text-slate-600 font-serif">System Uptime</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-navy-50 rounded-xl p-8 border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">50%</div>
                  <div className="text-slate-600 font-serif">Performance Improvement</div>
                </div>
              </div>
              
              <div className="text-center group">
                <div className="bg-navy-50 rounded-xl p-8 border border-navy-200 group-hover:border-gold-300 group-hover:shadow-xl transition-all duration-300">
                  <div className="text-4xl font-bold text-navy-900 mb-3 font-serif">100%</div>
                  <div className="text-slate-600 font-serif">On-Time Delivery</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Client Testimonials */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                What Clients Say
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Feedback from industry leaders and executives on project collaboration and results.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {portfolioData.testimonials.map((testimonial) => (
                <div 
                  key={testimonial.id}
                  className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 border border-navy-200 hover:border-gold-300 group"
                >
                  {/* Rating */}
                  <div className="flex items-center mb-4">
                    {[...Array(testimonial.rating)].map((_, index) => (
                      <Star 
                        key={index} 
                        className="text-gold-400 fill-current" 
                        size={16} 
                      />
                    ))}
                  </div>

                  {/* Content */}
                  <p className="text-slate-700 leading-relaxed mb-6 italic font-serif">
                    "{testimonial.content}"
                  </p>

                  {/* Project Context */}
                  <div className="mb-4 p-3 bg-navy-50 rounded-lg border border-navy-100">
                    <div className="flex items-center mb-2">
                      <Target className="text-navy-600 mr-2" size={16} />
                      <span className="text-sm font-semibold text-navy-900 font-serif">
                        {testimonial.project}
                      </span>
                    </div>
                    <div className="flex items-center text-xs text-slate-600">
                      <Users className="mr-1" size={12} />
                      <span className="font-serif">{testimonial.industry}</span>
                      <span className="mx-2">•</span>
                      <span className="font-serif">{testimonial.projectScale}</span>
                    </div>
                  </div>

                  {/* Author */}
                  <div className="border-t border-slate-200 pt-4">
                    <div className="flex items-center mb-2">
                      <Award className="text-gold-500 mr-2" size={16} />
                      <h4 className="font-semibold text-navy-900 font-serif">
                        {testimonial.role}
                      </h4>
                    </div>
                    <p className="text-sm text-slate-600 font-serif">
                      {testimonial.company}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Project Success Stats */}
            <div className="mt-16">
              <div className="bg-navy-50 rounded-2xl p-12 border border-navy-200">
                <h3 className="text-3xl font-semibold text-navy-900 mb-8 text-center font-serif">
                  Project Success Metrics
                </h3>
                
                <div className="grid md:grid-cols-4 gap-8">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-gold-600 mb-2 font-serif">100%</div>
                    <div className="text-sm text-slate-600 font-serif">On-Time Delivery</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-gold-600 mb-2 font-serif">99%</div>
                    <div className="text-sm text-slate-600 font-serif">Client Satisfaction</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-gold-600 mb-2 font-serif">60%</div>
                    <div className="text-sm text-slate-600 font-serif">Avg Cost Reduction</div>
                  </div>
                  <div className="text-center">
                    <div className="text-3xl font-bold text-gold-600 mb-2 font-serif">15+</div>
                    <div className="text-sm text-slate-600 font-serif">Industries Served</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="py-24 bg-gradient-to-br from-navy-900 to-charcoal-800">
          <div className="max-w-7xl mx-auto px-6 lg:px-8 text-center">
            <h2 className="text-4xl lg:text-5xl font-light text-white mb-8 font-serif">
              Ready for Your Next Transformation?
            </h2>
            <p className="text-xl text-slate-300 mb-12 max-w-3xl mx-auto font-serif">
              Let's discuss how proven architectural expertise and strategic leadership 
              can drive similar results for your organization.
            </p>
            <button
              onClick={() => window.location.href = '/contact'}
              className="inline-flex items-center px-8 py-4 bg-gold-500 hover:bg-gold-600 text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
            >
              Start Your Project
            </button>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default ProjectsPage;