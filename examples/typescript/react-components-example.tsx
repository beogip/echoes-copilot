// ECHO: diagnostic
// React components are re-rendering unnecessarily causing performance issues
// Profiler shows excessive renders in ProductList component

import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { Product, FilterOptions } from '../types';

interface ProductListProps {
  products: Product[];
  filters: FilterOptions;
  onProductSelect: (product: Product) => void;
}

const ProductList: React.FC<ProductListProps> = ({ 
  products, 
  filters, 
  onProductSelect 
}) => {
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');
  const [searchTerm, setSearchTerm] = useState('');

  // ECHO: optimization
  // This filtering logic runs on every render - needs memoization
  const filteredProducts = useMemo(() => {
    return products
      .filter(product => {
        const matchesSearch = product.name
          .toLowerCase()
          .includes(searchTerm.toLowerCase());
        
        const matchesCategory = !filters.category || 
          product.category === filters.category;
        
        const matchesPrice = product.price >= (filters.minPrice || 0) && 
          product.price <= (filters.maxPrice || Infinity);
        
        return matchesSearch && matchesCategory && matchesPrice;
      })
      .sort((a, b) => {
        const modifier = sortOrder === 'asc' ? 1 : -1;
        return (a.price - b.price) * modifier;
      });
  }, [products, filters, searchTerm, sortOrder]);

  // ECHO: coherence
  // Inconsistent callback patterns - some use useCallback, others don't
  const handleProductClick = useCallback((product: Product) => {
    onProductSelect(product);
  }, [onProductSelect]);

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(event.target.value);
  };

  const handleSortToggle = useCallback(() => {
    setSortOrder(prev => prev === 'asc' ? 'desc' : 'asc');
  }, []);

  return (
    <div className="product-list">
      <div className="controls">
        <input
          type="text"
          placeholder="Search products..."
          value={searchTerm}
          onChange={handleSearchChange}
        />
        <button onClick={handleSortToggle}>
          Sort {sortOrder === 'asc' ? '↑' : '↓'}
        </button>
      </div>
      
      <div className="products">
        {filteredProducts.map(product => (
          <ProductCard
            key={product.id}
            product={product}
            onClick={() => handleProductClick(product)}
          />
        ))}
      </div>
    </div>
  );
};

// ECHO: evaluation
// Review this custom hook for state management and side effects

interface UseApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

function useApi<T>(url: string, dependencies: any[] = []): UseApiState<T> {
  const [state, setState] = useState<UseApiState<T>>({
    data: null,
    loading: true,
    error: null
  });

  useEffect(() => {
    let isCancelled = false;

    const fetchData = async () => {
      setState(prev => ({ ...prev, loading: true, error: null }));
      
      try {
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        
        if (!isCancelled) {
          setState({ data, loading: false, error: null });
        }
      } catch (error) {
        if (!isCancelled) {
          setState({
            data: null,
            loading: false,
            error: error instanceof Error ? error.message : 'Unknown error'
          });
        }
      }
    };

    fetchData();

    return () => {
      isCancelled = true;
    };
  }, [url, ...dependencies]);

  return state;
}

// ECHO: planning
// Need to implement a complex form with validation, file uploads, and dynamic fields
// Requirements: Multi-step wizard, client-side validation, file upload with progress

interface FormWizardProps {
  steps: FormStep[];
  onComplete: (data: FormData) => Promise<void>;
  onCancel: () => void;
}

const FormWizard: React.FC<FormWizardProps> = ({ steps, onComplete, onCancel }) => {
  // Planning will structure:
  // 1. Step navigation state management
  // 2. Form data aggregation across steps
  // 3. Validation system with error display
  // 4. File upload with progress tracking
  // 5. Dynamic field rendering based on previous selections
  // 6. Auto-save and recovery mechanisms
  // 7. Accessibility considerations (ARIA labels, keyboard navigation)
  
  return <div>Form Wizard Implementation Planned</div>;
};

// ECHO: prioritization
// Multiple performance issues identified - need to prioritize fixes

interface PerformanceIssue {
  component: string;
  issue: string;
  impact: 'high' | 'medium' | 'low';
  effort: 'high' | 'medium' | 'low';
  description: string;
}

const performanceIssues: PerformanceIssue[] = [
  {
    component: 'ProductList',
    issue: 'Unnecessary re-renders',
    impact: 'high',
    effort: 'medium',
    description: 'Components re-render on every props change'
  },
  {
    component: 'ImageGallery',
    issue: 'Large bundle size',
    impact: 'medium',
    effort: 'low',
    description: 'Images not optimized, no lazy loading'
  },
  {
    component: 'SearchResults',
    issue: 'Memory leak',
    impact: 'high',
    effort: 'high',
    description: 'Event listeners not cleaned up properly'
  },
  {
    component: 'Dashboard',
    issue: 'Slow initial load',
    impact: 'medium',
    effort: 'medium',
    description: 'Too many API calls on mount'
  }
];

// Prioritization echo will rank these by impact vs effort matrix

export { ProductList, useApi, FormWizard, performanceIssues };
