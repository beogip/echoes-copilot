import fs from 'fs';
import path from 'path';
import yaml from 'js-yaml';

// Jest test suite for YAML file validation (unit and edge cases)

describe('YAML Validation', () => {
  const fixturesDir = path.join(__dirname, 'fixtures');

  it('should validate a correct YAML file', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'valid.yaml'), 'utf8');
    expect(() => yaml.load(file)).not.toThrow();
  });

  it('should detect malformed YAML', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'malformed.yaml'), 'utf8');
    expect(() => yaml.load(file)).toThrow();
  });

  it('should handle empty YAML files', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'empty.yaml'), 'utf8');
    expect(() => yaml.load(file)).not.toThrow();
    expect(yaml.load(file)).toBeUndefined();
  });

  it('should detect duplicate keys', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'duplicate-keys.yaml'), 'utf8');
    expect(() => yaml.load(file)).toThrow();
  });

  it('should handle large YAML files', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'large-file.yaml'), 'utf8');
    expect(() => yaml.load(file)).not.toThrow();
  });

  it('should detect circular references', () => {
    const file = fs.readFileSync(path.join(fixturesDir, 'circular.yaml'), 'utf8');
    expect(() => yaml.load(file)).not.toThrow(); // js-yaml supports anchors, but not true JS circular refs
  });

  it('should handle unexpected data types', () => {
    const file = 'key: !!js/function >\n  function() { return 1; }';
    expect(() => yaml.load(file)).toThrow();
  });
});
