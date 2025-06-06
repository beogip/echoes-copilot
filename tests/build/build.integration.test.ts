import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

// Jest test suite for build integration scenarios

describe('Build Integration', () => {
  const buildScript = path.resolve(__dirname, '../../scripts/build.js');
  const fixturesDir = path.join(__dirname, 'fixtures');
  const validYaml = path.join(fixturesDir, 'valid.yaml');
  const malformedYaml = path.join(fixturesDir, 'malformed.yaml');
  const emptyYaml = path.join(fixturesDir, 'empty.yaml');

  // Helper to run build and get status/output
  function runBuild(args: string[]): { status: number, stdout: string, stderr: string } {
    const { spawnSync } = require('child_process');
    const result = spawnSync('node', [buildScript, ...args], { encoding: 'utf8' });
    return {
      status: result.status,
      stdout: result.stdout,
      stderr: result.stderr
    };
  }

  // Refactor: Use afterEach for temp files
  let tempFiles: string[] = [];
  afterEach(() => {
    for (const file of tempFiles) {
      if (fs.existsSync(file)) fs.unlinkSync(file);
    }
    tempFiles = [];
  });

  it('should complete the build process successfully with valid input', () => {
    const { status, stdout } = runBuild([validYaml]);
    expect(status).toBe(0);
    expect(stdout).toMatch(/build/i);
  });

  it('should fail gracefully with malformed YAML', () => {
    const { status, stderr } = runBuild([malformedYaml]);
    expect(status).not.toBe(0); // Should exit with error
    expect(stderr).toMatch(/ERROR:|yaml|invalid/i);
  });

  it('should handle empty YAML files gracefully', () => {
    const { status, stdout } = runBuild([emptyYaml]);
    expect(status).toBe(0);
    expect(stdout).toMatch(/build|empty|no data/i);
  });

  it('should warn or error on duplicate keys', () => {
    const duplicateKeysYaml = path.join(fixturesDir, 'duplicate-keys.yaml');
    const { status, stderr } = runBuild([duplicateKeysYaml]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|duplicate|key|invalid/i);
  });

  it('should process large YAML files efficiently', () => {
    const largeYaml = path.join(fixturesDir, 'large-file.yaml');
    const start = Date.now();
    const { status, stdout } = runBuild([largeYaml]);
    const duration = Date.now() - start;
    expect(status).toBe(0);
    expect(stdout).toMatch(/build|success|ok/i);
    expect(duration).toBeLessThan(2000);
  });

  it('should handle circular references gracefully', () => {
    const circularYaml = path.join(fixturesDir, 'circular.yaml');
    const { status, stderr } = runBuild([circularYaml]);
    // YAML circular references using anchors and aliases are valid YAML features
    // The build script should handle them successfully
    expect(status).toBe(0);
    // Should not have any error messages in stderr
    expect(stderr).not.toMatch(/ERROR:|error:/i);
  });

  it('should warn or error on unexpected data types', () => {
    const tempFile = path.join(fixturesDir, 'unexpected-type.yaml');
    fs.writeFileSync(tempFile, 'key: !!js/function >\n  function() { return 1; }');
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|type|function|invalid/i);
  });

  it('should error on nonexistent file', () => {
    const invalidPath = path.join(fixturesDir, 'nonexistent.yaml');
    const { status, stderr } = runBuild([invalidPath]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|not\s*found|no such file|invalid/i);
  });

  it('should error on file without permissions', () => {
    const tempFile = path.join(fixturesDir, 'no-permission.yaml');
    fs.writeFileSync(tempFile, 'key: value');
    fs.chmodSync(tempFile, 0o000);
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|permission|denied|invalid/i);
    fs.chmodSync(tempFile, 0o644);
  });

  it('should error on binary file', () => {
    const tempFile = path.join(fixturesDir, 'binary-file.bin');
    fs.writeFileSync(tempFile, Buffer.from([0x00, 0xff, 0x88, 0x99]));
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|binary|invalid/i);
  });

  it('should error on directory instead of file', () => {
    const { status, stderr } = runBuild([fixturesDir]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|is a directory|invalid/i);
  });

  it('should process multiple files in batch if supported', () => {
    const { status, stdout, stderr } = runBuild([validYaml, malformedYaml]);
    // There may be partial success or error, depending on implementation
    expect(stdout + stderr).toMatch(/build|error|yaml/i);
  });

  // You can add more tests for edge-cases and integration with other files/flags
});
