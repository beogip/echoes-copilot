// validate-prs-yaml.js
// Validates all .prs.yaml files in echos-sources/ using js-yaml

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

function findYamlFiles(dir) {
  let results = [];
  const list = fs.readdirSync(dir);
  list.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat && stat.isDirectory()) {
      results = results.concat(findYamlFiles(filePath));
    } else if (file.endsWith('.prs.yaml')) {
      results.push(filePath);
    }
  });
  return results;
}

function validateYaml(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    yaml.load(content);
    return { file: filePath, valid: true };
  } catch (e) {
    return { file: filePath, valid: false, error: e.message };
  }
}

const baseDir = path.join(__dirname, '..', 'echos-sources');
const files = findYamlFiles(baseDir);
let errorCount = 0;

console.log(`Validating ${files.length} .prs.yaml files...`);
files.forEach(f => {
  const result = validateYaml(f);
  if (result.valid) {
    console.log(`✅ ${result.file}`);
  } else {
    errorCount++;
    console.log(`❌ ${result.file}\n    Error: ${result.error}`);
  }
});
console.log(`\nSummary: ${files.length} files checked, ${errorCount} errors found.`);
process.exit(errorCount === 0 ? 0 : 1);
