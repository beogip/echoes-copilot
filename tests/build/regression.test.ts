// Jest regression tests for the build system
import fs from 'fs';
import path from 'path';

describe('Build Regression', () => {
  const buildScript = path.resolve(__dirname, '../../scripts/build.js');
  const fixturesDir = path.join(__dirname, 'fixtures');
  const validYaml = path.join(fixturesDir, 'valid.yaml');
  const malformedYaml = path.join(fixturesDir, 'malformed.yaml');
  const duplicateKeysYaml = path.join(fixturesDir, 'duplicate-keys.yaml');
  const largeYaml = path.join(fixturesDir, 'large-file.yaml');

  function runBuild(args: string[]): { status: number, stdout: string, stderr: string } {
    const { spawnSync } = require('child_process');
    const result = spawnSync('node', [buildScript, ...args], { 
      encoding: 'utf8',
      env: {
        ...process.env,
        WINSTON_TIMESTAMP_FORMAT: 'fixed:10:38:09'
      }
    });
    return {
      status: result.status,
      stdout: result.stdout,
      stderr: result.stderr
    };
  }

  it('should not break previous valid build scenarios (output regression)', () => {
    const { status, stdout } = runBuild([validYaml]);
    expect(status).toBe(0);
    expect(stdout).toMatchSnapshot('valid-yaml-build-output');
  });

  it('should maintain error output consistency for malformed YAML', () => {
    const { status, stderr } = runBuild([malformedYaml]);
    expect(status).not.toBe(0);
    expect(stderr).toMatchSnapshot('malformed-yaml-error-output');
  });

  it('should maintain error output consistency for duplicate keys', () => {
    const { status, stderr } = runBuild([duplicateKeysYaml]);
    expect(status).not.toBe(0);
    expect(stderr).toMatchSnapshot('duplicate-keys-error-output');
  });

  it('should not break on large YAML files (performance regression)', () => {
    const start = Date.now();
    const { status, stdout } = runBuild([largeYaml]);
    const duration = Date.now() - start;
    expect(status).toBe(0);
    expect(stdout).toMatchSnapshot('large-yaml-build-output');
    expect(duration).toBeLessThan(3000); // 3s threshold
  });
});
