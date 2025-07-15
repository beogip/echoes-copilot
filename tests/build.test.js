const fs = require('fs');
const path = require('path');

describe('build/index.ts', () => {
  test('build/index.ts file exists', () => {
    const buildPath = path.join(__dirname, '../scripts/build/index.ts');
    expect(fs.existsSync(buildPath)).toBe(true);
  });
});
