import React from 'react';
import { Star, Quote, Building, Award, Target } from 'lucide-react';

const Testimonials = ({ data }) => {
  return (
    <section id="testimonials" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-light text-navy-900 mb-6 font-serif">
            Client Testimonials
          </h2>
          <p className="text-xl text-slate-600 max-w-3xl mx-auto font-serif">
            What industry leaders and executives say about working on 
            complex architecture and transformation projects.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {data.map((testimonial) => (
            <div 
              key={testimonial.id}
              className="bg-white rounded-xl p-8 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-2 group border border-navy-200 hover:border-gold-300 relative"
            >
              {/* Quote Icon */}
              <div className="absolute top-6 right-6 text-gold-200">
                <Quote size={32} />
              </div>

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

              {/* Project Info */}
              <div className="mb-4 p-3 bg-navy-50 rounded-lg border border-navy-100">
                <div className="flex items-center mb-2">
                  <Target className="text-navy-600 mr-2" size={16} />
                  <span className="text-sm font-semibold text-navy-900 font-serif">
                    {testimonial.project}
                  </span>
                </div>
                <div className="flex items-center text-xs text-slate-600">
                  <Building className="mr-1" size={12} />
                  <span className="font-serif">{testimonial.industry}</span>
                  <span className="mx-2">•</span>
                  <span className="font-serif">{testimonial.projectScale}</span>
                </div>
              </div>

              {/* Anonymous Author Info */}
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

        {/* Stats Section */}
        <div className="mt-16">
          <div className="bg-gradient-to-br from-navy-900 to-charcoal-800 rounded-2xl p-12 text-center">
            <h3 className="text-3xl font-semibold text-white mb-8 font-serif">
              Trusted Across Industries
            </h3>
            
            <div className="grid md:grid-cols-4 gap-8 mb-8">
              <div className="text-center">
                <div className="text-3xl font-bold text-gold-400 mb-2 font-serif">15+</div>
                <div className="text-sm text-slate-300 font-serif">Industries Served</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-gold-400 mb-2 font-serif">100+</div>
                <div className="text-sm text-slate-300 font-serif">Successful Projects</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-gold-400 mb-2 font-serif">99%</div>
                <div className="text-sm text-slate-300 font-serif">Client Satisfaction</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-gold-400 mb-2 font-serif">26+</div>
                <div className="text-sm text-slate-300 font-serif">Years Experience</div>
              </div>
            </div>
            
            <p className="text-slate-300 leading-relaxed max-w-4xl mx-auto font-serif">
              Built lasting relationships with C-level executives, technical teams, 
              and stakeholders across Financial Services, Insurance, Retail, Public Sector, 
              Healthcare, and more. Focused on collaborative leadership and technical excellence 
              that consistently delivers transformational results.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;