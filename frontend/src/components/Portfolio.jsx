import React, { useState, useEffect } from 'react';
import { portfolioData } from '../mock';
import Header from './Header';
import Hero from './Hero';
import About from './About';
import Skills from './Skills'; 
import Experience from './Experience';
import Projects from './Projects';
import Testimonials from './Testimonials';
import Contact from './Contact';
import Footer from './Footer';

const Portfolio = () => {
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    setIsLoaded(true);
  }, []);

  return (
    <div className={`min-h-screen bg-slate-50 transition-opacity duration-1000 ${isLoaded ? 'opacity-100' : 'opacity-0'}`}>
      <Header />
      <main>
        <Hero data={portfolioData.hero} />
        <About data={portfolioData.about} />
        <Skills data={portfolioData.skills} />
        <Experience data={portfolioData.experience} />
        <Projects data={portfolioData.projects} />
        <Testimonials data={portfolioData.testimonials} />
        <Contact data={portfolioData.contact} />
      </main>
      <Footer />
    </div>
  );
};

export default Portfolio;