// Search Service for portfolio content search functionality
// Phase 2 Enhancement: Search across projects, skills, and experience

import { mockData } from '../mock';

class SearchService {
  constructor() {
    this.searchIndex = this.buildSearchIndex();
  }

  buildSearchIndex() {
    const index = {
      projects: this.indexProjects(),
      skills: this.indexSkills(),
      experience: this.indexExperience(),
      all: []
    };

    // Build combined index
    index.all = [
      ...index.projects,
      ...index.skills, 
      ...index.experience
    ];

    return index;
  }

  indexProjects() {
    return mockData.projects.map(project => ({
      id: project.id,
      type: 'project',
      title: project.title,
      category: project.category,
      client: project.client,
      description: project.description,
      challenge: project.challenge,
      solution: project.solution,
      technologies: project.technologies.join(' '),
      outcomes: project.outcomes.join(' '),
      searchText: `${project.title} ${project.category} ${project.client} ${project.description} ${project.challenge} ${project.solution} ${project.technologies.join(' ')} ${project.outcomes.join(' ')}`.toLowerCase(),
      url: `/projects#${project.id}`,
      data: project
    }));
  }

  indexSkills() {
    const skills = [];
    
    // Index technical skills
    mockData.skills.technical.forEach(category => {
      category.skills.forEach(skill => {
        skills.push({
          id: `skill-${skill.replace(/\s+/g, '-').toLowerCase()}`,
          type: 'skill',
          title: skill,
          category: category.category,
          level: 'Technical',
          searchText: `${skill} ${category.category} technical`.toLowerCase(),
          url: `/skills#${category.category.replace(/\s+/g, '-').toLowerCase()}`,
          data: { skill, category: category.category, type: 'technical' }
        });
      });
    });

    // Index certifications
    if (mockData.skills.certifications) {
      mockData.skills.certifications.forEach(cert => {
        skills.push({
          id: `cert-${cert.name.replace(/\s+/g, '-').toLowerCase()}`,
          type: 'certification',
          title: cert.name,
          category: 'Certifications',
          level: cert.level || 'Professional',
          searchText: `${cert.name} ${cert.issuer} certification`.toLowerCase(),
          url: `/skills#certifications`,
          data: cert
        });
      });
    }

    return skills;
  }

  indexExperience() {
    return mockData.experience.map(exp => ({
      id: `exp-${exp.company.replace(/\s+/g, '-').toLowerCase()}`,
      type: 'experience',
      title: `${exp.role} at ${exp.company}`,
      category: 'Experience',
      company: exp.company,
      role: exp.role,
      period: exp.period,
      description: exp.description,
      achievements: exp.achievements?.join(' ') || '',
      technologies: exp.technologies?.join(' ') || '',
      searchText: `${exp.role} ${exp.company} ${exp.description} ${exp.achievements?.join(' ') || ''} ${exp.technologies?.join(' ') || ''}`.toLowerCase(),
      url: `/experience#${exp.company.replace(/\s+/g, '-').toLowerCase()}`,
      data: exp
    }));
  }

  search(query, options = {}) {
    if (!query || query.length < 2) {
      return {
        query,
        results: [],
        total: 0,
        categories: {},
        suggestions: this.getPopularSearches()
      };
    }

    const {
      type = 'all',
      limit = 10,
      includeHighlights = true,
      minScore = 0.1
    } = options;

    const searchTerms = query.toLowerCase().split(' ').filter(term => term.length > 1);
    const searchData = type === 'all' ? this.searchIndex.all : this.searchIndex[type] || [];

    // Score and rank results
    const scoredResults = searchData.map(item => {
      const score = this.calculateRelevanceScore(item, searchTerms);
      return { ...item, score };
    })
    .filter(item => item.score >= minScore)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);

    // Add highlights if requested
    if (includeHighlights) {
      scoredResults.forEach(result => {
        result.highlights = this.generateHighlights(result, searchTerms);
      });
    }

    // Group by categories
    const categories = scoredResults.reduce((acc, result) => {
      const category = result.type;
      if (!acc[category]) {
        acc[category] = [];
      }
      acc[category].push(result);
      return acc;
    }, {});

    return {
      query,
      results: scoredResults,
      total: scoredResults.length,
      categories,
      suggestions: scoredResults.length === 0 ? this.getSuggestions(query) : []
    };
  }

  calculateRelevanceScore(item, searchTerms) {
    let score = 0;
    const text = item.searchText;

    searchTerms.forEach(term => {
      // Exact title match (highest weight)
      if (item.title.toLowerCase().includes(term)) {
        score += 10;
      }

      // Category match (high weight)
      if (item.category.toLowerCase().includes(term)) {
        score += 8;
      }

      // Exact phrase match (high weight)
      if (text.includes(term)) {
        score += 5;
      }

      // Word boundary match (medium weight)
      const wordBoundaryRegex = new RegExp(`\\b${term}`, 'i');
      if (wordBoundaryRegex.test(text)) {
        score += 3;
      }

      // Partial match (low weight)
      const partialMatches = text.split(term).length - 1;
      score += partialMatches * 1;
    });

    // Boost score based on item type priority
    const typePriority = {
      'project': 1.2,
      'skill': 1.1,
      'certification': 1.1,
      'experience': 1.0
    };

    score *= (typePriority[item.type] || 1.0);

    // Normalize score (0-1 range)
    return Math.min(score / (searchTerms.length * 10), 1.0);
  }

  generateHighlights(item, searchTerms) {
    const highlights = {};
    
    // Highlight title
    highlights.title = this.highlightText(item.title, searchTerms);
    
    // Highlight description if available
    if (item.description) {
      highlights.description = this.highlightText(
        item.description.substring(0, 200) + (item.description.length > 200 ? '...' : ''),
        searchTerms
      );
    }

    return highlights;
  }

  highlightText(text, searchTerms) {
    let highlightedText = text;
    
    searchTerms.forEach(term => {
      const regex = new RegExp(`(${term})`, 'gi');
      highlightedText = highlightedText.replace(regex, '<mark>$1</mark>');
    });

    return highlightedText;
  }

  getSuggestions(query) {
    // Simple suggestion logic - find partial matches
    const suggestions = [];
    const queryLower = query.toLowerCase();

    // Get suggestions from titles
    this.searchIndex.all.forEach(item => {
      if (item.title.toLowerCase().includes(queryLower) && !suggestions.includes(item.title)) {
        suggestions.push(item.title);
      }
    });

    // Get suggestions from categories
    const categories = [...new Set(this.searchIndex.all.map(item => item.category))];
    categories.forEach(category => {
      if (category.toLowerCase().includes(queryLower) && !suggestions.includes(category)) {
        suggestions.push(category);
      }
    });

    return suggestions.slice(0, 5);
  }

  getPopularSearches() {
    return [
      'Enterprise Architecture',
      'Digital Transformation',
      'Cloud Migration',
      'Gen AI',
      'Microservices',
      'API Design',
      'Security Architecture',
      'DevOps',
      'CIAM',
      'Architecture Governance'
    ];
  }

  getSearchStats() {
    return {
      totalProjects: this.searchIndex.projects.length,
      totalSkills: this.searchIndex.skills.length,
      totalExperience: this.searchIndex.experience.length,
      totalItems: this.searchIndex.all.length,
      categories: [...new Set(this.searchIndex.all.map(item => item.type))]
    };
  }

  // Advanced search with filters
  advancedSearch(query, filters = {}) {
    const baseResults = this.search(query, { limit: 100 });
    
    let filteredResults = baseResults.results;

    // Apply category filter
    if (filters.category && filters.category !== 'all') {
      filteredResults = filteredResults.filter(item => 
        item.category.toLowerCase() === filters.category.toLowerCase()
      );
    }

    // Apply type filter
    if (filters.type && filters.type !== 'all') {
      filteredResults = filteredResults.filter(item => item.type === filters.type);
    }

    // Apply date range filter for experience
    if (filters.dateRange && filters.type === 'experience') {
      filteredResults = filteredResults.filter(item => {
        // Simple date range filtering - could be enhanced
        return true; // Placeholder
      });
    }

    // Apply technology filter
    if (filters.technology) {
      filteredResults = filteredResults.filter(item => 
        item.technologies?.toLowerCase().includes(filters.technology.toLowerCase()) ||
        item.searchText.includes(filters.technology.toLowerCase())
      );
    }

    return {
      ...baseResults,
      results: filteredResults.slice(0, filters.limit || 10),
      total: filteredResults.length,
      filters: filters
    };
  }
}

// Create singleton instance
export const searchService = new SearchService();
export default searchService;