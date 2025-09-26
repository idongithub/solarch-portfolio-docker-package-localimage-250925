// MongoDB Database Initialization Script for Kamal Singh Portfolio
// Enhanced version for local installation
// Run this script with: mongosh --file updated_init_database.js

print("================================================");
print("Kamal Singh Portfolio - Enhanced Database Setup");
print("================================================");

// Switch to portfolio database
db = db.getSiblingDB('portfolio_db');
print("✅ Connected to portfolio_db database");

// Drop existing collections for clean setup (optional)
var shouldReset = false; // Set to true if you want to reset all data

if (shouldReset) {
    print("🔄 Resetting database (dropping existing collections)...");
    db.status_checks.drop();
    db.contacts.drop();
    db.portfolio_content.drop();
    db.users.drop();
    db.projects.drop();
    db.testimonials.drop();
    print("✅ Existing collections dropped");
}

// Create collections with validation
print("📁 Creating collections with schema validation...");

// Status checks collection
db.createCollection("status_checks", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["id", "client_name", "timestamp"],
            properties: {
                id: { bsonType: "string" },
                client_name: { bsonType: "string" },
                timestamp: { bsonType: "date" },
                message: { bsonType: "string" },
                setup_version: { bsonType: "string" }
            }
        }
    }
});
print("✅ Created status_checks collection with validation");

// Contacts collection with comprehensive fields
db.createCollection("contacts", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["id", "name", "email", "timestamp"],
            properties: {
                id: { bsonType: "string" },
                name: { bsonType: "string", minLength: 2 },
                email: { bsonType: "string", pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$" },
                company: { bsonType: "string" },
                role: { bsonType: "string" },
                projectType: { bsonType: "string" },
                budget: { bsonType: "string" },
                timeline: { bsonType: "string" },
                message: { bsonType: "string" },
                timestamp: { bsonType: "date" },
                status: { enum: ["new", "contacted", "in_progress", "closed"] },
                priority: { enum: ["low", "normal", "high", "urgent"] }
            }
        }
    }
});
print("✅ Created contacts collection with validation");

// Portfolio content collection
db.createCollection("portfolio_content");
print("✅ Created portfolio_content collection");

// Users collection for future admin functionality
db.createCollection("users");
print("✅ Created users collection");

// Projects collection for dynamic project management
db.createCollection("projects");
print("✅ Created projects collection");

// Testimonials collection
db.createCollection("testimonials");
print("✅ Created testimonials collection");

// Insert comprehensive initial data
print("📊 Inserting initial data and samples...");

// Initial status check
db.status_checks.insertOne({
    id: "enhanced-setup-" + new Date().getTime(),
    client_name: "enhanced_database_initialization",
    timestamp: new Date(),
    message: "Enhanced database initialized successfully with validation",
    setup_version: "2.0.0",
    installation_type: "local_complete"
});
print("✅ Inserted enhanced status check document");

// Sample contact submissions for testing
var sampleContacts = [
    {
        id: "sample-contact-1",
        name: "John Smith",
        email: "john.smith@techcorp.com",
        company: "TechCorp Solutions",
        role: "CTO",
        projectType: "Digital Transformation",
        budget: "£100k - £250k",
        timeline: "6-12 months",
        message: "We're looking for an experienced IT architect to lead our digital transformation initiative. We need someone with expertise in cloud migration and enterprise architecture.",
        timestamp: new Date(Date.now() - 24*60*60*1000), // 1 day ago
        status: "new",
        priority: "high"
    },
    {
        id: "sample-contact-2", 
        name: "Sarah Johnson",
        email: "s.johnson@innovatebank.co.uk",
        company: "Innovate Bank",
        role: "Head of Technology",
        projectType: "CIAM/IAM Implementation",
        budget: "£50k - £100k",
        timeline: "3-6 months",
        message: "Looking for expertise in customer identity and access management solutions. We need to implement a robust CIAM solution for our digital banking platform.",
        timestamp: new Date(Date.now() - 48*60*60*1000), // 2 days ago
        status: "contacted", 
        priority: "normal"
    },
    {
        id: "sample-contact-3",
        name: "Michael Brown",
        email: "m.brown@cloudretail.com", 
        company: "Cloud Retail Ltd",
        role: "IT Director",
        projectType: "Cloud Migration Strategy",
        budget: "£25k - £50k",
        timeline: "1-3 months",
        message: "We need strategic guidance for migrating our legacy retail systems to cloud infrastructure. Looking for expertise in AWS/Azure migration strategies.",
        timestamp: new Date(Date.now() - 72*60*60*1000), // 3 days ago
        status: "in_progress",
        priority: "normal"
    }
];

db.contacts.insertMany(sampleContacts);
print("✅ Inserted " + sampleContacts.length + " sample contact documents");

// Portfolio metadata with comprehensive information
db.portfolio_content.insertOne({
    id: "portfolio-metadata-v2",
    name: "Kamal Singh",
    title: "IT Portfolio Architect",
    tagline: "Transforming Enterprise Through Strategic Architecture & Digital Innovation",
    summary: "26+ years of expertise in E2E Architecture and Digital Transformation, driving business growth through cost optimization, system integration, and cloud-native solutions.",
    detailed_bio: "An experienced business-focused Architecture Leader with extensive expertise spanning enterprise architecture, digital transformation, and cloud technologies across multiple industry verticals including Banking, Insurance, Retail, and Public Sector.",
    location: "Amersham, United Kingdom",
    email: "chkamalsingh@yahoo.com",
    phone: "07908 521 588",
    linkedin: "https://linkedin.com/in/kamalsingh-architect",
    availability: "Available for consulting and architecture leadership roles",
    working_hours: "Monday - Friday, 9:00 AM - 6:00 PM GMT",
    response_time: "Within 24 hours",
    years_experience: 26,
    projects_completed: "50+",
    industries_served: "10+",
    certifications: [
        "AWS Certified Solutions Architect – Associate",
        "Google Cloud – Certified Professional Cloud Architect",
        "Microsoft Certified-Azure Solutions Architect Expert", 
        "TOGAF Enterprise Architecture Level 2 Certified",
        "IASA CITA-F Core Architecture Certified"
    ],
    core_competencies: [
        "Enterprise Architecture",
        "Digital Transformation", 
        "Cloud Technologies (AWS, Azure, GCP)",
        "Microservices Architecture",
        "CIAM/IAM Solutions",
        "API-First Design",
        "DevOps & CI/CD",
        "Security Architecture"
    ],
    created_at: new Date(),
    updated_at: new Date(),
    version: "2.0.0"
});
print("✅ Inserted comprehensive portfolio metadata");

// Sample projects data matching the current portfolio
var sampleProjects = [
    {
        id: "project-digital-portal",
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
        status: "completed",
        featured: true,
        created_at: new Date(),
        updated_at: new Date()
    },
    {
        id: "project-ciam-solution",
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
        status: "completed",
        featured: true,
        created_at: new Date(),
        updated_at: new Date()
    }
];

db.projects.insertMany(sampleProjects);
print("✅ Inserted " + sampleProjects.length + " sample project documents");

// Sample testimonials
var sampleTestimonials = [
    {
        id: "testimonial-1",
        role: "Chief Technology Officer",
        company: "Global Financial Services",
        content: "The strategic vision and technical expertise were instrumental in our digital transformation. The ability to translate complex business requirements into scalable architecture solutions is exceptional.",
        rating: 5,
        project: "Digital Platform Modernization",
        industry: "Financial Services",
        project_scale: "Enterprise-wide transformation",
        created_at: new Date(),
        featured: true
    },
    {
        id: "testimonial-2",
        role: "Head of Technology",
        company: "Insurance Innovation Ltd",
        content: "Working on our CIAM implementation was transformative. The deep understanding of security frameworks and regulatory compliance delivered outstanding results.",
        rating: 5,
        project: "Identity Management Solution",
        industry: "Insurance",
        project_scale: "Multi-system integration",
        created_at: new Date(),
        featured: true
    }
];

db.testimonials.insertMany(sampleTestimonials);
print("✅ Inserted " + sampleTestimonials.length + " sample testimonial documents");

// Create comprehensive indexes for performance
print("📈 Creating performance indexes...");

// Indexes for status_checks collection
db.status_checks.createIndex({ "timestamp": -1 });
db.status_checks.createIndex({ "client_name": 1 });
db.status_checks.createIndex({ "id": 1 }, { unique: true });
print("✅ Created indexes for status_checks collection");

// Indexes for contacts collection
db.contacts.createIndex({ "timestamp": -1 });
db.contacts.createIndex({ "email": 1 });
db.contacts.createIndex({ "status": 1 });
db.contacts.createIndex({ "priority": 1 });
db.contacts.createIndex({ "company": 1 });
db.contacts.createIndex({ "id": 1 }, { unique: true });
print("✅ Created indexes for contacts collection");

// Indexes for portfolio_content collection
db.portfolio_content.createIndex({ "updated_at": -1 });
db.portfolio_content.createIndex({ "id": 1 }, { unique: true });
print("✅ Created indexes for portfolio_content collection");

// Indexes for projects collection
db.projects.createIndex({ "created_at": -1 });
db.projects.createIndex({ "category": 1 });
db.projects.createIndex({ "status": 1 });
db.projects.createIndex({ "featured": 1 });
db.projects.createIndex({ "id": 1 }, { unique: true });
print("✅ Created indexes for projects collection");

// Indexes for testimonials collection
db.testimonials.createIndex({ "created_at": -1 });
db.testimonials.createIndex({ "industry": 1 });
db.testimonials.createIndex({ "rating": -1 });
db.testimonials.createIndex({ "featured": 1 });
db.testimonials.createIndex({ "id": 1 }, { unique: true });
print("✅ Created indexes for testimonials collection");

// Create database user for application (optional security enhancement)
// Uncomment the following lines if you want to create a dedicated database user
/*
db.createUser({
    user: "portfolio_app",
    pwd: "secure_password_change_this",
    roles: [
        { role: "readWrite", db: "portfolio_db" }
    ]
});
print("✅ Created database user for application");
*/

// Verify the complete setup
print("🔍 Verifying database setup...");

// Count documents in each collection
var collections = ["status_checks", "contacts", "portfolio_content", "projects", "testimonials"];
collections.forEach(function(collectionName) {
    var count = db[collectionName].countDocuments();
    print("  - " + collectionName + ": " + count + " documents");
});

// Display sample documents from each collection
print("📋 Sample documents from each collection:");

print("\n📊 Status Check Sample:");
printjson(db.status_checks.findOne());

print("\n📞 Contact Sample:");
printjson(db.contacts.findOne());

print("\n👤 Portfolio Metadata Sample:");
printjson(db.portfolio_content.findOne());

print("\n🚀 Project Sample:");
printjson(db.projects.findOne());

print("\n💬 Testimonial Sample:");
printjson(db.testimonials.findOne());

// Database statistics
print("\n📈 Database Statistics:");
var stats = db.stats();
print("  - Database: " + stats.db);
print("  - Collections: " + stats.collections);
print("  - Objects: " + stats.objects);
print("  - Data Size: " + Math.round(stats.dataSize / 1024) + " KB");
print("  - Index Size: " + Math.round(stats.indexSize / 1024) + " KB");

// List all indexes
print("\n📋 Created Indexes:");
collections.forEach(function(collectionName) {
    var indexes = db[collectionName].getIndexes();
    print("  " + collectionName + ":");
    indexes.forEach(function(index) {
        print("    - " + JSON.stringify(index.key));
    });
});

print("================================================");
print("✅ Enhanced Database Initialization Completed!");
print("================================================");

print("\n🎯 Next Steps:");
print("1. Backend server can now connect to: mongodb://localhost:27017/portfolio_db");
print("2. Start the backend: cd backend && source venv/bin/activate && uvicorn server:app --reload");
print("3. Start the frontend: cd frontend && yarn start");
print("4. Access the portfolio at: http://localhost:3000");
print("5. Check API documentation at: http://localhost:8001/docs");
print("6. View contact submissions in the database");

print("\n💡 Database Features:");
print("• Schema validation for data integrity");
print("• Performance indexes for fast queries");
print("• Sample data for testing and development");
print("• Comprehensive collections for full functionality");
print("• Ready for production use with proper security");

print("\n🔐 Security Recommendations:");
print("• Enable MongoDB authentication in production");
print("• Use environment variables for database credentials");
print("• Implement proper access control and user roles");
print("• Enable SSL/TLS for database connections");
print("• Regular backup and monitoring setup");

print("\nDatabase is fully ready for the Kamal Singh Portfolio application! 🚀");