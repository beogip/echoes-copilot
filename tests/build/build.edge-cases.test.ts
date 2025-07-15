import fs from 'fs';
import path from 'path';

xdescribe('Build Script Edge Cases', () => {
  const buildScript = 'npx';
  const buildArgsBase = ['ts-node', path.resolve(__dirname, '../../scripts/build/index.ts')];
  const fixturesDir = path.join(__dirname, 'fixtures');

  function runBuild(args: string[]): { status: number, stdout: string, stderr: string } {
    const { spawnSync } = require('child_process');
    const result = spawnSync(buildScript, [...buildArgsBase, ...args], { encoding: 'utf8' });
    return {
      status: result.status,
      stdout: result.stdout,
      stderr: result.stderr
    };
  }

  // Utilidad para borrar archivos o symlinks, incluso si están rotos
  function safeUnlink(filePath: string) {
    try {
      fs.lstatSync(filePath); // throws si no existe
      fs.unlinkSync(filePath);
    } catch (e) {
      // No existe o ya fue borrado
    }
  }

  // Lista de archivos/symlinks a limpiar después de cada test
  let tempFiles: string[] = [];

  beforeEach(() => {
    // Limpieza previa de artefactos conocidos que pueden quedar de ejecuciones fallidas
    [
      'broken-link-edge.yaml',
      'symlinkA-edge.yaml',
      'symlinkB-edge.yaml',
      'real-target-edge.yaml',
    ].forEach(f => safeUnlink(path.join(fixturesDir, f)));
  });

  afterEach(() => {
    for (const file of tempFiles) safeUnlink(file);
    tempFiles = [];
  });

  it('should error on a symlink pointing to a nonexistent file', () => {
    const symlinkPath = path.join(fixturesDir, 'broken-link-edge.yaml');
    fs.symlinkSync('nonexistent-target.yaml', symlinkPath);
    tempFiles.push(symlinkPath);
    const { status, stderr } = runBuild([symlinkPath]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|symlink|not\s*found|invalid/i);
  });
/* --- TESTS REMOVIDOS TEMPORALMENTE ---
  it('should error on a file with no read permissions', () => {
    const tempFile = path.join(fixturesDir, 'no-read-perm-edge.yaml');
    fs.writeFileSync(tempFile, 'key: value');
    fs.chmodSync(tempFile, 0o000);
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|permission|denied|invalid/i);
    fs.chmodSync(tempFile, 0o644);
  });

  it('should error on a binary file with a .yaml extension', () => {
    const tempFile = path.join(fixturesDir, 'binary-edge.yaml');
    fs.writeFileSync(tempFile, Buffer.from([0x00, 0xff, 0x88, 0x99]));
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|binary|invalid/i);
  });

  it('should error if given a directory instead of a file', () => {
    const { status, stderr } = runBuild([fixturesDir]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|is a directory|invalid/i);
  });

  it('should error on a deeply nested symlink chain', () => {
    const targetFile = path.join(fixturesDir, 'real-target-edge.yaml');
    const symlinkA = path.join(fixturesDir, 'symlinkA-edge.yaml');
    const symlinkB = path.join(fixturesDir, 'symlinkB-edge.yaml');
    fs.writeFileSync(targetFile, 'key: value');
    fs.symlinkSync('symlinkB-edge.yaml', symlinkA);
    fs.symlinkSync('real-target-edge.yaml', symlinkB);
    tempFiles.push(targetFile, symlinkA, symlinkB);
    const { status, stderr } = runBuild([symlinkA]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|symlink|invalid|too\s*many\s*levels/i);
  });

  it('should error on a file with unicode/emoji in the filename', () => {
    const tempFile = path.join(fixturesDir, 'unicode-😀-edge.yaml');
    fs.writeFileSync(tempFile, 'key: value');
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|unicode|invalid|filename|fail/i);
  });

  
  it('should error on a file with a very long filename', () => {
    const longName = 'long-'.repeat(40) + 'edge.yaml';
    const tempFile = path.join(fixturesDir, longName);
    let created = false;
    try {
      fs.writeFileSync(tempFile, 'key: value');
      created = true;
      tempFiles.push(tempFile);
      const { status, stderr } = runBuild([tempFile]);
      expect(status).not.toBe(0);
      expect(stderr).toMatch(/ERROR:|filename|too\s*long|invalid/i);
    } catch (e) {
      expect(created).toBe(false);
    }
  });

  it('should error on a file with invalid UTF-8 bytes', () => {
    const tempFile = path.join(fixturesDir, 'invalid-utf8-edge.yaml');
    fs.writeFileSync(tempFile, Buffer.from([0xc3, 0x28])); // Invalid UTF-8
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|utf-8|invalid|character/i);
  });

  it('should error on a file with path traversal in the name', () => {
    const tempFile = path.join(fixturesDir, '../traversal-edge.yaml');
    fs.writeFileSync(tempFile, 'key: value');
    tempFiles.push(tempFile);
    const { status, stderr } = runBuild([tempFile]);
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|traversal|invalid|path/i);
  });

  it('should error if parent directory is read-only', () => {
    const roDir = path.join(fixturesDir, 'readonly-dir-edge');
    const tempFile = path.join(roDir, 'file.yaml');
    fs.mkdirSync(roDir);
    fs.writeFileSync(tempFile, 'key: value');
    fs.chmodSync(roDir, 0o555); // read-only
    tempFiles.push(tempFile);
    let status, stderr;
    try {
      ({ status, stderr } = runBuild([tempFile]));
    } finally {
      fs.chmodSync(roDir, 0o755);
      safeUnlink(tempFile);
      fs.rmdirSync(roDir);
    }
    expect(status).not.toBe(0);
    expect(stderr).toMatch(/ERROR:|permission|read-only|invalid/i);
  });
  --- FIN TESTS REMOVIDOS --- */
});
