// validate-prs-yaml.ts - TypeScript migration of validate-prs-yaml.js
// Utility to validate PRS YAML files for Echo Protocol

import fs from 'fs';
import path from 'path';
import yaml from 'js-yaml';

interface ValidationResult {
  file: string;
  valid: boolean;
  errors?: string[];
}

function validateYamlFile(filePath: string): ValidationResult {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const data = yaml.load(content);
    // Basic validation: must be an object and have at least one key
    if (typeof data !== 'object' || data === null || Array.isArray(data)) {
      return { file: filePath, valid: false, errors: ['YAML root is not an object'] };
    }
    if (Object.keys(data).length === 0) {
      return { file: filePath, valid: false, errors: ['YAML object is empty'] };
    }
    // Add more schema checks as needed
    return { file: filePath, valid: true };
  } catch (err: any) {
    return { file: filePath, valid: false, errors: [err.message] };
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

function main() {
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0].endsWith('.yaml')) {
    // Validate a single YAML file
    const file = args[0];
    const result = validateYamlFile(file);
    if (!result.valid) {
      console.error(`❌ ${file}`);
      if (result.errors) result.errors.forEach(e => console.error('  -', e));
      console.log(`\nSummary: 1 file checked, 1 error found.`);
      process.exit(1);
    } else {
      console.log(`✅ ${file}`);
      console.log(`\nSummary: 1 file checked, 0 errors found.`);
      process.exit(0);
    }
  }
  // Default: validate all YAML files in directory
  const targetDir = args[0] || path.join(__dirname, '../echos-sources');
  const files = findYamlFiles(targetDir);
  console.log(`Validating ${files.length} .yaml files...`);
  let errors = 0;
  files.forEach((file) => {
    const result = validateYamlFile(file);
    if (!result.valid) {
      errors++;
      console.error(`❌ ${file}`);
      if (result.errors) result.errors.forEach(e => console.error('  -', e));
    } else {
      console.log(`✅ ${file}`);
    }
  });
  console.log(`\nSummary: ${files.length} files checked, ${errors} errors found.`);
  process.exit(errors > 0 ? 1 : 0);
}

if (require.main === module) {
  main();
}
