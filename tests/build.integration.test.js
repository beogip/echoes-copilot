const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

describe('build.js integration', () => {
  const outputFile = path.join(__dirname, '..', '.github', 'copilot-instructions.md');

  test('build script completes successfully', () => {
    execFileSync('node', ['scripts/build.js', '--copilot'], { stdio: 'ignore' });
    expect(fs.existsSync(outputFile)).toBe(true);
  });
});
