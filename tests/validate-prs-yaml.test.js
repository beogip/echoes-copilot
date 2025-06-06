const path = require('path');
const { validateYaml } = require('../scripts/validate-prs-yaml');

describe('validate-prs-yaml.js', () => {
  test('valid YAML passes validation', () => {
    const file = path.join(__dirname, 'fixtures', 'valid.yaml');
    const result = validateYaml(file);
    expect(result.valid).toBe(true);
  });

  test('invalid YAML fails validation', () => {
    const file = path.join(__dirname, 'fixtures', 'invalid.yaml');
    const result = validateYaml(file);
    expect(result.valid).toBe(false);
  });

  test('duplicate keys fail validation', () => {
    const file = path.join(__dirname, 'fixtures', 'duplicate.yaml');
    const result = validateYaml(file);
    expect(result.valid).toBe(false);
  });
});
