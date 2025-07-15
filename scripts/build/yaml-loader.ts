// yaml-loader.ts - Enhanced YAML file loading with comprehensive error handling

import fs from 'fs';
import path from 'path';
import yaml from 'js-yaml';
import winston from 'winston';
import { BuildMetrics } from './metrics';
import { EchoData } from './validation';

/**
 * Enhanced YAML file loader with comprehensive error handling
 * @param filePath - Path to YAML file
 * @param logger - Logger instance
 * @param buildMetrics - Build metrics object
 * @returns Parsed YAML data or null on error
 */
function loadYamlFile(
  filePath: string,
  logger: winston.Logger,
  buildMetrics: BuildMetrics
): EchoData | null {
  if (!filePath || typeof filePath !== 'string') {
    logger.error('Invalid filePath argument for loadYamlFile');
    buildMetrics.errors.push('Invalid filePath argument');
    return null;
  }

  const fileName = path.basename(filePath);
  
  try {
    // Check file existence
    if (!fs.existsSync(filePath)) {
      logger.error(`File not found: ${filePath}`);
      buildMetrics.errors.push(`Missing file: ${fileName}`);
      return null;
    }

    // Check for symlink loop or hard link
    let stat: fs.Stats;
    try {
      stat = fs.lstatSync(filePath);
      if (stat.isSymbolicLink()) {
        // Detect symlink loop (points to itself or too many levels)
        const realPath = fs.realpathSync.native(filePath);
        if (realPath === filePath) {
          logger.error(`Symlink loop detected: ${filePath}`);
          buildMetrics.errors.push(`Symlink loop: ${fileName}`);
          return null;
        }
      }
      if (!stat.isFile()) {
        logger.error(`Not a regular file: ${filePath}`);
        buildMetrics.errors.push(`Not a regular file: ${fileName}`);
        return null;
      }
      if (stat.nlink > 1) {
        logger.error(`Hard link detected: ${filePath}`);
        buildMetrics.errors.push(`Hard link: ${fileName}`);
        return null;
      }
    } catch (statError: any) {
      logger.error(`Cannot stat file: ${filePath} (${statError.message})`);
      buildMetrics.errors.push(`Stat error: ${fileName}`);
      return null;
    }

    // Check file readability
    try {
      fs.accessSync(filePath, fs.constants.R_OK);
    } catch (accessError: any) {
      logger.error(`Cannot read file: ${filePath} (${accessError.message})`);
      buildMetrics.errors.push(`Unreadable file: ${fileName}`);
      return null;
    }

    // Check for suspicious filename (unicode, emoji, traversal)
    if (/[^\x00-\x7F]/.test(fileName) || /[\u{1F600}-\u{1F64F}]/u.test(fileName) || fileName.includes('..') || fileName.includes('/') || fileName.includes('\\')) {
      logger.error(`Suspicious or invalid filename: ${fileName}`);
      buildMetrics.errors.push(`Invalid filename: ${fileName}`);
      return null;
    }

    let content: Buffer;
    try {
      content = fs.readFileSync(filePath);
    } catch (readError: any) {
      logger.error(`Cannot read file: ${filePath} (${readError.message})`);
      buildMetrics.errors.push(`Read error: ${fileName}`);
      return null;
    }

    // Check for binary (non-UTF-8) or BOM
    if (content[0] === 0xef && content[1] === 0xbb && content[2] === 0xbf) {
      logger.error(`BOM detected in file: ${fileName}`);
      buildMetrics.errors.push(`BOM: ${fileName}`);
      return null;
    }
    if (content.some(b => b === 0x00)) {
      logger.error(`Binary file detected: ${fileName}`);
      buildMetrics.errors.push(`Binary file: ${fileName}`);
      return null;
    }

    let text: string;
    try {
      text = content.toString('utf8');
    } catch (utf8Error: any) {
      logger.error(`Invalid UTF-8 in file: ${fileName}`);
      buildMetrics.errors.push(`Invalid UTF-8: ${fileName}`);
      return null;
    }

    // Check for empty, whitespace, tabs, CRLF, only comments
    if (!text.trim() || /^\s+$/.test(text)) {
      logger.warn(`Empty or whitespace-only file: ${fileName}`);
      if (buildMetrics.warnings) buildMetrics.warnings.push(`Empty file: ${fileName}`);
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
      logger.warn(`File contains only comments or whitespace: ${fileName}`);
      if (buildMetrics.warnings) buildMetrics.warnings.push(`Comments only: ${fileName}`);
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
      logger.error(`CRLF line endings detected: ${fileName}`);
      buildMetrics.errors.push(`CRLF line endings: ${fileName}`);
      return null;
    }

    if (/^\t+$/.test(text)) {
      logger.error(`File contains only tabs: ${fileName}`);
      buildMetrics.errors.push(`Only tabs: ${fileName}`);
      return null;
    }

    // Try YAML parse
    let data: any;
    try {
      data = yaml.load(text);
    } catch (error: any) {
      logger.error(`YAML parse error in ${fileName}: ${error.message}`, { filePath: filePath, stack: error.stack });
      buildMetrics.errors.push(`YAML parse error: ${fileName}`);
      return null;
    }

    if (!data) {
      logger.error(`YAML file parsed to null/undefined: ${fileName}`);
      buildMetrics.errors.push(`Null YAML: ${fileName}`);
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

  } catch (error: any) {
    logger.error(`YAML parse error in ${fileName}: ${error.message}`, { filePath: filePath, stack: error.stack });
    buildMetrics.errors.push(`Parse error: ${fileName}`);
    return null;
  }
}

export {
  loadYamlFile
};
