import React, { useState, useEffect, useRef } from 'react';
import { Search, X, Filter, Zap, ArrowRight, Clock, Tag } from 'lucide-react';
import { searchService } from '../services/searchService';
import { analyticsService } from '../services/analyticsService';

const SearchComponent = ({ isOpen, onClose, onNavigate }) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState(null);
  const [isSearching, setIsSearching] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const [filters, setFilters] = useState({
    type: 'all',
    category: 'all'
  });
  const [recentSearches, setRecentSearches] = useState([]);
  
  const inputRef = useRef(null);
  const resultsRef = useRef(null);

  // Focus input when opened
  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  // Load recent searches from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('portfolio_recent_searches');
    if (saved) {
      try {
        setRecentSearches(JSON.parse(saved));
      } catch (e) {
        console.error('Failed to load recent searches:', e);
      }
    }
  }, []);

  // Perform search with debouncing
  useEffect(() => {
    if (!query.trim()) {
      setResults(null);
      return;
    }

    setIsSearching(true);
    const timeoutId = setTimeout(() => {
      performSearch(query);
    }, 300); // 300ms debounce

    return () => clearTimeout(timeoutId);
  }, [query, filters]);

  const performSearch = async (searchQuery) => {
    try {
      const searchOptions = {
        type: filters.type,
        limit: 20,
        includeHighlights: true
      };

      const searchResults = searchService.advancedSearch(searchQuery, {
        ...filters,
        ...searchOptions
      });

      setResults(searchResults);
      setSelectedIndex(-1);

      // Track search
      analyticsService.trackEvent('search', 'perform_search', {
        query: searchQuery,
        resultsCount: searchResults.total,
        filters: filters
      });

    } catch (error) {
      console.error('Search error:', error);
      analyticsService.trackError(error, { context: 'search' });
    } finally {
      setIsSearching(false);
    }
  };

  const handleSearch = (searchQuery) => {
    if (!searchQuery.trim()) return;

    // Save to recent searches
    const newRecentSearches = [
      searchQuery,
      ...recentSearches.filter(s => s !== searchQuery)
    ].slice(0, 10);

    setRecentSearches(newRecentSearches);
    localStorage.setItem('portfolio_recent_searches', JSON.stringify(newRecentSearches));

    setQuery(searchQuery);
  };

  const handleResultClick = (result) => {
    analyticsService.trackEvent('search', 'result_click', {
      query,
      resultType: result.type,
      resultTitle: result.title,
      position: results.results.indexOf(result)
    });

    if (onNavigate) {
      onNavigate(result.url);
    }
    onClose();
  };

  const handleKeyDown = (e) => {
    if (!results || results.results.length === 0) return;

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setSelectedIndex(prev => 
          prev < results.results.length - 1 ? prev + 1 : prev
        );
        break;
      case 'ArrowUp':
        e.preventDefault();
        setSelectedIndex(prev => prev > 0 ? prev - 1 : -1);
        break;
      case 'Enter':
        e.preventDefault();
        if (selectedIndex >= 0) {
          handleResultClick(results.results[selectedIndex]);
        }
        break;
      case 'Escape':
        onClose();
        break;
      default:
        break;
    }
  };

  const clearSearch = () => {
    setQuery('');
    setResults(null);
    setSelectedIndex(-1);
    inputRef.current?.focus();
  };

  const getResultIcon = (type) => {
    switch (type) {
      case 'project':
        return '🚀';
      case 'skill':
        return '⚡';
      case 'certification':
        return '🏆';
      case 'experience':
        return '💼';
      default:
        return '📄';
    }
  };

  const getResultTypeLabel = (type) => {
    switch (type) {
      case 'project':
        return 'Project';
      case 'skill':
        return 'Skill';
      case 'certification':
        return 'Certification';
      case 'experience':
        return 'Experience';
      default:
        return 'Content';
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-start justify-center pt-20">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl mx-4 max-h-[80vh] overflow-hidden">
        {/* Search Header */}
        <div className="p-6 border-b border-slate-200">
          <div className="flex items-center space-x-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400" size={20} />
              <input
                ref={inputRef}
                type="text"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Search projects, skills, experience..."
                className="w-full pl-12 pr-12 py-3 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:outline-none text-lg"
              />
              {query && (
                <button
                  onClick={clearSearch}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-slate-600"
                >
                  <X size={20} />
                </button>
              )}
            </div>
            <button
              onClick={onClose}
              className="p-2 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100"
            >
              <X size={24} />
            </button>
          </div>

          {/* Filters */}
          <div className="flex items-center space-x-4 mt-4">
            <div className="flex items-center space-x-2">
              <Filter className="text-slate-500" size={16} />
              <span className="text-sm text-slate-600">Filter by:</span>
            </div>
            <select
              value={filters.type}
              onChange={(e) => setFilters(prev => ({ ...prev, type: e.target.value }))}
              className="px-3 py-1 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-indigo-500 focus:outline-none"
            >
              <option value="all">All Types</option>
              <option value="project">Projects</option>
              <option value="skill">Skills</option>
              <option value="certification">Certifications</option>
              <option value="experience">Experience</option>
            </select>
          </div>
        </div>

        {/* Search Results */}
        <div className="overflow-y-auto max-h-96" ref={resultsRef}>
          {isSearching && (
            <div className="p-6 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto mb-4"></div>
              <p className="text-slate-600">Searching...</p>
            </div>
          )}

          {!query && !isSearching && (
            <div className="p-6">
              {/* Popular Searches */}
              <div className="mb-6">
                <h3 className="text-sm font-semibold text-slate-700 mb-3 flex items-center">
                  <Zap className="mr-2" size={16} />
                  Popular Searches
                </h3>
                <div className="flex flex-wrap gap-2">
                  {searchService.getPopularSearches().map((search) => (
                    <button
                      key={search}
                      onClick={() => handleSearch(search)}
                      className="px-3 py-1 bg-slate-100 text-slate-700 rounded-full text-sm hover:bg-indigo-100 hover:text-indigo-700 transition-colors"
                    >
                      {search}
                    </button>
                  ))}
                </div>
              </div>

              {/* Recent Searches */}
              {recentSearches.length > 0 && (
                <div>
                  <h3 className="text-sm font-semibold text-slate-700 mb-3 flex items-center">
                    <Clock className="mr-2" size={16} />
                    Recent Searches
                  </h3>
                  <div className="space-y-2">
                    {recentSearches.slice(0, 5).map((search, index) => (
                      <button
                        key={index}
                        onClick={() => handleSearch(search)}
                        className="w-full text-left px-3 py-2 rounded-lg hover:bg-slate-100 text-slate-700 flex items-center justify-between group"
                      >
                        <span>{search}</span>
                        <ArrowRight className="opacity-0 group-hover:opacity-100 transition-opacity" size={16} />
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {results && !isSearching && (
            <div className="p-6">
              {results.total > 0 ? (
                <>
                  <div className="mb-4">
                    <p className="text-sm text-slate-600">
                      Found {results.total} result{results.total !== 1 ? 's' : ''} for "{query}"
                    </p>
                  </div>

                  <div className="space-y-3">
                    {results.results.map((result, index) => (
                      <button
                        key={result.id}
                        onClick={() => handleResultClick(result)}
                        className={`w-full text-left p-4 rounded-xl border transition-all ${
                          selectedIndex === index
                            ? 'border-indigo-500 bg-indigo-50'
                            : 'border-slate-200 hover:border-slate-300 hover:bg-slate-50'
                        }`}
                      >
                        <div className="flex items-start space-x-3">
                          <div className="text-2xl">{getResultIcon(result.type)}</div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center space-x-2 mb-1">
                              <h4 
                                className="font-semibold text-slate-800 truncate"
                                dangerouslySetInnerHTML={{ __html: result.highlights?.title || result.title }}
                              />
                              <span className="px-2 py-1 bg-slate-100 text-slate-600 rounded-full text-xs font-medium">
                                {getResultTypeLabel(result.type)}
                              </span>
                            </div>
                            
                            {result.category && (
                              <div className="flex items-center space-x-1 mb-2">
                                <Tag className="text-slate-400" size={14} />
                                <span className="text-sm text-slate-600">{result.category}</span>
                              </div>
                            )}

                            {result.highlights?.description && (
                              <p 
                                className="text-sm text-slate-600 line-clamp-2"
                                dangerouslySetInnerHTML={{ __html: result.highlights.description }}
                              />
                            )}

                            {result.data.technologies && (
                              <div className="mt-2 flex flex-wrap gap-1">
                                {result.data.technologies.slice(0, 3).map((tech, techIndex) => (
                                  <span key={techIndex} className="px-2 py-1 bg-indigo-100 text-indigo-700 rounded text-xs">
                                    {tech}
                                  </span>
                                ))}
                                {result.data.technologies.length > 3 && (
                                  <span className="px-2 py-1 bg-slate-100 text-slate-600 rounded text-xs">
                                    +{result.data.technologies.length - 3} more
                                  </span>
                                )}
                              </div>
                            )}
                          </div>
                          <ArrowRight className="text-slate-400 flex-shrink-0" size={16} />
                        </div>
                      </button>
                    ))}
                  </div>
                </>
              ) : (
                <div className="text-center py-8">
                  <div className="text-4xl mb-4">🔍</div>
                  <h3 className="text-lg font-semibold text-slate-800 mb-2">No results found</h3>
                  <p className="text-slate-600 mb-4">
                    Try different keywords or check out these suggestions:
                  </p>
                  {results.suggestions.length > 0 && (
                    <div className="flex flex-wrap gap-2 justify-center">
                      {results.suggestions.map((suggestion) => (
                        <button
                          key={suggestion}
                          onClick={() => handleSearch(suggestion)}
                          className="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full text-sm hover:bg-indigo-200 transition-colors"
                        >
                          {suggestion}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Search Tips */}
        <div className="px-6 py-3 bg-slate-50 border-t border-slate-200">
          <p className="text-xs text-slate-500 flex items-center justify-center space-x-4">
            <span>Press <kbd className="px-1 py-0.5 bg-white border border-slate-300 rounded text-xs">↵</kbd> to select</span>
            <span>Press <kbd className="px-1 py-0.5 bg-white border border-slate-300 rounded text-xs">↑↓</kbd> to navigate</span>
            <span>Press <kbd className="px-1 py-0.5 bg-white border border-slate-300 rounded text-xs">Esc</kbd> to close</span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default SearchComponent;