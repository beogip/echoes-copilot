const fs = require('fs');
const path = require('path');
const os = require('os');
const { detectDuplicateKeys, findYamlFiles } = require('../scripts/validate-prs-yaml');

describe('validate-prs-yaml utilities', () => {
  test('detectDuplicateKeys reports duplicates', () => {
    const yamlContent = 'foo: 1\nbar: 2\nfoo: 3\n';
    const result = detectDuplicateKeys(yamlContent);
    expect(result).toEqual(["Duplicate key 'foo' at line 3"]);
  });

  test('findYamlFiles finds .prs.yaml recursively', () => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'yaml-test-'));
    const nested = path.join(tmpDir, 'sub');
    fs.mkdirSync(nested);
    const file1 = path.join(tmpDir, 'a.prs.yaml');
    const file2 = path.join(nested, 'b.prs.yaml');
    const other = path.join(tmpDir, 'c.txt');
    fs.writeFileSync(file1, 'name: a');
    fs.writeFileSync(file2, 'name: b');
    fs.writeFileSync(other, 'text');
    const files = findYamlFiles(tmpDir).map(p => path.basename(p)).sort();
    expect(files).toEqual(['a.prs.yaml', 'b.prs.yaml']);
    fs.rmSync(tmpDir, { recursive: true, force: true });
  });
});
