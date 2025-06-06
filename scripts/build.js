#!/usr/bin/env node

/**
 * Enhanced Build script for Echo + Copilot Instructions
 * Combines modular echo files into single copilot-instructions.md
 * 
 * Features:
 * - Structured logging with Winston
 * - Enhanced error handling and recovery
 * - Build validation and integrity checks
 * - Performance monitoring
 * - Detailed build metrics
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const winston = require('winston');

// Configure Winston logger with console transport that outputs to stderr for errors
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    // Support external timestamp configuration for testing
    process.env.WINSTON_TIMESTAMP_FORMAT?.startsWith('fixed:')
      ? winston.format.timestamp({ format: () => process.env.WINSTON_TIMESTAMP_FORMAT.replace('fixed:', '') })
      : winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.errors({ stack: true })
  ),
  transports: [
    new winston.transports.Console({
      stderrLevels: ['error', 'warn'], // Send errors and warnings to stderr for test compatibility
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, stack }) => {
          return `${timestamp} [${level}]: ${message}${stack ? '\n' + stack : ''}`;
        })
      )
    }),
    new winston.transports.File({
      filename: path.join(__dirname, '..', 'logs', 'build.log'),
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ]
});

// Helper function to log errors consistently (replaces dual logging pattern)
function logError(message, context = {}) {
  logger.error(message, context);
  buildMetrics.errors.push(typeof message === 'string' ? message : message.toString());
}

// Helper function to log warnings consistently
function logWarning(message, context = {}) {
  logger.warn(message, context);
  buildMetrics.warnings.push(typeof message === 'string' ? message : message.toString());
}

// Build metrics tracking
const buildMetrics = {
  startTime: Date.now(),
  echoFilesProcessed: 0,
  instructionFilesGenerated: 0,
  totalOutputSize: 0,
  errors: [],
  warnings: []
};

const CONFIG = {
  sourceDir: path.join(__dirname, '..', 'instructions-source'),
  outputFile: path.join(__dirname, '..', '.github', 'copilot-instructions.md'),
  instructionsDir: path.join(__dirname, '..', '.github', 'instructions'),
  echoProtocolDir: path.join(__dirname, '..', 'echos-sources'),
  
  // Echo configurations
  echos: [
    {
      name: 'diagnostic',
      file: 'diagnostic/diagnostic-technical.prs.yaml',
      emoji: '🛠️',
      trigger: 'diagnostic'
    },
    {
      name: 'planning',
      file: 'planning/planning-formative.prs.yaml', 
      emoji: '🧭',
      trigger: 'planning'
    },
    {
      name: 'evaluation',
      file: 'evaluation/evaluation-structured.prs.yaml',
      emoji: '🧪', 
      trigger: 'evaluation'
    },
    {
      name: 'optimization',
      file: 'optimization/optimization-technical.prs.yaml',
      emoji: '⚙️',
      trigger: 'optimization'
    },
    {
      name: 'coherence',
      file: 'coherence/coherence-self-correction.prs.yaml',
      emoji: '✅',
      trigger: 'coherence'
    },
    {
      name: 'prioritization',
      file: 'prioritization/prioritization-decisional.prs.yaml',
      emoji: '🔢',
      trigger: 'prioritization'
    }
  ]
};

/**
 * Enhanced YAML file loader with comprehensive error handling
 * @param {string} filePath - Path to YAML file
 * @returns {Object|null} Parsed YAML data or null on error
 */
function loadYamlFile(filePath) {
  const fileName = path.basename(filePath);
  try {
    // Check file existence
    if (!fs.existsSync(filePath)) {
      const errMsg = `File not found: ${filePath}`;
      logError(errMsg);
      buildMetrics.errors.push(`Missing file: ${fileName}`);
      return null;
    }
    // Check for symlink loop or hard link
    let stat;
    try {
      stat = fs.lstatSync(filePath);
      if (stat.isSymbolicLink()) {
        // Detect symlink loop (points to itself or too many levels)
        const realPath = fs.realpathSync.native(filePath);
        if (realPath === filePath) {
          const errMsg = `Symlink loop detected: ${filePath}`;
          logError(errMsg);
          buildMetrics.errors.push(`Symlink loop: ${fileName}`);
          return null;
        }
      }
      if (!stat.isFile()) {
        const errMsg = `Not a regular file: ${filePath}`;
        logError(errMsg);
        buildMetrics.errors.push(`Not a regular file: ${fileName}`);
        return null;
      }
      if (stat.nlink > 1) {
        const errMsg = `Hard link detected: ${filePath}`;
        logError(errMsg);
        buildMetrics.errors.push(`Hard link: ${fileName}`);
        return null;
      }
    } catch (statError) {
      const errMsg = `Cannot stat file: ${filePath} (${statError.message})`;
      logError(errMsg);
      buildMetrics.errors.push(`Stat error: ${fileName}`);
      return null;
    }
    // Check file readability
    try {
      fs.accessSync(filePath, fs.constants.R_OK);
    } catch (accessError) {
      const errMsg = `Cannot read file: ${filePath} (${accessError.message})`;
      logError(errMsg);
      buildMetrics.errors.push(`Unreadable file: ${fileName}`);
      return null;
    }
    // Check for suspicious filename (unicode, emoji, traversal)
    if (/[^\x00-\x7F]/.test(fileName) || /[\u{1F600}-\u{1F64F}]/u.test(fileName) || fileName.includes('..') || fileName.includes('/') || fileName.includes('\\')) {
      const errMsg = `Suspicious or invalid filename: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`Invalid filename: ${fileName}`);
      return null;
    }
    let content;
    try {
      content = fs.readFileSync(filePath);
    } catch (readError) {
      const errMsg = `Cannot read file: ${filePath} (${readError.message})`;
      logError(errMsg);
      buildMetrics.errors.push(`Read error: ${fileName}`);
      return null;
    }
    // Check for binary (non-UTF-8) or BOM
    if (content[0] === 0xef && content[1] === 0xbb && content[2] === 0xbf) {
      const errMsg = `BOM detected in file: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`BOM: ${fileName}`);
      return null;
    }
    if (content.some(b => b === 0x00)) {
      const errMsg = `Binary file detected: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`Binary file: ${fileName}`);
      return null;
    }
    let text;
    try {
      text = content.toString('utf8');
    } catch (utf8Error) {
      const errMsg = `Invalid UTF-8 in file: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`Invalid UTF-8: ${fileName}`);
      return null;
    }
    // Check for empty, whitespace, tabs, CRLF, only comments
    if (!text.trim() || /^\s+$/.test(text)) {
      const warnMsg = `Empty or whitespace-only file: ${fileName}`;
      logWarning(warnMsg);
      // Return empty structure instead of null for empty files
      return {
        id: 'empty',
        name: 'Empty File',
        purpose: 'Empty file detected',
        trigger: '',
        steps: [],
        output: '',
        examples: []
      };
    }
    if (/^[#\s\r\n]+$/.test(text)) {
      const warnMsg = `File contains only comments or whitespace: ${fileName}`;
      logWarning(warnMsg);
      // Return empty structure instead of null for comment-only files
      return {
        id: 'comments-only',
        name: 'Comments Only File',
        purpose: 'File contains only comments',
        trigger: '',
        steps: [],
        output: '',
        examples: []
      };
    }
    if (/\r\n/.test(text)) {
      const errMsg = `CRLF line endings detected: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`CRLF line endings: ${fileName}`);
      return null;
    }
    if (/^\t+$/.test(text)) {
      const errMsg = `File contains only tabs: ${fileName}`;
      logError(errMsg);
      buildMetrics.errors.push(`Only tabs: ${fileName}`);
      return null;
    }
    // Try YAML parse
    let data;
    try {
      data = yaml.load(text);
    } catch (error) {
      const errMsg = `YAML parse error in ${fileName}: ${error.message}`;
      logError(errMsg, { filePath: filePath, stack: error.stack });
      return null;
    }
    if (!data) {
      const errMsg = `YAML file parsed to null/undefined: ${fileName}`;
      logError(errMsg);
      return null;
    }
    // Handle echo-protocol format (array with single echo object)
    if (Array.isArray(data) && data.length > 0) {
      logger.debug(`Loaded array format YAML: ${fileName}`);
      return data[0]; // Return the first (and usually only) echo
    }
    // Handle direct object format
    logger.debug(`Loaded object format YAML: ${fileName}`);
    return data;
  } catch (error) {
    const errMsg = `YAML parse error in ${fileName}: ${error.message}`;
    logError(errMsg, { filePath: filePath, stack: error.stack });
    return null;
  }
}

/**
 * Generate fallback content when echo processing fails
 * @param {string} name - Echo name
 * @param {Object} config - Echo configuration
 * @returns {string} Fallback markdown content
 */
function generateFallbackContent(name, config) {
  logger.info(`Generating fallback content for: ${name}`);
  
  return `---
applyTo: '**'
---

# Copilot Instructions: ${name.charAt(0).toUpperCase() + name.slice(1)} Echo

## Purpose

Perform ${name} analysis on code and development tasks.

## When to Trigger

Use these instructions when ${name} analysis is needed.

## ${name.charAt(0).toUpperCase() + name.slice(1)} Steps

1. **Analyze Context**
   - Review the current situation and requirements
   - Identify key factors and constraints

2. **Apply ${name.charAt(0).toUpperCase() + name.slice(1)} Logic**
   - Execute systematic ${name} process
   - Generate structured analysis

3. **Provide Recommendations**
   - Present clear, actionable insights
   - Include rationale and next steps

## Output Format

Structured analysis with clear recommendations and rationale.

`;
}

/**
 * Enhanced echo to instructions format converter
 * @param {Object} echo - Echo data from YAML
 * @param {Object} config - Echo configuration
 * @returns {string} Formatted markdown content
 */
function convertEchoToInstructionsFormat(echo, config) {
  const { name, trigger } = config;
  
  try {
    logger.debug(`Converting echo to instructions format: ${name}`);
    
    // Validate required data
    if (!echo || typeof echo !== 'object') {
      logger.error(`Invalid echo data for ${name}: not an object`);
      buildMetrics.errors.push(`Invalid echo data: ${name}`);
      return generateFallbackContent(name, config);
    }
    
    // Extract mode from echo data, fallback to config, then capitalize name
    const mode = echo.mode || 
                 (echo.echo && echo.echo.includes('–') ? echo.echo.split('–')[1].trim() : null) || 
                 `${name.charAt(0).toUpperCase() + name.slice(1)}`;
    
    let markdown = `---\napplyTo: '**'\n---\n\n`;
    
    // Title handling with validation
    const echoTitle = echo.echo || echo.name || `${name.charAt(0).toUpperCase() + name.slice(1)} Echo`;
    markdown += `# Copilot Instructions: ${echoTitle}\n\n`;
    
    // Purpose section with fallback
    markdown += '## Purpose\n\n';
    const purposeText = echo.purpose || echo.objective || `Perform ${name} analysis on code and development tasks`;
    markdown += `${purposeText}\n\n`;
    
    // When to trigger section
    markdown += '## When to Trigger\n\n';
    const triggerText = echo.trigger || echo.trigger_context || echo.when || 
                       `Use these instructions when ${name} analysis is needed`;
    markdown += `${triggerText}\n\n`;
    
    // Steps section with comprehensive validation
    if (echo.steps && Array.isArray(echo.steps)) {
      const stepsSectionTitle = `${mode} Steps`;
      markdown += `## ${stepsSectionTitle}\n\n`;
      
      echo.steps.forEach((step, index) => {
        try {
          if (typeof step === 'object' && step !== null) {
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
                  if (validation && typeof validation === 'string') {
                    markdown += `     - ${validation}\n`;
                  }
                });
              } else if (typeof step.validation === 'string') {
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
          } else if (typeof step === 'string') {
            markdown += `${index + 1}. ${step}\n\n`;
          } else {
            logger.warn(`Invalid step format in ${name} at index ${index}`);
            buildMetrics.warnings.push(`Invalid step format: ${name}[${index}]`);
          }
        } catch (stepError) {
          logger.error(`Error processing step ${index} in ${name}`, { error: stepError.message });
          buildMetrics.errors.push(`Step processing error: ${name}[${index}]`);
        }
      });
    } else if (echo.steps) {
      logger.warn(`Steps field is not an array in ${name}`);
      buildMetrics.warnings.push(`Invalid steps format: ${name}`);
    }
    
    // Output format section with validation
    if (echo.output_format || echo.output) {
      markdown += '## Output Format\n\n';
      
      if (echo.output_format?.structure && typeof echo.output_format.structure === 'object') {
        markdown += 'Structured analysis with:\n';
        Object.entries(echo.output_format.structure).forEach(([key, value]) => {
          if (key && value) {
            markdown += `• ${key}: ${value}\n`;
          }
        });
      } else if (echo.output || echo.output_format) {
        const outputText = echo.output || (typeof echo.output_format === 'string' ? echo.output_format : '');
        if (outputText) {
          markdown += `${outputText}\n`;
        }
      }
      markdown += '\n';
    }
    
    // Additional sections with validation
    if (echo.examples && Array.isArray(echo.examples) && echo.examples.length > 0) {
      markdown += '## Examples\n\n';
      echo.examples.forEach((example, index) => {
        if (example && typeof example === 'string') {
          markdown += `${index + 1}. ${example}\n`;
        } else if (example && typeof example === 'object') {
          const exampleTitle = example.title || example.name || `Example ${index + 1}`;
          markdown += `### ${exampleTitle}\n\n`;
          if (example.description) {
            markdown += `${example.description}\n\n`;
          }
        }
      });
      markdown += '\n';
    }
    
    logger.debug(`Successfully converted echo: ${name} (${markdown.length} chars)`);
    buildMetrics.totalOutputSize += markdown.length;
    return markdown;
    
  } catch (error) {
    logger.error(`Error converting echo ${name} to instructions format`, { 
      error: error.message,
      stack: error.stack 
    });
    buildMetrics.errors.push(`Conversion error: ${name}`);
    return generateFallbackContent(name, config);
  }
}

/**
 * Enhanced individual instructions builder with validation and error recovery
 */
function buildIndividualInstructions() {
  logger.info('🔨 Building individual instruction files...');
  
  try {
    // Ensure instructions directory exists
    if (!fs.existsSync(CONFIG.instructionsDir)) {
      fs.mkdirSync(CONFIG.instructionsDir, { recursive: true });
      logger.info(`Created instructions directory: ${CONFIG.instructionsDir}`);
    }
    
    // Process each echo configuration
    CONFIG.echos.forEach(echoConfig => {
      try {
        const echoPath = path.join(CONFIG.echoProtocolDir, echoConfig.file);
        logger.debug(`Processing echo: ${echoConfig.name} from ${echoPath}`);
        
        let echoData = loadYamlFile(echoPath);
        
        if (!echoData) {
          logger.error(`Failed to load echo data for ${echoConfig.name}`);
          buildMetrics.errors.push(`Failed to load: ${echoConfig.name}`);
          
          // Generate fallback content
          echoData = {
            name: echoConfig.name,
            purpose: `Perform ${echoConfig.name} analysis on code and development tasks`,
            steps: [
              {
                name: 'Analyze Context',
                description: 'Review the current situation and requirements',
                validation: [`Were the ${echoConfig.name} requirements clearly identified?`],
                output: 'Context analysis summary'
              }
            ]
          };
        }
        
        const markdown = convertEchoToInstructionsFormat(echoData, echoConfig);
        const outputPath = path.join(CONFIG.instructionsDir, `${echoConfig.name}.md`);
        
        // Write with error handling
        try {
          fs.writeFileSync(outputPath, markdown);
          logger.info(`✅ Generated: ${echoConfig.name}.md`);
          buildMetrics.instructionFilesGenerated++;
          buildMetrics.echoFilesProcessed++;
        } catch (writeError) {
          logger.error(`Failed to write ${echoConfig.name}.md`, { error: writeError.message });
          buildMetrics.errors.push(`Write error: ${echoConfig.name}.md`);
        }
        
      } catch (echoError) {
        logger.error(`Error processing echo ${echoConfig.name}`, { 
          error: echoError.message,
          stack: echoError.stack 
        });
        buildMetrics.errors.push(`Processing error: ${echoConfig.name}`);
      }
    });
    
    logger.info(`📁 Individual instructions built: ${buildMetrics.instructionFilesGenerated} files`);
    
  } catch (error) {
    logger.error('Fatal error in buildIndividualInstructions', { 
      error: error.message,
      stack: error.stack 
    });
    buildMetrics.errors.push('Fatal build error');
  }
}

/**
 * Enhanced copilot instructions builder with validation
 */
function buildInstructions() {
  logger.info('🔨 Building copilot instructions index...');
  
  try {
    // Load header content
    const headerPath = path.join(CONFIG.sourceDir, 'header.md');
    let headerContent = '';
    
    if (fs.existsSync(headerPath)) {
      try {
        headerContent = fs.readFileSync(headerPath, 'utf8');
        logger.debug(`Loaded header content: ${headerContent.length} chars`);
      } catch (headerError) {
        logger.warn(`Failed to load header: ${headerError.message}`);
        buildMetrics.warnings.push('Header load failed');
      }
    } else {
      logger.warn(`Header file not found: ${headerPath}`);
      buildMetrics.warnings.push('Header file missing');
    }
    
    // Build echo index section
    let echoIndex = '\n## Available Echos for Development\n\n<!-- Echos will be inserted here by build script -->\n\n';
    
    CONFIG.echos.forEach(echoConfig => {
      try {
        const echoPath = path.join(CONFIG.echoProtocolDir, echoConfig.file);
        const echoData = loadYamlFile(echoPath);
        
        if (echoData) {
          const purpose = getShortPurpose(echoData.purpose || echoData.objective);
          const category = getEchoCategory(echoConfig.name);
          
          echoIndex += `\n### ${echoConfig.emoji} **${echoConfig.name}** - ${category}\n`;
          echoIndex += `- **Trigger**: \`// ECHO: ${echoConfig.trigger}\`\n`;
          echoIndex += `- **Purpose**: ${purpose}\n`;
          echoIndex += `- **File**: \`.github/instructions/${echoConfig.name}.md\`\n`;
        } else {
          logger.warn(`Skipping echo index entry for ${echoConfig.name} (no data)`);
          buildMetrics.warnings.push(`Index skip: ${echoConfig.name}`);
        }
      } catch (indexError) {
        logger.error(`Error building index for ${echoConfig.name}`, { error: indexError.message });
        buildMetrics.errors.push(`Index error: ${echoConfig.name}`);
      }
    });
    
    // Load footer content
    const footerPath = path.join(CONFIG.sourceDir, 'footer.md');
    let footerContent = '';
    
    if (fs.existsSync(footerPath)) {
      try {
        footerContent = fs.readFileSync(footerPath, 'utf8');
        logger.debug(`Loaded footer content: ${footerContent.length} chars`);
      } catch (footerError) {
        logger.warn(`Failed to load footer: ${footerError.message}`);
        buildMetrics.warnings.push('Footer load failed');
      }
    } else {
      logger.warn(`Footer file not found: ${footerPath}`);
      buildMetrics.warnings.push('Footer file missing');
    }
    
    // Combine all content
    let content = headerContent + echoIndex + '\n' + footerContent;
    buildMetrics.totalOutputSize += content.length;
    
    // Write output file with validation
    try {
      const outputDir = path.dirname(CONFIG.outputFile);
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
        logger.info(`Created output directory: ${outputDir}`);
      }
      
      fs.writeFileSync(CONFIG.outputFile, content);
      logger.info(`✅ Instructions index built successfully: ${CONFIG.outputFile}`);
      logger.info(`📊 Total length: ${content.length} characters`);
      
    } catch (writeError) {
      logger.error(`Failed to write output file: ${CONFIG.outputFile}`, { error: writeError.message });
      buildMetrics.errors.push('Output file write failed');
    }
    
  } catch (error) {
    logger.error('Fatal error in buildInstructions', { 
      error: error.message,
      stack: error.stack 
    });
    buildMetrics.errors.push('Fatal index build error');
  }
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

/**
 * Post-build validation and integrity checks
 */
function validateBuild() {
  logger.info('🔍 Running post-build validation...');
  
  const validationResults = {
    passed: 0,
    failed: 0,
    issues: []
  };
  
  try {
    // Check individual instruction files
    CONFIG.echos.forEach(echoConfig => {
      const filePath = path.join(CONFIG.instructionsDir, `${echoConfig.name}.md`);
      
      if (fs.existsSync(filePath)) {
        try {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Basic content validation
          if (content.length < 100) {
            validationResults.issues.push(`${echoConfig.name}.md: Content too short (${content.length} chars)`);
            validationResults.failed++;
          } else if (!content.includes('# Copilot Instructions:')) {
            validationResults.issues.push(`${echoConfig.name}.md: Missing proper header`);
            validationResults.failed++;
          } else if (!content.includes('## Purpose')) {
            validationResults.issues.push(`${echoConfig.name}.md: Missing Purpose section`);
            validationResults.failed++;
          } else {
            validationResults.passed++;
          }
          
        } catch (readError) {
          validationResults.issues.push(`${echoConfig.name}.md: Read error - ${readError.message}`);
          validationResults.failed++;
        }
      } else {
        validationResults.issues.push(`${echoConfig.name}.md: File missing`);
        validationResults.failed++;
      }
    });
    
    // Check main output file
    if (fs.existsSync(CONFIG.outputFile)) {
      try {
        const content = fs.readFileSync(CONFIG.outputFile, 'utf8');
        if (content.length < 1000) {
          validationResults.issues.push(`Output file too short: ${content.length} chars`);
          validationResults.failed++;
        } else {
          validationResults.passed++;
        }
      } catch (readError) {
        validationResults.issues.push(`Output file read error: ${readError.message}`);
        validationResults.failed++;
      }
    } else {
      validationResults.issues.push('Output file missing');
      validationResults.failed++;
    }
    
    // Log validation results
    logger.info(`Validation completed: ${validationResults.passed} passed, ${validationResults.failed} failed`);
    
    if (validationResults.issues.length > 0) {
      logger.warn('Validation issues found:');
      validationResults.issues.forEach(issue => logger.warn(`  - ${issue}`));
    }
    
    return validationResults;
    
  } catch (error) {
    logger.error('Error during build validation', { error: error.message });
    return { passed: 0, failed: 1, issues: ['Validation error'] };
  }
}

/**
 * Display comprehensive build metrics and summary
 */
function displayBuildMetrics() {
  const duration = Date.now() - buildMetrics.startTime;
  
  logger.info('\n📊 Build Metrics Summary:');
  logger.info(`   ⏱️  Duration: ${duration}ms`);
  logger.info(`   📄 Echo files processed: ${buildMetrics.echoFilesProcessed}`);
  logger.info(`   📋 Instruction files generated: ${buildMetrics.instructionFilesGenerated}`);
  logger.info(`   📏 Total output size: ${buildMetrics.totalOutputSize} chars`);
  logger.info(`   ❌ Errors: ${buildMetrics.errors.length}`);
  logger.info(`   ⚠️  Warnings: ${buildMetrics.warnings.length}`);
  
  if (buildMetrics.errors.length > 0) {
    logger.error('\n❌ Build Errors:');
    buildMetrics.errors.forEach(error => logger.error(`   - ${error}`));
  }
  
  if (buildMetrics.warnings.length > 0) {
    logger.warn('\n⚠️  Build Warnings:');
    buildMetrics.warnings.forEach(warning => logger.warn(`   - ${warning}`));
  }
  
  // Performance insights
  const avgTimePerEcho = Math.round(duration / CONFIG.echos.length);
  const avgSizePerFile = Math.round(buildMetrics.totalOutputSize / buildMetrics.instructionFilesGenerated);
  
  logger.info('\n🔍 Performance Insights:');
  logger.info(`   ⚡ Average time per echo: ${avgTimePerEcho}ms`);
  logger.info(`   📊 Average file size: ${avgSizePerFile} chars`);
  
  return {
    duration,
    success: buildMetrics.errors.length === 0,
    metrics: buildMetrics
  };
}

/**
 * Enhanced main build function with comprehensive error handling
 */
function buildAll() {
  logger.info('🚀 Starting Enhanced Echo Protocol build for GitHub Copilot...\n');
  
  try {
    // Ensure logs directory exists
    const logsDir = path.join(__dirname, '..', 'logs');
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }
    
    // Build individual instruction files (primary functionality)
    buildIndividualInstructions();
    
    logger.info('');
    
    // Build lightweight index file for overview
    buildInstructions();
    
    // Run post-build validation
    logger.info('');
    const validationResults = validateBuild();
    
    // Display comprehensive metrics
    const buildResults = displayBuildMetrics();
    
    // Final summary
    logger.info('\n🎉 Enhanced build completed!');
    logger.info('📁 Primary: Individual instruction files in .github/instructions/');
    logger.info('📄 Secondary: Overview index in .github/copilot-instructions.md');
    logger.info('📊 Logs: Detailed build log in logs/build.log');
    
    if (buildResults.success && validationResults.failed === 0) {
      logger.info('✅ Build completed successfully with no errors!');
      process.exit(0);
    } else {
      logger.warn('⚠️  Build completed with warnings or errors. Check logs for details.');
      process.exit(1);
    }
    
  } catch (fatalError) {
    logger.error('💥 Fatal build error', { 
      error: fatalError.message,
      stack: fatalError.stack 
    });
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  // Check for command line arguments
  const args = process.argv.slice(2);

  // If direct YAML/file arguments are provided, process them individually
  if (args.length > 0 && args.every(arg => arg.endsWith('.yaml') || arg.endsWith('.yml') || fs.existsSync(arg))) {
    let hadError = false;
    let hadWarning = false;
    args.forEach(fileArg => {
      const data = loadYamlFile(fileArg);
      const fileName = require('path').basename(fileArg);
      const fileContent = fs.existsSync(fileArg) ? fs.readFileSync(fileArg, 'utf8') : '';
      const isEmptyWarning = buildMetrics.warnings.some(w => w.includes(fileName) && w.includes('Empty'));
      const isOtherWarning = buildMetrics.warnings.some(w => w.includes(fileName) && !w.includes('Empty'));
      if (data) {
        console.log(`Build succeeded for: ${fileArg}`);
      } else if (isEmptyWarning && !isOtherWarning) {
        console.warn(`WARNING: Build completed with warning for: ${fileArg}`);
        hadWarning = true;
      } else {
        // If file is not empty, treat as parse error and exit immediately
        if (fileContent.trim()) {
          process.exit(1);
        } else {
          hadError = true;
        }
      }
      if (buildMetrics.errors.length > 0) {
        process.exit(1);
      }
    });
    process.exit(0);
  } else if (args.includes('--individual') || args.includes('-i')) {
    buildIndividualInstructions();
    displayBuildMetrics();
  } else if (args.includes('--copilot') || args.includes('-c')) {
    buildInstructions();
    displayBuildMetrics();
  } else {
    buildAll();
  }
}

module.exports = { buildInstructions, buildIndividualInstructions, buildAll };
