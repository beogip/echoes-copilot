// utils.ts - Utility functions for echo processing and build system

/**
 * Interface for echo configuration object
 */
interface EchoConfig {
  name: string;
  file: string;
  trigger: string;
  emoji?: string;
}

/**
 * Get category for echo based on name
 * @param echoName - Name of the echo
 * @returns Category classification
 */
function getEchoCategory(echoName: string): string {
  if (!echoName || typeof echoName !== 'string') return 'General';
  
  const categoryMap: Record<string, string> = {
    'diagnostic': 'Technical Debugging',
    'planning': 'Project Planning',
    'evaluation': 'Code & Design Review',
    'optimization': 'Performance & Efficiency',
    'coherence': 'Flow Correction',
    'prioritization': 'Decision Making'
  };
  
  return categoryMap[echoName.toLowerCase()] || 'General';
}

/**
 * Get shortened version of purpose text
 * @param fullPurpose - Full purpose text
 * @returns Shortened purpose (max 80 chars)
 */
function getShortPurpose(fullPurpose: string | undefined): string {
  if (!fullPurpose || typeof fullPurpose !== 'string') return 'No purpose defined';
  
  const maxLength = 80;
  if (fullPurpose.length <= maxLength) return fullPurpose;
  
  // Find the last space before the limit to avoid cutting words
  const cutIndex = fullPurpose.lastIndexOf(' ', maxLength);
  return cutIndex > 0 ? fullPurpose.substring(0, cutIndex) + '...' : fullPurpose.substring(0, maxLength) + '...';
}

/**
 * Generate fallback content when echo processing fails
 * @param name - Echo name
 * @param config - Echo configuration
 * @returns Fallback markdown content
 */
function generateFallbackContent(name: string, config: EchoConfig): string {
  if (!name || !config) return '';
  
  return `---
applyTo: '**'
---

# Copilot Instructions: ${name.charAt(0).toUpperCase() + name.slice(1)} Echo

## Purpose

Perform ${name} analysis on code and development tasks.

## When to Trigger

Use these instructions when ${name} analysis is needed. Trigger with: \`// ECHO: ${config.trigger}\`

## Steps

1. **Initialize Analysis**
   - Set up the ${name} analysis context
   - Identify the scope and objectives

2. **Execute Analysis**
   - Apply ${name} methodology
   - Gather relevant information

3. **Report Results**
   - Summarize findings
   - Provide actionable recommendations

*Note: This is fallback content generated due to processing error.*
`;
}

export {
  EchoConfig,
  getEchoCategory,
  getShortPurpose,
  generateFallbackContent
};
