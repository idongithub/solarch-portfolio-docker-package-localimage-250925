#!/bin/bash

# Create Static HTML Portfolio - No build process needed
# Just pure HTML/CSS/JS that works directly

set -e

echo "🌐 Creating Static HTML Portfolio"
echo "================================"

# Create static directory
mkdir -p static-portfolio

# Create index.html with all the portfolio content
cat > static-portfolio/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kamal Singh - IT Portfolio Architect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        /* Header */
        header {
            background: rgba(0, 0, 0, 0.9);
            color: white;
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            display: flex;
            align-items: center;
            font-size: 1.5rem;
            font-weight: bold;
            color: #f59e0b;
        }
        
        .logo-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(45deg, #3b82f6, #1e40af);
            border-radius: 50%;
            margin-right: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        nav ul {
            display: flex;
            list-style: none;
            gap: 2rem;
        }
        
        nav a {
            color: white;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        nav a:hover {
            color: #f59e0b;
        }
        
        /* Hero Section */
        .hero {
            background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7)), url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 800"><rect fill="%23000080" width="1200" height="800"/><g fill="%23ffffff" opacity="0.1"><circle cx="200" cy="200" r="100"/><circle cx="600" cy="300" r="80"/><circle cx="1000" cy="150" r="120"/></g></svg>');
            height: 100vh;
            display: flex;
            align-items: center;
            color: white;
            text-align: center;
        }
        
        .hero-content h1 {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            color: #f59e0b;
        }
        
        .hero-content h2 {
            font-size: 2rem;
            margin-bottom: 2rem;
            color: #94a3b8;
        }
        
        .stats {
            display: flex;
            justify-content: center;
            gap: 3rem;
            margin: 3rem 0;
            flex-wrap: wrap;
        }
        
        .stat {
            text-align: center;
            padding: 1rem;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #f59e0b;
            display: block;
        }
        
        .cta-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s;
            display: inline-block;
        }
        
        .btn-primary {
            background: #f59e0b;
            color: white;
        }
        
        .btn-secondary {
            background: transparent;
            color: white;
            border: 2px solid #f59e0b;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        /* Sections */
        .section {
            padding: 80px 0;
            background: white;
        }
        
        .section:nth-child(even) {
            background: #f8fafc;
        }
        
        .section-title {
            text-align: center;
            font-size: 2.5rem;
            margin-bottom: 3rem;
            color: #1e40af;
        }
        
        /* Skills */
        .skills-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }
        
        .skill-card {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border-left: 4px solid #f59e0b;
        }
        
        .skill-card h3 {
            color: #1e40af;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .skill-icon {
            width: 30px;
            height: 30px;
            background: #f59e0b;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .skill-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin: 1rem 0;
        }
        
        .skill-tag {
            background: #e0f2fe;
            color: #0277bd;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.9rem;
        }
        
        /* Projects */
        .projects-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }
        
        .project-card {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }
        
        .project-card:hover {
            transform: translateY(-5px);
        }
        
        .project-image {
            height: 200px;
            background: linear-gradient(45deg, #3b82f6, #1e40af);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.2rem;
            font-weight: bold;
        }
        
        .project-content {
            padding: 1.5rem;
        }
        
        .project-content h3 {
            color: #1e40af;
            margin-bottom: 0.5rem;
        }
        
        .project-meta {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }
        
        /* Contact */
        .contact-content {
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .contact-info {
            display: flex;
            justify-content: center;
            gap: 3rem;
            margin-top: 2rem;
            flex-wrap: wrap;
        }
        
        .contact-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #1e40af;
            font-weight: bold;
        }
        
        /* Footer */
        footer {
            background: #1e40af;
            color: white;
            text-align: center;
            padding: 2rem 0;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .hero-content h1 {
                font-size: 2.5rem;
            }
            
            .hero-content h2 {
                font-size: 1.5rem;
            }
            
            .stats {
                gap: 1rem;
            }
            
            nav ul {
                flex-direction: column;
                gap: 1rem;
            }
            
            .header-content {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="container">
            <div class="header-content">
                <div class="logo">
                    <div class="logo-icon">AS</div>
                    ARCHSOL IT Solutions
                </div>
                <nav>
                    <ul>
                        <li><a href="#home">Home</a></li>
                        <li><a href="#about">About</a></li>
                        <li><a href="#skills">Skills</a></li>
                        <li><a href="#projects">Projects</a></li>
                        <li><a href="#contact">Contact</a></li>
                    </ul>
                </nav>
            </div>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero" id="home">
        <div class="container">
            <div class="hero-content">
                <h1>Kamal Singh</h1>
                <h2>IT Portfolio Architect</h2>
                <p>Leading enterprise architecture and digital transformation initiatives with cutting-edge Gen AI and Agentic AI technologies</p>
                
                <div class="stats">
                    <div class="stat">
                        <span class="stat-number">26+</span>
                        <span>Years Experience</span>
                    </div>
                    <div class="stat">
                        <span class="stat-number">50+</span>
                        <span>Projects Delivered</span>
                    </div>
                    <div class="stat">
                        <span class="stat-number">10+</span>
                        <span>Industry Sectors</span>
                    </div>
                </div>
                
                <div class="cta-buttons">
                    <a href="#projects" class="btn btn-primary">View My Work</a>
                    <a href="#contact" class="btn btn-secondary">Get In Touch</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Skills Section -->
    <section class="section" id="skills">
        <div class="container">
            <h2 class="section-title">Core Competencies</h2>
            <div class="skills-grid">
                <div class="skill-card">
                    <h3><span class="skill-icon">🤖</span>AI & Emerging Technologies</h3>
                    <p>Leading-edge artificial intelligence architecture and agentic systems design for enterprise transformation.</p>
                    <div class="skill-tags">
                        <span class="skill-tag">Gen AI Architecture</span>
                        <span class="skill-tag">Agentic AI Systems</span>
                        <span class="skill-tag">LLM Integration</span>
                        <span class="skill-tag">AI-Driven Automation</span>
                        <span class="skill-tag">RAG Systems</span>
                        <span class="skill-tag">Multi-Agent Orchestration</span>
                    </div>
                </div>
                
                <div class="skill-card">
                    <h3><span class="skill-icon">🏗️</span>Enterprise Architecture</h3>
                    <p>Strategic technology leadership and large-scale system design across multiple industry verticals.</p>
                    <div class="skill-tags">
                        <span class="skill-tag">Solution Design</span>
                        <span class="skill-tag">System Integration</span>
                        <span class="skill-tag">Digital Transformation</span>
                        <span class="skill-tag">Architecture Governance</span>
                    </div>
                </div>
                
                <div class="skill-card">
                    <h3><span class="skill-icon">☁️</span>Cloud & Modern Technology</h3>
                    <p>Leading cloud adoption and modernization initiatives with cutting-edge technologies including Gen AI services.</p>
                    <div class="skill-tags">
                        <span class="skill-tag">AWS</span>
                        <span class="skill-tag">Azure</span>
                        <span class="skill-tag">GCP</span>
                        <span class="skill-tag">Kubernetes</span>
                        <span class="skill-tag">Azure OpenAI</span>
                        <span class="skill-tag">AWS Bedrock</span>
                    </div>
                </div>
                
                <div class="skill-card">
                    <h3><span class="skill-icon">🔒</span>Security & Compliance</h3>
                    <p>Enterprise-grade security architecture and regulatory compliance framework implementation.</p>
                    <div class="skill-tags">
                        <span class="skill-tag">Zero Trust</span>
                        <span class="skill-tag">GDPR</span>
                        <span class="skill-tag">SOX</span>
                        <span class="skill-tag">Identity Management</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Projects Section -->
    <section class="section" id="projects">
        <div class="container">
            <h2 class="section-title">Featured Projects</h2>
            <div class="projects-grid">
                <div class="project-card">
                    <div class="project-image">Gen AI Platform</div>
                    <div class="project-content">
                        <h3>Enterprise Gen AI & Agentic Systems Platform</h3>
                        <div class="project-meta">Financial Services • 14 months</div>
                        <p>Architected comprehensive enterprise Gen AI platform with multi-agent orchestration, RAG systems, and intelligent automation for regulatory compliance.</p>
                        <div class="skill-tags">
                            <span class="skill-tag">Azure OpenAI</span>
                            <span class="skill-tag">LangChain</span>
                            <span class="skill-tag">RAG Systems</span>
                        </div>
                    </div>
                </div>
                
                <div class="project-card">
                    <div class="project-image">Digital Transformation</div>
                    <div class="project-content">
                        <h3>Digital Portal Transformation</h3>
                        <div class="project-meta">Insurance • 18 months</div>
                        <p>Led comprehensive digital transformation initiative for specialty insurance provider, modernizing legacy systems with cloud-native architecture.</p>
                        <div class="skill-tags">
                            <span class="skill-tag">AWS</span>
                            <span class="skill-tag">Microservices</span>
                            <span class="skill-tag">API Gateway</span>
                        </div>
                    </div>
                </div>
                
                <div class="project-card">
                    <div class="project-image">CIAM Solution</div>
                    <div class="project-content">
                        <h3>Enterprise CIAM Solution</h3>
                        <div class="project-meta">Banking • 12 months</div>
                        <p>Designed and implemented customer identity and access management solution supporting 2M+ users with advanced security features.</p>
                        <div class="skill-tags">
                            <span class="skill-tag">Identity Management</span>
                            <span class="skill-tag">OAuth 2.0</span>
                            <span class="skill-tag">Zero Trust</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section class="section" id="contact">
        <div class="container">
            <h2 class="section-title">Get In Touch</h2>
            <div class="contact-content">
                <p>Ready to transform your enterprise architecture with cutting-edge AI technologies? Let's discuss how we can drive your digital transformation initiatives.</p>
                <div class="contact-info">
                    <div class="contact-item">
                        <span>📧</span>
                        <span>kamal.singh@architecturesolutions.co.uk</span>
                    </div>
                    <div class="contact-item">
                        <span>📍</span>
                        <span>Amersham, United Kingdom</span>
                    </div>
                    <div class="contact-item">
                        <span>💼</span>
                        <span>ARCHSOL IT Solutions</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <div class="container">
            <p>&copy; 2024 Kamal Singh - IT Portfolio Architect. All rights reserved.</p>
            <p>ARCHSOL IT Solutions - Enterprise Architecture & Digital Transformation</p>
        </div>
    </footer>

    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Simple animation on scroll
        window.addEventListener('scroll', () => {
            const cards = document.querySelectorAll('.skill-card, .project-card');
            cards.forEach(card => {
                const cardTop = card.offsetTop;
                const cardHeight = card.clientHeight;
                const windowHeight = window.innerHeight;
                const scrollTop = window.scrollY;

                if (scrollTop > (cardTop + cardHeight - windowHeight)) {
                    card.style.opacity = '1';
                    card.style.transform = 'translateY(0)';
                }
            });
        });
    </script>
</body>
</html>
EOF

echo "✅ Static HTML portfolio created"

# Create simple Dockerfile for static content
cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy static files
COPY static-portfolio/ /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

echo "✅ Simple static Dockerfile created"

# Build it
echo "🔨 Building static Docker image..."
sudo docker build -t kamal-portfolio-static . --no-cache

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉🎉🎉 SUCCESS! 🎉🎉🎉"
    echo ""
    echo "✅ Your static IT Portfolio is ready!"
    echo ""
    echo "🚀 To run your portfolio:"
    echo "   sudo docker run -d -p 80:80 --name my-portfolio kamal-portfolio-static"
    echo ""
    echo "🌐 Then visit: http://localhost"
    echo ""
    echo "📊 Your portfolio includes:"
    echo "   ✅ ARCHSOL IT Solutions branding"
    echo "   ✅ IT Portfolio Architect positioning"
    echo "   ✅ Gen AI and Agentic AI skills"
    echo "   ✅ Professional project showcase"
    echo "   ✅ Complete responsive design"
    echo "   ✅ Smooth animations and interactions"
    echo ""
    echo "🔧 Container management:"
    echo "   Stop:    sudo docker stop my-portfolio"
    echo "   Start:   sudo docker start my-portfolio"
    echo "   Remove:  sudo docker rm -f my-portfolio"
    echo ""
    echo "✅ STATIC PORTFOLIO BUILD COMPLETED!"
    
else
    echo "❌ Build failed"
    exit 1
fi