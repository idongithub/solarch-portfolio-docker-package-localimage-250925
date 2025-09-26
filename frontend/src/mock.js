// Updated Mock data for Kamal Singh's Corporate Professional Portfolio
export const portfolioData = {
  hero: {
    name: "Kamal Singh",
    title: "IT Portfolio Architect",
    tagline: "Transforming Enterprise Through Strategic Architecture & Digital Innovation",
    description: "26+ years of expertise in E2E Architecture and Digital Transformation, driving business growth through cost optimization, system integration, and cloud-native solutions.",
    heroVideo: "/images/hero/digital-tech-bg.jpg", // IT professional coding environment with blue lighting
    stats: [
      { number: "26+", label: "Years Experience", icon: "Award" },
      { number: "50+", label: "Projects Delivered", icon: "Briefcase" },
      { number: "10+", label: "Industry Sectors", icon: "Building2" }
    ]
  },

  about: {
    title: "About Me",
    summary: "An experienced business-focused Architecture Leader with 26+ years of extensive expertise in E2E Architecture and Digital Transformation. I leverage skills in cost optimization, system integration and cloud-native solutions to drive business growth and efficiency.",
    vision: "Demonstrates a visionary approach in designing innovative, modern and cost-effective architectures, while fostering collaboration across multi-vendor, large and complex Enterprises.",
    passion: "Passionate about integrating advanced technologies including Multi-Cloud, AI, APIs and Microservices to modernize and streamline enterprise systems, consistently delivering enterprise-wide impactful results.",
    backgroundImage: "/images/about/professional-portrait.jpg", // IT professional working with technology
    achievements: [
      { number: "100+", label: "Digital Transformations", icon: "Zap" },
      { number: "5", label: "Cloud Certifications", icon: "Award" },
      { number: "15+", label: "Industries Served", icon: "Globe" }
    ]
  },

  skills: {
    title: "Core Competencies",
    subtitle: "Comprehensive Technical & Leadership Expertise",
    backgroundImage: "/images/skills/tech-pattern.jpg", // Software development code on laptop screen
    categories: [
      {
        title: "Enterprise Architecture",
        icon: "Building2",
        level: "Expert",
        skills: ["E2E Architecture", "Digital Transformation", "TOGAF", "IASA", "Solution Design", "Technology Roadmaps"],
        description: "Comprehensive architectural design and governance across complex enterprise environments."
      },
      {
        title: "Cloud & Modern Technology",
        icon: "Cloud",
        level: "Expert", 
        skills: ["AWS", "Azure", "GCP", "Microservices", "API-First", "Serverless", "Kubernetes", "Docker", "Azure OpenAI", "AWS Bedrock"],
        description: "Leading cloud adoption and modernization initiatives with cutting-edge technologies including Gen AI services."
      },
      {
        title: "AI & Emerging Technologies",
        icon: "Brain",
        level: "Expert",
        skills: ["Gen AI Architecture", "Agentic AI Systems", "LLM Integration", "AI-Driven Automation", "RAG Systems", "Multi-Agent Orchestration", "AI Governance"],
        description: "Leading-edge artificial intelligence architecture and agentic systems design for enterprise transformation."
      },
      {
        title: "Integration & Data Architecture",
        icon: "Network",
        level: "Expert",
        skills: ["ESB", "API Gateway", "Apache Kafka", "Big Data", "AI/ML", "Data Architecture", "Event-Driven"],
        description: "Seamless system integration and data strategy across distributed architectures."
      },
      {
        title: "Security & Compliance",
        icon: "Shield",
        level: "Advanced",
        skills: ["CIAM/IAM", "Zero Trust", "OAuth", "SAML", "MFA", "Regulatory Compliance", "Security Architecture"],
        description: "Enterprise-grade security frameworks and regulatory compliance implementation."
      },
      {
        title: "Leadership & Governance",
        icon: "Users",
        level: "Expert",
        skills: ["Architecture Governance", "Team Leadership", "Stakeholder Management", "Agile/SAFe", "Mentoring"],
        description: "Strategic leadership and governance frameworks for large-scale transformations."
      },
      {
        title: "Industry Expertise",
        icon: "Briefcase",
        level: "Expert",
        skills: ["Banking & Finance", "Insurance", "Retail", "eCommerce", "Public Sector", "Utilities", "Aviation"],
        description: "Deep domain knowledge across multiple industry verticals and business contexts."
      }
    ]
  },

  experience: {
    title: "Professional Experience",
    subtitle: "Leading digital transformation and architecture initiatives across enterprise organizations for over two decades.",
    backgroundImage: "/images/experience/corporate-building.jpg", // Data center server room with blue lighting
    timeline: [
      {
        id: 1,
        title: "Lead Solutions Architect", 
        company: "Banking, Finance and Insurance",
        period: "Current",
        type: "current",
        location: "United Kingdom",
        description: "Leading architectural excellence for digital transformation initiatives across financial services sector.",
        achievements: [
          "Led team of architects for new digital portal solution achieving quality criteria and best value",
          "Chaired TDA governance forum reviewing solution designs for architecture compliance",
          "Crafted Microsoft Power Platform solutions for Business Dashboard delivery",
          "Led IAM solution analysis using Azure AD/Entra, B2C and External ID"
        ],
        technologies: ["Azure", "Power Platform", "React", "Microservices", "Dynamics 365", "Azure APIM"],
        impact: "Delivered 40% improvement in digital engagement and 25% cost reduction"
      },
      {
        id: 2,
        title: "Lead Integrations Architect",
        company: "Finance and Banking", 
        period: "Recent",
        type: "recent",
        location: "United Kingdom",
        description: "Spearheaded integration architecture for core banking systems with focus on performance optimization.",
        achievements: [
          "Led performance review of core banking services with 26-point recommendations",
          "Crafted integration patterns for Mainframe systems with external systems",
          "Designed REST Interfaces and Kafka-based messaging solutions"
        ],
        technologies: ["Mainframe", "REST APIs", "Apache Kafka", "Integration Patterns"],
        impact: "Improved system performance by 60% and reduced integration complexity"
      },
      {
        id: 3,
        title: "Lead Solutions Architect",
        company: "Specialty Insurance",
        period: "Recent", 
        type: "recent",
        location: "United Kingdom",
        description: "Managed architecture team for regulatory, risks and finance functions with focus on AI capabilities.",
        achievements: [
          "Managed architecture team for regulatory, risks and finance functions",
          "Conducted enterprise-wide Gen AI capabilities assessment and strategy development",  
          "Designed AWS hosted reserving transformation with integrated Gen AI models",
          "Architected Agentic AI systems for automated regulatory compliance workflows",
          "Implemented RAG (Retrieval-Augmented Generation) for intelligent document processing",
          "Crafted application performance management strategy with AI-driven monitoring"
        ],
        technologies: ["AWS", "Gen AI", "Agentic AI", "RAG Systems", "LLM Integration", "Document Management", "Performance Monitoring"],
        impact: "Enhanced regulatory compliance by 35% and accelerated reporting processes"
      },
      {
        id: 4,
        title: "Lead Solutions Architect",
        company: "Finance and Insurance",
        period: "Recent",
        type: "recent",
        location: "United Kingdom",
        description: "Architected cutting-edge SaaS based Digital platform with React and Azure Cognitive AI, replacing legacy systems.",
        achievements: [
          "Designed robust CIAM solution for Cyber Risk Insured customers using Azure AD B2C",
          "Led multi-vendor design reviews ensuring alignment of low-level designs with overall architecture",
          "Crafted innovative Asana-Jira integration boosting efficiency in managing new requests",
          "Technically assured end-to-end delivery of case management using D365 Customer service solution"
        ],
        technologies: ["React", "Azure Cognitive AI", "Azure AD B2C", "Dynamics 365", "Azure APIM"],
        impact: "Enhanced multilingual capabilities and drove significant cost savings"
      },
      {
        id: 5,
        title: "Solutions Architect",
        company: "Retail and eCommerce",
        period: "Previous",
        type: "previous",
        location: "United Kingdom",
        description: "Spearheaded design for cloud migration of 32 on-premises applications implementing serverless solutions.",
        achievements: [
          "Designed enterprise-wide Identity and Access Management solution using Azure AD",
          "Provided architectural assurance to vendor selection for Enterprise-wide IAM solutions",
          "Developed automated interface using Azure Logic Apps between HR systems and authentication platforms",
          "Engineered secure integration for Knowledge Management solution around Verint's SaaS platform"
        ],
        technologies: ["Azure AD", "Serverless", "Cloud-Native", "OAuth/SAML", "Azure Logic Apps"],
        impact: "Significant cost savings through data centre decommissioning and enhanced security"
      },
      {
        id: 6,
        title: "Solutions Architect",
        company: "Finance and Banking",
        period: "Previous",
        type: "previous",
        location: "United Kingdom",
        description: "Delivered high-level solution designs for PSD2 compliant environment with Microservices architecture.",
        achievements: [
          "Integrated Microservices, Mobile Push Notification and event-based architecture",
          "Conducted comprehensive review of Microservices-Mainframe interactions",
          "Reviewed Cloud migration strategies utilizing Landing Zones and hybrid cloud",
          "Mentored team members on emerging market trends including Domain Driven Design"
        ],
        technologies: ["Microservices", "AWS Serverless", "Event-Based Architecture", "PSD2", "Mobile Push"],
        impact: "Optimized Digital Banking customer onboarding experience and performance enhancement"
      },
      {
        id: 7,
        title: "Lead Solutions Architect",
        company: "Betting and Gaming",
        period: "Previous",
        type: "previous",
        location: "United Kingdom",
        description: "Led end-to-end architecture of Global digital platform integrating with Betting Engine for US market expansion.",
        achievements: [
          "Designed cutting-edge API based integration for global digital platform leveraging modern technologies",
          "Presented complex solution architecture to New Jersey regulatory body securing approval",
          "Drove architectural innovations through multi-state architecture enabling rapid expansion",
          "Proposed strategic API Gateway solution options incorporating GraphQL and REST APIs"
        ],
        technologies: ["Java Spring", "Node.js", "Kubernetes/EKS", "Apache Cassandra", "Kafka/Confluent"],
        impact: "Positioned company for substantial growth in competitive US markets"
      },
      {
        id: 8,
        title: "Solutions Architect",
        company: "Finance and Accounting SaaS",
        period: "Previous",
        type: "previous",
        location: "United Kingdom",
        description: "Architected global omni-channel headless commerce platform integrating Salesforce ecosystem.",
        achievements: [
          "Designed API First integration approach utilizing MuleSoft to revolutionize Order to cash processes",
          "Architected E2E global CMS solution with AWS-native hosted search application",
          "Led design for outsourced payment function ensuring strict compliance with financial regulations",
          "Drove Digital transformation achieving substantial cost reductions through legacy platform decommissioning"
        ],
        technologies: ["Salesforce", "CPQ Platform", "MuleSoft", "Sitecore", "AWS Beanstalk"],
        impact: "Revolutionized multi-channel customer experience and achieved significant cost reductions"
      }
    ]
  },

  projects: {
    title: "Featured Projects",
    subtitle: "Showcasing major architectural achievements and digital transformation initiatives that have driven business value and innovation.",
    backgroundImage: "/images/projects/innovation-tech.jpg", // Digital enterprise architecture visualization
    featured: [
      {
        id: 1,
        title: "Digital Portal Transformation",
        category: "Digital Platform",
        client: "Banking & Finance",
        duration: "18 months",
        description: "Led end-to-end architecture for digital portal using Micro Frontend architecture with React, headless CMS (Drupal), and Azure cloud integration.",
        challenge: "Legacy system modernization with zero-downtime migration and enhanced customer experience requirements.",
        solution: "Implemented micro-frontend architecture with event-driven integration patterns and cloud-native deployment.",
        technologies: ["React", "Azure", "Drupal", "Microservices", "API Management"],
        outcomes: [
          "Enhanced customer experience with 40% faster load times",
          "Improved operational efficiency by 30%", 
          "Cost optimization of 25% through cloud migration"
        ],
        image: "/images/projects/digital-portal.jpg",
        featured: true
      },
      {
        id: 2,
        title: "Enterprise CIAM Solution",
        category: "Identity & Access",
        client: "Insurance Sector",
        duration: "12 months",
        description: "Architected comprehensive Customer Identity and Access Management solution using Azure AD B2C with custom policies and dynamic templates.",
        challenge: "Complex multi-tenant identity management with regulatory compliance and seamless user experience.",
        solution: "Designed scalable CIAM architecture with custom policies, MFA integration, and regulatory compliance frameworks.",
        technologies: ["Azure AD B2C", "OAuth", "SAML", "API Gateway", "Dynamics 365"],
        outcomes: [
          "Enhanced security posture with 99.9% uptime",
          "Streamlined authentication reducing login time by 50%", 
          "Achieved full regulatory compliance across all jurisdictions"
        ],
        image: "/images/projects/ciam-security.jpg",
        featured: true
      },
      {
        id: 3,
        title: "Cloud Migration Initiative",
        category: "Cloud Transformation", 
        client: "Retail & eCommerce",
        duration: "24 months",
        description: "Spearheaded cloud migration for 32 on-premises applications implementing serverless and cloud-native solutions resulting in significant cost savings.",
        challenge: "Large-scale migration of legacy applications with minimal business disruption and cost optimization.",
        solution: "Phased migration approach with containerization, serverless adoption, and automated CI/CD pipelines.",
        technologies: ["AWS", "Serverless", "Kubernetes", "Docker", "Well-Architected Framework"],
        outcomes: [
          "60% cost reduction through optimized cloud resource usage",
          "Improved scalability supporting 10x traffic growth", 
          "Enhanced reliability with 99.99% availability"
        ],
        image: "/images/projects/cloud-migration.jpg",
        featured: true
      },
      {
        id: 4,
        title: "Global Gaming Platform",
        category: "Digital Platform",
        client: "Betting & Gaming",
        duration: "20 months",
        description: "Led end-to-end architecture of Global digital platform integrating with Betting Engine for US market expansion, presenting to regulatory bodies and securing approvals.",
        challenge: "Complex regulatory compliance across multiple US states with real-time betting engine integration and scalable architecture for rapid market expansion.",
        solution: "Designed cutting-edge API-based integration with multi-state architecture, GraphQL and REST APIs, and regulatory-compliant data handling frameworks.",
        technologies: ["Java Spring", "Node.js", "Kubernetes/EKS", "Apache Cassandra", "Kafka/Confluent", "GraphQL"],
        outcomes: [
          "Successfully secured regulatory approval from New Jersey gaming commission",
          "Enabled rapid multi-state expansion with reusable architecture components",
          "Positioned company for substantial growth in competitive US markets"
        ],
        image: "/images/projects/gaming-platform.jpg",
        featured: true
      },
      {
        id: 5,
        title: "Omni-Channel Commerce Platform",
        category: "E-Commerce Transformation",
        client: "Finance & Accounting SaaS",
        duration: "16 months", 
        description: "Architected global omni-channel headless commerce platform integrating Salesforce ecosystem with API-first approach, revolutionizing Order-to-Cash processes.",
        challenge: "Legacy system replacement with seamless multi-channel customer experience, complex payment integrations, and regulatory compliance for financial services.",
        solution: "Implemented headless commerce architecture with MuleSoft integration, AWS-native search capabilities, and compliant payment processing workflows.",
        technologies: ["Salesforce", "CPQ Platform", "MuleSoft", "Sitecore", "AWS Beanstalk", "Headless CMS"],
        outcomes: [
          "Revolutionized multi-channel customer experience with unified platform",
          "Achieved significant cost reductions through legacy decommissioning",
          "Enhanced order processing efficiency by 45% across all channels"
        ],
        image: "/images/projects/commerce-platform.jpg",
        featured: true
      },
      {
        id: 6,
        title: "Enterprise Gen AI & Agentic Systems Platform",
        category: "AI Innovation",
        client: "Financial Services",
        duration: "14 months",
        description: "Architected comprehensive enterprise Gen AI platform with multi-agent orchestration, RAG systems, and intelligent automation for regulatory compliance and customer service transformation.",
        challenge: "Building scalable Gen AI infrastructure with regulatory compliance, data governance, and multi-agent coordination for complex financial services workflows.",
        solution: "Designed cloud-native Gen AI architecture with RAG systems, agentic AI workflows, LLM orchestration, and enterprise-grade security for intelligent document processing and automated compliance.",
        technologies: ["Azure OpenAI", "LangChain", "RAG Systems", "Agentic AI", "Vector Databases", "Python", "Kubernetes", "Azure Cognitive Services"],
        outcomes: [
          "Implemented intelligent document processing reducing manual work by 70%",
          "Deployed multi-agent systems for automated regulatory reporting",
          "Enhanced customer service capabilities with Gen AI-powered chatbots and intelligent routing"
        ],
        image: "/images/projects/digital-portal.jpg",
        featured: true
      }
    ]
  },

  testimonials: [
    {
      id: 1,
      role: "Chief Technology Officer",
      company: "Global Financial Services",
      content: "The strategic vision and technical expertise were instrumental in our digital transformation. The ability to translate complex business requirements into scalable architecture solutions is exceptional.",
      rating: 5,
      image: "/images/testimonials/testimonial-1.jpg",
      project: "Digital Platform Modernization",
      industry: "Financial Services",
      projectScale: "Enterprise-wide transformation"
    },
    {
      id: 2,
      role: "Head of Technology",
      company: "Insurance Innovation Ltd",
      content: "Working on our CIAM implementation was transformative. The deep understanding of security frameworks and regulatory compliance delivered outstanding results.",
      rating: 5,
      image: "/images/testimonials/testimonial-2.jpg",
      project: "Identity Management Solution",
      industry: "Insurance",
      projectScale: "Multi-system integration"
    },
    {
      id: 3,
      role: "Digital Transformation Director", 
      company: "Retail Modernization Group",
      content: "The leadership in our cloud migration project was exemplary. The governance approach and stakeholder management skills ensured smooth delivery across all workstreams.",
      rating: 5,
      image: "/images/testimonials/testimonial-3.jpg",
      project: "Cloud Migration Initiative",
      industry: "Retail & eCommerce",
      projectScale: "32 applications migrated"
    },
    {
      id: 4,
      role: "VP of Engineering",
      company: "Banking Consortium",
      content: "The architectural guidance during our modernization initiative was invaluable. Complex legacy systems were transformed into scalable, cloud-native solutions with minimal business disruption.",
      rating: 5,
      image: "/images/testimonials/testimonial-4.jpg",
      project: "Core Banking Modernization",
      industry: "Banking",
      projectScale: "Mission-critical systems"
    },
    {
      id: 5,
      role: "Enterprise Architect",
      company: "Public Sector Organization",
      content: "Outstanding expertise in enterprise architecture governance. The framework and standards implemented have significantly improved our delivery quality and consistency across multiple projects.",
      rating: 5,
      image: "/images/testimonials/testimonial-5.jpg",
      project: "Architecture Governance Framework",
      industry: "Public Sector",
      projectScale: "Organization-wide standards"
    },
    {
      id: 6,
      role: "Chief Information Officer",
      company: "Healthcare Network",
      content: "The strategic approach to our digital transformation was comprehensive and well-executed. Delivered on time, within budget, and exceeded our performance expectations.",
      rating: 5,
      image: "/images/testimonials/testimonial-6.jpg",
      project: "Healthcare Platform Integration",
      industry: "Healthcare",
      projectScale: "Multi-location deployment"
    }
  ],

  contact: {
    email: "chkamalsingh@yahoo.com",
    phone: "07908 521 588",
    location: "Amersham, United Kingdom", // Removed house name and street name as requested
    linkedin: "https://linkedin.com/in/kamalsingh-architect",
    availability: "Available for consulting and architecture leadership roles",
    backgroundImage: "/images/contact/contact-bg.jpg",
    workingHours: "Monday - Friday, 9:00 AM - 6:00 PM GMT",
    responseTime: "Within 24 hours"
  },

  certifications: [
    "AWS Certified Solutions Architect – Associate",
    "Google Cloud – Certified Professional Cloud Architect", 
    "Microsoft Certified-Azure Solutions Architect Expert",
    "TOGAF Enterprise Architecture Level 2 Certified",
    "IASA CITA-F Core Architecture Certified"
  ]
};