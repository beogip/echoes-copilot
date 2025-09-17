// echo-merge.ts - Echo Protocol file merging and processing module
// Handles the merging and processing of Echo Protocol files

import fs from 'fs';
import path from 'path';
import winston from 'winston';
import { BuildMetrics } from './metrics';
import { EchoConfig, generateFallbackContent } from './utils';
import { EchoData, validateEchoYaml } from './validation';

// Load centralized configuration
const EchoConstants = require('../../config/config-loader.js');
let echoConstants: any;
try {
  echoConstants = new EchoConstants();
} catch (error) {
  console.error('Warning: Could not load echo configuration in build');
  echoConstants = null;
}
interface BuildConfig {
  sourceDir: string;
  outputFile: string;
  outputDir: string;
  instructionsDir: string;
  echoProtocolDir: string;
  echos: EchoConfig[];
}

interface StepData {
  name?: string;
  title?: string;
  goal?: string;
  description?: string;
  process?: string;
  validation?: string | string[];
  output?: string;
  expected_output?: string;
  critical_instruction?: string;
}

interface ExampleData {
  title?: string;
  name?: string;
  description?: string;
}

function validateEchoData(echo: Partial<EchoConfig & EchoData>, name: string): boolean {
  if (!echo || typeof echo !== 'object') return false;
  if (!echo.purpose && !echo.objective && !echo.steps) return false;
  return true;
}

function safeReadFile(filePath: string, logger: winston.Logger, buildMetrics: BuildMetrics): string | null {
  if (!filePath || typeof filePath !== 'string') {
    logger.error('Invalid filePath argument', { filePath });
    buildMetrics.errors.push('Invalid filePath argument');
    return null;
  }
  try {
    try {
      return fs.readFileSync(filePath, 'utf8');
    } catch (err: any) {
      if (err.code === 'ENOENT') {
        logger.warn(`File not found: ${filePath}`);
        return null;
      }
      throw err;
    }
  } catch (error: any) {
    logger.error(`Error reading file ${filePath}:`, { error: error.message });
    buildMetrics.warnings.push(`File read error: ${path.basename(filePath)}`);
    return null;
  }
}

function generateStepsSection(
  steps: StepData[],
  mode: string,
  name: string,
  logger: winston.Logger,
  buildMetrics: BuildMetrics
): string {
  if (!steps || !Array.isArray(steps)) {
    logger.warn(`No valid steps found for echo: ${name}`);
    buildMetrics.warnings.push(`No steps: ${name}`);
    return '';
  }
  if (!mode || !name) {
    logger.warn('Missing mode or name in generateStepsSection');
    buildMetrics.warnings.push('Missing mode or name');
    return '';
  }
  const stepsSectionTitle = `${mode} Steps`;
  let markdown = `## ${stepsSectionTitle}\n\n`;
  steps.forEach((step, index) => {
    if (!step || typeof step !== 'object') {
      logger.warn(`Invalid step format in ${name}, step ${index + 1}`);
      buildMetrics.warnings.push(`Invalid step: ${name}[${index + 1}]`);
      return;
    }
    try {
      const stepTitle = step.name || step.title || step.goal || `Step ${index + 1}`;
      markdown += `${index + 1}. **${stepTitle}**\n\n`;
      if (step.description || step.process || step.goal) {
        markdown += `   - ${step.description || step.process || step.goal}\n`;
      }
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
      if (step.output || step.expected_output) {
        markdown += `   - _Expected Output:_ ${step.output || step.expected_output}\n`;
      }
      if (step.critical_instruction) {
        markdown += `   - _Critical Instruction:_ ${step.critical_instruction}\n`;
      }
      markdown += '\n';
    } catch (stepError: any) {
      logger.error(`Error processing step ${index + 1} in ${name}`, { error: stepError.message });
      buildMetrics.errors.push(`Step error: ${name}[${index + 1}]`);
    }
  });
  return markdown;
}

function generateExamplesSection(examples: Array<string | ExampleData>): string {
  if (!examples || !Array.isArray(examples) || examples.length === 0) return '';
  let markdown = '\n## Examples\n\n';
  examples.forEach((example, index) => {
    if (!example) return;
    if (typeof example === 'string') {
      markdown += `### Example ${index + 1}\n\n${example}\n\n`;
    } else if (typeof example === 'object') {
      const exampleTitle = example.title || example.name || `Example ${index + 1}`;
      markdown += `### ${exampleTitle}\n\n`;
      if (example.description) {
        markdown += `${example.description}\n\n`;
      }
    }
  });
  return markdown + '\n';
}

function convertEchoToInstructionsFormat(
  echo: EchoData,
  config: EchoConfig,
  logger: winston.Logger,
  buildMetrics: BuildMetrics
): string {
  if (!echo || !config || !logger || !buildMetrics) {
    if (logger) logger.error('Missing arguments in convertEchoToInstructionsFormat');
    if (buildMetrics) buildMetrics.errors.push('Missing arguments in convertEchoToInstructionsFormat');
    return generateFallbackContent(config?.name || 'unknown', config);
  }

  const { name, trigger } = config;
  
  try {
    logger.debug(`Converting echo to instructions format: ${name}`);
    
    // Validate required data
    if (!validateEchoData(echo, name)) {
      logger.error(`Invalid echo data for ${name}: not an object or missing required fields`);
      buildMetrics.errors.push(`Invalid echo data: ${name}`);
      return generateFallbackContent(name, config);
    }
    
    // Extract mode from echo data, fallback to config, then capitalize name
    const mode = (echo as any).mode || 
                 ((echo as any).echo && (echo as any).echo.includes('–') ? (echo as any).echo.split('–')[1].trim() : null) || 
                 `${name.charAt(0).toUpperCase() + name.slice(1)}`;
    
    let markdown = `---\napplyTo: '**'\n---\n\n`;
    
    // Title handling with validation
    const echoTitle = (echo as any).echo || echo.name || `${name.charAt(0).toUpperCase() + name.slice(1)} Echo`;
    markdown += `# Copilot Instructions: ${echoTitle}\n\n`;
    
    // Purpose section with fallback
    markdown += '## Purpose\n\n';
    const purposeText = echo.purpose || echo.objective || `Perform ${name} analysis on code and development tasks`;
    markdown += `${purposeText}\n\n`;
    
    // When to trigger section
    markdown += '## When to Trigger\n\n';
    const triggerText = (echo as any).trigger || (echo as any).trigger_context || (echo as any).when || 
                       `Use these instructions when ${name} analysis is needed`;
    markdown += `${triggerText}\n\n`;
    
    // Steps section with comprehensive validation
    if (echo.steps && Array.isArray(echo.steps)) {
      markdown += generateStepsSection(echo.steps, mode, name, logger, buildMetrics);
    } else if (echo.steps) {
      logger.warn(`Steps field is not an array in ${name}`);
      buildMetrics.warnings.push(`Invalid steps format: ${name}`);
    }
    
    // Output format section with validation
    if ((echo as any).output_format || (echo as any).output) {
      logger.debug(`Adding Output Format section for ${name}`);
      markdown += '## Output Format\n\n';
      
      if ((echo as any).output_format?.structure && typeof (echo as any).output_format.structure === 'object') {
        logger.debug(`Using structured output format for ${name}`);
        markdown += 'Structured analysis with:\n';
        Object.entries((echo as any).output_format.structure).forEach(([key, value]) => {
          if (key && value) {
            markdown += `• ${key}: ${value}\n`;
          }
        });
      } else if ((echo as any).output || (echo as any).output_format) {
        const outputText = (echo as any).output || (typeof (echo as any).output_format === 'string' ? (echo as any).output_format : '');
        logger.debug(`Using simple output format for ${name}: "${outputText}"`);
        if (outputText) {
          markdown += `${outputText}\n`;
        }
      }
      markdown += '\n';
    } else {
      logger.debug(`No output format found for ${name}`);
    }
    
    // Additional sections with validation
    if ((echo as any).examples && Array.isArray((echo as any).examples) && (echo as any).examples.length > 0) {
      markdown += generateExamplesSection((echo as any).examples);
    }
    
    logger.debug(`Successfully converted echo: ${name} (${markdown.length} chars)`);
    buildMetrics.totalOutputSize += markdown.length;
    return markdown;
    
  } catch (error: any) {
    logger.error(`Error converting echo ${name} to instructions format`, { 
      error: error.message,
      stack: error.stack 
    });
    buildMetrics.errors.push(`Conversion error: ${name}`);
    return generateFallbackContent(name, config);
  }
}

function buildIndividualInstructions(
  config: BuildConfig, 
  loadYamlFile: (filePath: string) => EchoData | null, 
  logger: winston.Logger, 
  buildMetrics: BuildMetrics
): void {
  if (!config || !loadYamlFile || !logger || !buildMetrics) {
    if (logger) logger.error('Missing arguments in buildIndividualInstructions');
    if (buildMetrics) buildMetrics.errors.push('Missing arguments in buildIndividualInstructions');
    return;
  }
  
  logger.info('🔨 Building individual instruction files...');
  
  try {
    // Ensure instructions directory exists
    if (!fs.existsSync(config.instructionsDir)) {
      fs.mkdirSync(config.instructionsDir, { recursive: true });
      logger.info(`Created instructions directory: ${config.instructionsDir}`);
    }
    
    // Process each echo configuration
    config.echos.forEach(echoConfig => {
      if (!echoConfig || !echoConfig.name || !echoConfig.file) {
        logger.warn('Invalid echoConfig entry', { echoConfig });
        buildMetrics.warnings.push('Invalid echoConfig entry');
        return;
      }
      try {
        const echoPath = path.join(config.echoProtocolDir, echoConfig.file);
        logger.debug(`Processing echo: ${echoConfig.name} from ${echoPath}`);
        let echoData = loadYamlFile(echoPath);
        // Validate YAML after loading
        if (echoData) {
          validateEchoYaml(echoData, buildMetrics);
        }
        if (!echoData) {
          logger.error(`Failed to load echo data for ${echoConfig.name}`);
          buildMetrics.errors.push(`Failed to load: ${echoConfig.name}`);
          
          // Generate fallback content
          echoData = { 
            purpose: `Perform ${echoConfig.name} analysis`, 
            steps: [{ name: 'Analysis Step', description: `Execute ${echoConfig.name} methodology` }] 
          };
          logger.info(`Generated fallback content for ${echoConfig.name}`);
        }
        const fileName = `${echoConfig.name}${echoConstants?.getFileExtension() || '.prompt.md'}`;
        const instructionContent = convertEchoToInstructionsFormat(echoData, echoConfig, logger, buildMetrics);
        const outputPath = path.join(config.instructionsDir, fileName);
        fs.writeFileSync(outputPath, instructionContent, 'utf8');
        logger.info(`✅ Generated: ${fileName}`);
        buildMetrics.processedFiles.push(echoConfig.name);
      } catch (echoError: any) {
        logger.error(`Error processing echo ${echoConfig.name}`, { error: echoError.message, stack: echoError.stack });
        buildMetrics.errors.push(`Echo processing: ${echoConfig.name}`);
      }
    });
    
    logger.info(`📦 Individual instructions complete: ${buildMetrics.processedFiles.length} files`);
  } catch (error: any) {
    logger.error('Fatal error building individual instructions', { error: error.message, stack: error.stack });
    throw error;
  }
}

function buildInstructions(
  config: BuildConfig, 
  loadYamlFile: (filePath: string) => EchoData | null, 
  logger: winston.Logger, 
  buildMetrics: BuildMetrics,
  getEchoCategory: (name: string) => string
): void {
  if (!config || !loadYamlFile || !logger || !buildMetrics || !getEchoCategory) {
    if (logger) logger.error('Missing arguments in buildInstructions');
    if (buildMetrics) buildMetrics.errors.push('Missing arguments in buildInstructions');
    return;
  }
  
  logger.info('🔨 Building copilot instructions index...');
  
  try {
    const headerPath = path.join(config.sourceDir, 'header.md');
    const headerContent = safeReadFile(headerPath, logger, buildMetrics) || '';
    if (headerContent) logger.debug(`Loaded header content: ${headerContent.length} chars`);
    
    let echoIndex = '\n## Available Echos for Development\n\n<!-- Echos will be inserted here by build script -->\n\n';
    
    if (!Array.isArray(config.echos)) {
      logger.error('config.echos is not an array');
      buildMetrics.errors.push('config.echos is not an array');
      return;
    }
    
    config.echos.forEach(echoConfig => {
      if (!echoConfig || !echoConfig.name || !echoConfig.file) {
        logger.warn('Invalid echoConfig entry', { echoConfig });
        buildMetrics.warnings.push('Invalid echoConfig entry');
        return;
      }
      try {
        const echoPath = path.join(config.echoProtocolDir, echoConfig.file);
        const echoData = loadYamlFile(echoPath);
        // Validate YAML after loading
        if (echoData) {
          validateEchoYaml(echoData, buildMetrics);
        }
        if (!echoData) {
          logger.warn(`Skipping echo index entry for ${echoConfig.name} (no data)`);
          buildMetrics.warnings.push(`Index skip: ${echoConfig.name}`);
          return;
        }
        const purpose = echoData.purpose || echoData.objective || 'Systematic analysis and recommendations';
        const category = getEchoCategory(echoConfig.name);
        echoIndex += `\n### ${echoConfig.emoji} **${echoConfig.name}** - ${category}\n`;
        echoIndex += `- **Trigger**: ${echoConfig.trigger}\n`;
        echoIndex += `- **Purpose**: ${purpose}\n`;
        const echoNameSafe = (typeof echoConfig.name === 'string' && echoConfig.name.trim().length > 0) ? echoConfig.name : 'unknown';
        echoIndex += `- **File**: \`${echoConstants?.getEchoFilePath(echoNameSafe) || `.github/prompts/${echoNameSafe}.prompt.md`}\`\n`;
      } catch (indexError: any) {
        logger.error(`Error building index for ${echoConfig.name}`, { error: indexError.message });
        buildMetrics.errors.push(`Index error: ${echoConfig.name}`);
      }
    });
    
    const footerPath = path.join(config.sourceDir, 'footer.md');
    const footerContent = safeReadFile(footerPath, logger, buildMetrics) || '';
    if (footerContent) logger.debug(`Loaded footer content: ${footerContent.length} chars`);
    
    const finalContent = headerContent + echoIndex + footerContent;
    const outputPath = path.join(config.outputDir, config.outputFile);
    
    // Ensure output directory exists
    if (!fs.existsSync(config.outputDir)) {
      fs.mkdirSync(config.outputDir, { recursive: true });
      logger.info(`Created output directory: ${config.outputDir}`);
    }
    
    fs.writeFileSync(outputPath, finalContent, 'utf8');
    logger.info(`✅ Generated main instructions: ${config.outputFile}`);
    logger.debug(`Final content size: ${finalContent.length} chars`);
    buildMetrics.totalOutputSize += finalContent.length;
  } catch (error: any) {
    logger.error('Fatal error building instructions index', { error: error.message, stack: error.stack });
    throw error;
  }
}

export {
  BuildConfig,
  StepData,
  ExampleData,
  validateEchoData,
  safeReadFile,
  generateStepsSection,
  generateExamplesSection,
  convertEchoToInstructionsFormat,
  buildIndividualInstructions,
  buildInstructions
};
