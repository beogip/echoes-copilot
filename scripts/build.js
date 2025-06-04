#!/usr/bin/env node

/**
 * Build script for Echo + Copilot Instructions
 * Combines modular echo files into single copilot-instructions.md
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const CONFIG = {
  sourceDir: path.join(__dirname, '..', 'instructions-source'),
  outputFile: path.join(__dirname, '..', '.github', 'copilot-instructions.md'),
  instructionsDir: path.join(__dirname, '..', '.github', 'instructions'),
  echoProtocolDir: path.join(__dirname, '..', 'echos-sources'),
  
  // Echo configurations
  echos: [
    {
      name: 'diagnostic',
      file: 'diagnostic-technical.prs.yaml',
      emoji: '🛠️',
      trigger: 'diagnostic'
    },
    {
      name: 'planning',
      file: 'planning-formative.prs.yaml', 
      emoji: '🧭',
      trigger: 'planning'
    },
    {
      name: 'evaluation',
      file: 'evaluation-structured.prs.yaml',
      emoji: '🧪', 
      trigger: 'evaluation'
    },
    {
      name: 'optimization',
      file: 'optimization-technical.prs.yaml',
      emoji: '⚙️',
      trigger: 'optimization'
    },
    {
      name: 'coherence',
      file: 'coherence-self-correction.prs.yaml',
      emoji: '✅',
      trigger: 'coherence'
    },
    {
      name: 'prioritization',
      file: 'prioritization-decisional.prs.yaml',
      emoji: '🔢',
      trigger: 'prioritization'
    }
  ]
};

function loadYamlFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const data = yaml.load(content);
    
    // Handle echo-protocol format (array with single echo object)
    if (Array.isArray(data) && data.length > 0) {
      return data[0]; // Return the first (and usually only) echo
    }
    
    // Handle direct object format
    return data;
  } catch (error) {
    console.error(`Error loading ${filePath}:`, error.message);
    console.warn(`  ⚠️  Skipping invalid YAML file: ${path.basename(filePath)}`);
    return null;
  }
}

function convertEchoToInstructionsFormat(echo, config) {
  const { name, trigger } = config;
  
  // Extract mode from echo data, fallback to config, then capitalize name
  const mode = echo.mode || (echo.echo && echo.echo.includes('–') ? echo.echo.split('–')[1].trim() : null) || 
               `${name.charAt(0).toUpperCase() + name.slice(1)}`;
  
  let markdown = `---\napplyTo: '**'\n---\n\n`;
  
  // Title handling
  const echoTitle = echo.echo || echo.name || `${name.charAt(0).toUpperCase() + name.slice(1)} Echo`;
  markdown += `# Copilot Instructions: ${echoTitle}\n\n`;
  
  // Purpose
  markdown += '## Purpose\n\n';
  markdown += `${echo.purpose || echo.objective || `Perform ${name} analysis on code and development tasks`}\n\n`;
  
  // When to trigger
  markdown += '## When to Trigger\n\n';
  const triggerText = echo.trigger || echo.trigger_context || echo.when || `Use these instructions when ${name} analysis is needed`;
  markdown += `${triggerText}.\n\n`;
  
  // Steps section
  if (echo.steps && Array.isArray(echo.steps)) {
    const stepsSectionTitle = `${mode} Steps`;
    markdown += `## ${stepsSectionTitle}\n\n`;
    
    echo.steps.forEach((step, index) => {
      if (typeof step === 'object') {
        const stepTitle = step.name || step.title || step.goal || `Step ${index + 1}`;
        markdown += `${index + 1}. **${stepTitle}**\n\n`;
        
        // Description/goal
        if (step.description || step.process || step.goal) {
          markdown += `   - ${step.description || step.process || step.goal}\n`;
        }
        
        // Validation criteria
        if (step.validation) {
          markdown += `   - _Validation:_\n`;
          if (Array.isArray(step.validation)) {
            step.validation.forEach(validation => {
              markdown += `     - ${validation}\n`;
            });
          } else {
            markdown += `     - ${step.validation}\n`;
          }
        }
        
        // Expected output
        if (step.output || step.expected_output) {
          markdown += `   - _Expected Output:_ ${step.output || step.expected_output}\n`;
        }
        
        // Critical instructions
        if (step.critical_instruction) {
          markdown += `   - _Critical Instruction:_\n     - ${step.critical_instruction}\n`;
        }
        
        markdown += '\n';
      } else {
        markdown += `${index + 1}. ${step}\n\n`;
      }
    });
  }
  
  // Output format
  if (echo.output_format || echo.output) {
    markdown += '## Output Format\n\n';
    
    if (echo.output_format?.structure) {
      markdown += 'Structured analysis with:\n';
      Object.entries(echo.output_format.structure).forEach(([key, value]) => {
        markdown += `• ${key}: ${value}\n`;
      });
    } else if (echo.output?.template) {
      markdown += echo.output.template;
    } else if (echo.output_format?.description) {
      markdown += echo.output_format.description;
    } else {
      markdown += `Structured ${name} analysis with clear recommendations and actionable next steps.`;
    }
    markdown += '\n\n';
  }
  
  // Notes section
  if (echo.notes || echo.compatibility || echo.examples || echo.config) {
    markdown += '## Notes\n\n';
    
    if (echo.notes) {
      if (Array.isArray(echo.notes)) {
        echo.notes.forEach(note => {
          markdown += `- ${note}\n`;
        });
      } else {
        markdown += `${echo.notes}\n`;
      }
    }
    
    if (echo.config) {
      markdown += '\nConfiguration:\n';
      Object.entries(echo.config).forEach(([key, value]) => {
        markdown += `- ${key}: ${value}\n`;
      });
    }
    
    if (echo.compatibility) {
      markdown += `\nCompatible with: ${echo.compatibility.join(', ')}\n`;
    }
    
    if (echo.examples) {
      markdown += '\n## Example Usage\n\n';
      if (Array.isArray(echo.examples)) {
        echo.examples.forEach(example => {
          markdown += `${example}\n\n`;
        });
      } else {
        markdown += `${echo.examples}\n\n`;
      }
    }
  }
  
  return markdown;
}

function convertEchoToMarkdown(echo, config) {
  const { name, emoji, trigger } = config;
  
  let markdown = `### ${emoji} ${echo.name?.toUpperCase() || name.toUpperCase()} ECHO\n`;
  markdown += `**Trigger**: \`// ECHO: ${trigger}\`\n`;
  markdown += `**Purpose**: ${echo.purpose || echo.objective}\n\n`;
  
  // Steps
  if (echo.steps && Array.isArray(echo.steps)) {
    markdown += '**Steps**:\n';
    echo.steps.forEach((step, index) => {
      if (typeof step === 'object') {
        markdown += `${index + 1}. **${step.name || step.title}**: ${step.description || step.process}\n`;
      } else {
        markdown += `${index + 1}. ${step}\n`;
      }
    });
    markdown += '\n';
  }
  
  // Output format
  if (echo.output_format || echo.output) {
    markdown += '**Output Format**:\n```\n';
    
    if (echo.output_format?.structure) {
      markdown += '## ' + (echo.name || name) + ' Analysis\n';
      Object.entries(echo.output_format.structure).forEach(([key, value]) => {
        markdown += `- **${key}**: [${value}]\n`;
      });
    } else if (echo.output?.template) {
      markdown += echo.output.template;
    } else {
      markdown += `## ${echo.name || name} Analysis\n`;
      markdown += '- **Analysis**: [Detailed analysis]\n';
      markdown += '- **Recommendations**: [Specific recommendations]\n';
    }
    
    markdown += '```\n\n';
  }
  
  return markdown;
}

function buildIndividualInstructions() {
  console.log('🏗️  Building individual instruction files...\n');
  
  // Ensure instructions directory exists
  if (!fs.existsSync(CONFIG.instructionsDir)) {
    fs.mkdirSync(CONFIG.instructionsDir, { recursive: true });
    console.log(`📁 Created directory: ${CONFIG.instructionsDir}`);
  }
  
  CONFIG.echos.forEach(echoConfig => {
    console.log(`📄 Processing ${echoConfig.name}...`);
    let echoData = null;
    // Only load .prs.yaml files from echos-source
    const echoDir = path.join(__dirname, '..', 'echos-sources', echoConfig.name);
    const protocolPath = path.join(echoDir, echoConfig.file);
    if (protocolPath.endsWith('.prs.yaml') && fs.existsSync(protocolPath)) {
      echoData = loadYamlFile(protocolPath);
      if (echoData) {
        console.log(`  ✅ Loaded from echos-source: ${echoConfig.name}/${echoConfig.file}`);
      }
    }
    // Fallback if not found
    if (!echoData) {
      console.error(`  ❌ Echo file not found for ${echoConfig.name}`);
      echoData = {
        name: `${echoConfig.name.charAt(0).toUpperCase() + echoConfig.name.slice(1)} Echo`,
        purpose: `Perform ${echoConfig.name} analysis on code and development tasks`,
        trigger_context: `${echoConfig.name} analysis is needed`,
        steps: [
          {
            name: `Analyze ${echoConfig.name} requirements`,
            description: `Identify the specific ${echoConfig.name} needs and context`,
            validation: [`Were the ${echoConfig.name} requirements clearly identified?`],
            output: `Clear definition of ${echoConfig.name} scope`
          },
          {
            name: `Apply systematic methodology`,
            description: `Use structured approach to ${echoConfig.name}`,
            validation: [`Was a systematic approach followed?`],
            output: `Methodical ${echoConfig.name} analysis`
          },
          {
            name: `Generate recommendations`,
            description: `Provide actionable next steps`,
            validation: [`Are recommendations clear and actionable?`],
            output: `Specific ${echoConfig.name} recommendations`
          }
        ]
      };
    }
    // Generate instruction file
    const instructionContent = convertEchoToInstructionsFormat(echoData, echoConfig);
    
    // Extract mode from echo data for filename
    const mode = (echoData.mode || (echoData.echo && echoData.echo.includes('–') ? 
      echoData.echo.split('–')[1].trim().toLowerCase().replace(/\s+/g, '-') : 'mode')).toLowerCase();
    
    const outputPath = path.join(CONFIG.instructionsDir, `${echoConfig.name.toLowerCase()}-${mode}.instructions.md`);
    
    fs.writeFileSync(outputPath, instructionContent);
    console.log(`  💾 Generated: ${path.basename(outputPath)}`);
  });
  
  console.log('\n✅ Individual instruction files built successfully!');
}

function buildInstructions() {
  console.log('🏗️  Building Copilot instructions index...');
  
  // Load header template or use default
  const headerPath = path.join(CONFIG.sourceDir, 'header.md');
  let content = '';
  if (fs.existsSync(headerPath)) {
    content += fs.readFileSync(headerPath, 'utf8') + '\n\n';
  } else {
    console.log('📝 Using optimized index-based template...');
    content += `# Echo Protocol Integration for GitHub Copilot

You are GitHub Copilot enhanced with the Echo Protocol - a modular reasoning architecture that structures cognitive processes for systematic problem-solving in software development.

## What are Thought Echos?

**Thought Echos** are structured cognitive units that define specific reasoning processes:

- **Functional units** with defined purpose, trigger, steps, and output
- **Reusable** across different contexts and projects
- **Auditable** with explicit and traceable steps
- **Modular** that can be combined into complex flows
- **Agent-agnostic** (executable by humans, AIs, or hybrids)

## Quick Start

1. **Copy this repository's \`.github/instructions/\` folder** to your project
2. **Use echo triggers in comments** to activate structured reasoning
3. **GitHub Copilot automatically loads** the individual instruction files

## Echo Activation

When you see a comment starting with \`ECHO:\`, execute the corresponding reasoning pattern:

\`\`\`javascript
// ECHO: diagnostic
// Need to understand why this function fails with large arrays
\`\`\`

\`\`\`python
# ECHO: planning
# Want to refactor this module for better maintainability
\`\`\`

## Available Development Echos

The following echos are available through individual instruction files in \`.github/instructions/\`:

`;
  }
  
  // Generate echo index (lightweight references, not full definitions)
  CONFIG.echos.forEach(echoConfig => {
    console.log(`📋 Indexing ${echoConfig.name} echo...`);
    
    // Load echo for basic info
    const echoProtocolPath = path.join(CONFIG.echoProtocolDir, echoConfig.name, echoConfig.file);
    
    let echoData = null;
    if (fs.existsSync(echoProtocolPath)) {
      echoData = loadYamlFile(echoProtocolPath);
      console.log(`  ✅ Loaded from echo-protocol: ${echoConfig.file}`);
    }
    
    if (echoData) {
      // Extract mode for filename reference
      const mode = echoData.mode || (echoData.echo && echoData.echo.includes('–') ? 
        echoData.echo.split('–')[1].trim() : 'Mode');
      
      const fileName = `${echoConfig.name}-${mode}.instructions.md`;
      
      content += `### ${echoConfig.emoji} **${echoConfig.name}** - ${getEchoCategory(echoConfig.name)}
- **Trigger**: \`// ECHO: ${echoConfig.trigger}\`
- **Purpose**: ${getShortPurpose(echoData.purpose)}
- **File**: \`${fileName}\`

`;
    }
  });

  // Load footer or use default
  const footerPath = path.join(CONFIG.sourceDir, 'footer.md');
  let footerContent = '';
  if (fs.existsSync(footerPath)) {
    footerContent = fs.readFileSync(footerPath, 'utf8');
  } else {
    footerContent = `\n## Advanced Echo Combinations\n\nYou can chain multiple echos for complex problems:\n\n...`;
  }

  content += '\n' + footerContent;
  
  // Write output file
  fs.writeFileSync(CONFIG.outputFile, content);
  console.log(`✅ Instructions index built successfully: ${CONFIG.outputFile}`);
  console.log(`📊 Total length: ${content.length} characters`);
}

// Helper functions for echo indexing
function getEchoCategory(echoName) {
  const categories = {
    'diagnostic': 'Technical Debugging',
    'planning': 'Project Planning',
    'evaluation': 'Code & Design Review',
    'optimization': 'Performance & Efficiency',
    'coherence': 'Flow Correction',
    'prioritization': 'Decision Making'
  };
  return categories[echoName] || 'Analysis';
}

function getShortPurpose(fullPurpose) {
  if (!fullPurpose) return 'Systematic analysis and recommendations';
  
  // Extract first sentence or truncate to reasonable length
  const firstSentence = fullPurpose.split('.')[0];
  if (firstSentence.length > 80) {
    return firstSentence.substring(0, 77) + '...';
  }
  return firstSentence;
}

function buildAll() {
  console.log('🚀 Building Echo Protocol integration for GitHub Copilot...\n');
  
  // Build individual instruction files (primary functionality)
  buildIndividualInstructions();
  
  console.log();
  
  // Build lightweight index file for overview
  buildInstructions();
  
  console.log('\n🎉 All builds completed successfully!');
  console.log('📁 Primary: Individual instruction files in .github/instructions/');
  console.log('📄 Secondary: Overview index in .github/copilot-instructions.md');
}

// Run if called directly
if (require.main === module) {
  // Check for command line arguments
  const args = process.argv.slice(2);
  
  if (args.includes('--individual') || args.includes('-i')) {
    buildIndividualInstructions();
  } else if (args.includes('--copilot') || args.includes('-c')) {
    buildInstructions();
  } else {
    buildAll();
  }
}

module.exports = { buildInstructions, buildIndividualInstructions, buildAll };
