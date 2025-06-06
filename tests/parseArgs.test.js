const { parseArgs } = require('../install');

function withArgs(args, fn) {
  const original = process.argv;
  process.argv = ['node', 'install.js', ...args];
  const result = fn();
  process.argv = original;
  return result;
}

describe('parseArgs', () => {
  test('returns defaults when no args provided', () => {
    const opts = withArgs([], () => parseArgs());
    expect(opts.mode).toBe('instructions');
    expect(opts.force).toBe(false);
    expect(opts.targetDir).toBe('.github');
  });

  test('parses provided options', () => {
    const opts = withArgs(['--mode', 'comprehensive', '--force', '--target', 'out', '--dry-run'], () => parseArgs());
    expect(opts.mode).toBe('comprehensive');
    expect(opts.force).toBe(true);
    expect(opts.targetDir).toBe('out');
    expect(opts.dryRun).toBe(true);
  });
});
