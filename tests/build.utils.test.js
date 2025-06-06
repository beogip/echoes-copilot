const fs = require('fs');
const path = require('path');
const os = require('os');
const { loadYamlFile } = require('../scripts/build');

describe('build.js utilities', () => {
  test('loadYamlFile returns null for missing file', () => {
    const result = loadYamlFile(path.join(__dirname, 'nonexistent.yaml'));
    expect(result).toBeNull();
  });

  test('loadYamlFile returns null for invalid YAML', () => {
    const tmpFile = path.join(os.tmpdir(), 'invalid.yaml');
    fs.writeFileSync(tmpFile, 'foo: [1,2');
    const result = loadYamlFile(tmpFile);
    expect(result).toBeNull();
    fs.unlinkSync(tmpFile);
  });

  test('loadYamlFile loads valid YAML', () => {
    const tmpFile = path.join(os.tmpdir(), 'valid.yaml');
    fs.writeFileSync(tmpFile, 'name: test');
    const result = loadYamlFile(tmpFile);
    expect(result).toEqual({ name: 'test' });
    fs.unlinkSync(tmpFile);
  });
});
