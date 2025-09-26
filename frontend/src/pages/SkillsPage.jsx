import React, { useEffect, useState } from 'react';
import { Building2, Cloud, Network, Shield, Users, Briefcase, Star, Award, Brain } from 'lucide-react';
import Layout from '../components/Layout';

// Safe icon map with fallback
const iconMap = {
  Building2,
  Cloud,
  Network,
  Shield,
  Users,
  Briefcase,
  Brain,
  Star,
  Award
};

// Default skills data in case portfolioData fails to load
const defaultSkills = {
  categories: [
    {
      name: "Enterprise Architecture",
      icon: "Building2",
      skills: [
        { name: "Solution Architecture", level: "Expert", years: "15+" },
        { name: "System Design", level: "Expert", years: "15+" }
      ]
    }
  ]
};

const SkillsPage = () => {
  const [isLoaded, setIsLoaded] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [skills, setSkills] = useState(defaultSkills);

  useEffect(() => {
    // Safely load portfolioData with error handling
    const loadSkillsData = async () => {
      try {
        const { portfolioData } = await import('../mock');
        if (portfolioData && portfolioData.skills) {
          setSkills(portfolioData.skills);
        }
      } catch (error) {
        console.warn('Failed to load portfolio data, using defaults:', error);
        // Keep defaultSkills
      } finally {
        setIsLoaded(true);
      }
    };

    loadSkillsData();
  }, []);

  const getLevelColor = (level) => {
    switch (level) {
      case 'Expert':
        return 'text-yellow-600 bg-yellow-100 border-yellow-300';
      case 'Advanced':
        return 'text-blue-600 bg-blue-100 border-blue-300';
      default:
        return 'text-slate-600 bg-slate-100 border-slate-300';
    }
  };

  const getLevelStars = (level) => {
    switch (level) {
      case 'Expert':
        return 5;
      case 'Advanced':
        return 4;
      default:
        return 3;
    }
  };

  // Safe icon rendering with fallback
  const renderIcon = (iconName) => {
    const IconComponent = iconMap[iconName] || Building2;
    return <IconComponent className="h-6 w-6" />;
  };

  return (
    <Layout>
      <div className={`transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
        {/* Hero Section */}
        <section className="relative py-32 bg-gradient-to-br from-navy-900 via-charcoal-800 to-navy-900 overflow-hidden">
          <div className="absolute inset-0">
            <img 
              src={skills.backgroundImage} 
              alt="Technology Innovation Pattern"
              className="w-full h-full object-cover opacity-20"
            />
          </div>
          
          <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center">
              <h1 className="text-5xl lg:text-7xl font-light text-white mb-8 font-serif">
                {skills.title}
              </h1>
              <p className="text-xl text-gold-300 max-w-4xl mx-auto leading-relaxed font-serif">
                {skills.subtitle}
              </p>
            </div>
          </div>
        </section>

        {/* Skills Grid */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              {skills.categories.map((category, index) => {
                const IconComponent = iconMap[category.icon] || Building2;
                const isSelected = selectedCategory === index;
                
                return (
                  <div 
                    key={index}
                    className={`group cursor-pointer transition-all duration-300 ${
                      isSelected ? 'transform scale-105 z-10' : 'hover:transform hover:scale-105'
                    }`}
                    onClick={() => setSelectedCategory(isSelected ? null : index)}
                  >
                    <div className={`bg-white rounded-xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 border-2 ${
                      isSelected 
                        ? 'border-gold-400 shadow-2xl' 
                        : 'border-navy-200 group-hover:border-gold-300'
                    }`}>
                      {/* Header */}
                      <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center">
                          <div className={`p-3 rounded-lg mr-4 transition-colors duration-300 ${
                            isSelected 
                              ? 'bg-gold-200 text-gold-700' 
                              : 'bg-navy-100 text-navy-600 group-hover:bg-gold-100 group-hover:text-gold-600'
                          }`}>
                            <IconComponent size={28} />
                          </div>
                        </div>
                        <div className={`px-3 py-1 rounded-full text-xs font-semibold border font-serif ${getLevelColor(category.level)}`}>
                          {category.level}
                        </div>
                      </div>

                      <h3 className="text-2xl font-semibold text-navy-900 mb-4 font-serif">
                        {category.title}
                      </h3>

                      {/* Skill Level Stars */}
                      <div className="flex items-center mb-4">
                        {[...Array(5)].map((_, starIndex) => (
                          <Star 
                            key={starIndex}
                            className={`w-4 h-4 ${
                              starIndex < getLevelStars(category.level)
                                ? 'text-gold-400 fill-current'
                                : 'text-slate-300'
                            }`}
                          />
                        ))}
                        <span className="ml-2 text-sm text-slate-600 font-serif">
                          {getLevelStars(category.level)}/5
                        </span>
                      </div>

                      <p className="text-slate-600 mb-6 font-serif leading-relaxed">
                        {category.description}
                      </p>
                      
                      {/* Skills List */}
                      <div className="space-y-3">
                        <h4 className="font-semibold text-navy-900 text-sm font-serif">Key Technologies:</h4>
                        <div className="flex flex-wrap gap-2">
                          {category.skills.slice(0, isSelected ? category.skills.length : 4).map((skill, skillIndex) => (
                            <span 
                              key={skillIndex}
                              className="px-3 py-1 bg-navy-50 text-navy-700 rounded-full text-xs font-medium hover:bg-gold-100 hover:text-gold-700 transition-colors duration-200 font-serif"
                            >
                              {skill}
                            </span>
                          ))}
                          {!isSelected && category.skills.length > 4 && (
                            <span className="px-3 py-1 bg-gold-100 text-gold-700 rounded-full text-xs font-medium font-serif">
                              +{category.skills.length - 4} more
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Expand Indicator */}
                      <div className="mt-6 text-center">
                        <span className="text-xs text-slate-500 font-serif">
                          {isSelected ? 'Click to collapse' : 'Click to expand'}
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Certifications Section */}
        <section className="py-24 bg-navy-50">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Professional Certifications
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Industry-recognized certifications demonstrating expertise across major cloud platforms and enterprise architecture frameworks.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {(skills.certifications || []).map((cert, index) => (
                <div 
                  key={index}
                  className="bg-white rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 border border-slate-200 hover:border-yellow-300 group"
                >
                  <div className="flex items-center">
                    <div className="p-3 bg-yellow-100 rounded-lg mr-4 group-hover:bg-yellow-200 transition-colors duration-300">
                      <Award className="text-yellow-600" size={24} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-slate-900 font-serif leading-tight">
                        {cert}
                      </h3>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Industry Expertise */}
        <section className="py-24 bg-white">
          <div className="max-w-7xl mx-auto px-6 lg:px-8">
            <div className="text-center mb-16">
              <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
                Industry Expertise
              </h2>
              <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
                Deep domain knowledge across multiple industry verticals, enabling effective translation of business requirements into technical solutions.
              </p>
            </div>

            <div className="bg-gradient-to-br from-navy-900 to-charcoal-800 rounded-2xl p-12 text-center">
              <h3 className="text-3xl font-semibold text-white mb-8 font-serif">
                26+ Years Across Industries
              </h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Banking</div>
                  <div className="text-sm text-slate-400 font-serif">& Finance</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Insurance</div>
                  <div className="text-sm text-slate-400 font-serif">& Risk</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Retail</div>
                  <div className="text-sm text-slate-400 font-serif">& eCommerce</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Public</div>
                  <div className="text-sm text-slate-400 font-serif">Sector</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Utilities</div>
                  <div className="text-sm text-slate-400 font-serif">& Energy</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Aviation</div>
                  <div className="text-sm text-slate-400 font-serif">& Transport</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Gaming</div>
                  <div className="text-sm text-slate-400 font-serif">& Entertainment</div>
                </div>
                <div className="text-gold-300">
                  <div className="text-2xl font-bold mb-2 font-serif">Healthcare</div>
                  <div className="text-sm text-slate-400 font-serif">& Life Sciences</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Call to Action */}
        <section className="py-24 bg-gradient-to-br from-navy-900 to-charcoal-800">
          <div className="max-w-7xl mx-auto px-6 lg:px-8 text-center">
            <h2 className="text-4xl lg:text-5xl font-light text-white mb-8 font-serif">
              Let's Leverage This Expertise
            </h2>
            <p className="text-xl text-slate-300 mb-12 max-w-3xl mx-auto font-serif">
              Ready to apply strategic architecture and proven methodologies to your next transformation initiative?
            </p>
            <button
              onClick={() => window.location.href = '/contact'}
              className="inline-flex items-center px-8 py-4 bg-gold-500 hover:bg-gold-600 text-navy-900 rounded-lg font-semibold transition-all duration-300 hover:scale-105 font-serif"
            >
              Discuss Your Project
            </button>
          </div>
        </section>
      </div>
    </Layout>
  );
};

export default SkillsPage;