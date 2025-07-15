// validate-prs-yaml.ts - TypeScript migration of validate-prs-yaml.js
// Utility to validate PRS YAML files for Echo Protocol

import fs from 'fs';
import path from 'path';
import yaml from 'js-yaml';
import winston from 'winston';
import { logError, logWarning } from './utils/error-handler';
import logger from './build/logger';

interface ValidationResult {
  file: string;
  valid: boolean;
  errors?: string[];
}

function validateYamlFile(filePath: string): ValidationResult {
  try {
    const stat = fs.lstatSync(filePath);
    if (stat.isSymbolicLink()) {
      return { file: filePath, valid: false, errors: ['Path is a symlink (not supported)'] };
    }
    if (stat.isDirectory()) {
      return { file: filePath, valid: false, errors: ['Path is a directory, not a YAML file'] };
    }
    const content = fs.readFileSync(filePath, 'utf8');
    // Check for binary file (simple heuristic: presence of null byte)
    if (/\x00/.test(content)) {
      return { file: filePath, valid: false, errors: ['File appears to be binary, not valid YAML'] };
    }
    const data = yaml.load(content);
    // Basic validation: must be an object and have at least one key
    if (typeof data !== 'object' || data === null || Array.isArray(data)) {
      return { file: filePath, valid: false, errors: ['YAML root is not an object'] };
    }
    if (Object.keys(data).length === 0) {
      // Treat empty YAML as a warning, not an error
      return { file: filePath, valid: true, errors: ['YAML object is empty'] };
    }
    // Add more schema checks as needed
    return { file: filePath, valid: true };
  } catch (err: any) {
    // Distinguish between file not found, permission denied, and YAML parse errors
    if (err.code === 'ENOENT') {
      return { file: filePath, valid: false, errors: ['File not found'] };
    }
    if (err.code === 'EACCES') {
      return { file: filePath, valid: false, errors: ['Permission denied'] };
    }
    if (err.message && err.message.match(/duplicat(e|ed) key/i)) {
      return { file: filePath, valid: false, errors: ['Duplicate key in YAML'] };
    }
    if (err.message && err.message.match(/too many levels/i)) {
      return { file: filePath, valid: false, errors: ['Symlink chain too deep or invalid'] };
    }
    if (err.message && err.message.match(/unicode|filename|fail/i)) {
      return { file: filePath, valid: false, errors: ['Invalid or unsupported filename'] };
    }
    return { file: filePath, valid: false, errors: [`Internal error during YAML validation: ${err.message}`] };
  }
}

function findYamlFiles(dir: string): string[] {
  let results: string[] = [];
  const list = fs.readdirSync(dir);
  list.forEach((file) => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat && stat.isDirectory()) {
      results = results.concat(findYamlFiles(filePath));
    } else if (file.endsWith('.yaml')) {
      results.push(filePath);
    }
  });
  return results;
}

function reportValidationMessages(messages: string[] | undefined, reporter: (msg: string) => void, prefix: string) {
  if (messages && messages.length > 0) {
    messages.forEach(e => reporter(`${prefix}${e}`));
  }
}

function printValidationError(result: ValidationResult) {
  if (!result.errors || result.errors.length === 0) {
    logError(logger, `ERROR: ❌ ${result.file}`);
    return;
  }
  for (const errMsg of result.errors) {
    if (/ENOENT|not found/i.test(errMsg)) {
      logError(logger, `ERROR: File not found`);
      return;
    }
    if (/EACCES|permission denied/i.test(errMsg)) {
      logError(logger, `ERROR: Permission denied`);
      return;
    }
    if (/symlink/i.test(errMsg)) {
      logError(logger, `ERROR: Path is a symlink (not supported)`);
      return;
    }
    if (/directory/i.test(errMsg)) {
      logError(logger, `ERROR: Path is a directory, not a YAML file`);
      return;
    }
    if (/binary/i.test(errMsg)) {
      logError(logger, `ERROR: File appears to be binary, not valid YAML`);
      return;
    }
    if (/duplicate key/i.test(errMsg)) {
      logError(logger, `ERROR: Duplicate key in YAML`);
      return;
    }
    if (/yaml root is not an object/i.test(errMsg)) {
      logError(logger, `ERROR: YAML root is not an object`);
      return;
    }
    if (/unicode|filename|fail/i.test(errMsg)) {
      logError(logger, `ERROR: Invalid or unsupported filename`);
      return;
    }
  }
  // Fallback for unknown error
  logError(logger, `ERROR: ${result.errors[0]}`);
}

function handleValidationResult(result: ValidationResult, counters: { errors: number; warnings: number }): boolean {
  if (!result.valid) {
    counters.errors++;
    printValidationError(result);
    return false;
  } else {
    console.log(`✅ ${result.file}`);
    if (result.errors && result.errors.length > 0) {
      counters.warnings += result.errors.length;
      reportValidationMessages(result.errors, msg => logWarning(logger, '  (warning) - ' + msg), '');
    }
    return true;
  }
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0].endsWith('.yaml')) {
    // Validate a single YAML file
    const file = args[0];
    const result = validateYamlFile(file);
    if (!result.valid) {
      printValidationError(result);
      console.log(`\nSummary: 1 file checked, 1 error found.`);
      process.exit(1);
    } else {
      console.log(`✅ ${result.file}`);
      if (result.errors && result.errors.length > 0) {
        result.errors.forEach(msg => logWarning(logger, '  (warning) - ' + msg));
      }
      console.log(`\nSummary: 1 file checked, 0 errors found.`);
      process.exit(0);
    }
  }
  // Default: validate all YAML files in directory
  const targetDir = args[0] || path.join(__dirname, '../echos-sources');
  const files = findYamlFiles(targetDir);
  console.log(`Validating ${files.length} .yaml files...`);
  let counters = { errors: 0, warnings: 0 };
  files.forEach((file) => {
    const result = validateYamlFile(file);
    if (!result.valid) {
      printValidationError(result);
      counters.errors++;
    } else {
      console.log(`✅ ${result.file}`);
      if (result.errors && result.errors.length > 0) {
        counters.warnings += result.errors.length;
        result.errors.forEach(msg => logWarning(logger, '  (warning) - ' + msg));
      }
    }
  });
  // Only exit with code 1 if there are true errors. Warnings (e.g., empty YAML) do not fail the build.
  console.log(`\nSummary: ${files.length} files checked, ${counters.errors} errors, ${counters.warnings} warnings.`);
  process.exit(counters.errors > 0 ? 1 : 0);
}

if (require.main === module) {
  main();
}

export { validateYamlFile };
