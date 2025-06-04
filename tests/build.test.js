const fs = require('fs');
const path = require('path');

describe('build.js', () => {
  test('build.js file exists', () => {
    const buildPath = path.join(__dirname, '../scripts/build.js');
    expect(fs.existsSync(buildPath)).toBe(true);
  });
});
