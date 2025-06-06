import fs from 'fs';
import path from 'path';

// Jest test suite for build performance scenarios

describe('Build Performance', () => {
  const buildScript = path.resolve(__dirname, '../../scripts/build.js');
  const fixturesDir = path.join(__dirname, 'fixtures');
  const largeYaml = path.join(fixturesDir, 'large-file.yaml');
  const validYaml = path.join(fixturesDir, 'valid.yaml');

  // Allow time/memory limits to be set via environment variables
  const TIME_LIMIT_LARGE = process.env.PERF_TIME_LARGE ? parseInt(process.env.PERF_TIME_LARGE) : 2000;
  const TIME_LIMIT_BATCH = process.env.PERF_TIME_BATCH ? parseInt(process.env.PERF_TIME_BATCH) : 3000;
  const TIME_LIMIT_PARALLEL = process.env.PERF_TIME_PARALLEL ? parseInt(process.env.PERF_TIME_PARALLEL) : 3000;
  const AVG_LIMIT_STRESS = process.env.PERF_AVG_STRESS ? parseInt(process.env.PERF_AVG_STRESS) : 500;

  // Helper to clean up temporary files
  let tempFiles: string[] = [];
  afterEach(() => {
    for (const file of tempFiles) {
      if (fs.existsSync(file)) fs.unlinkSync(file);
    }
    tempFiles = [];
  });

  function runBuild(args: string[]): { status: number, stdout: string, stderr: string, duration: number, memory: number } {
    const { spawnSync } = require('child_process');
    const start = process.hrtime.bigint();
    const memStart = process.memoryUsage().heapUsed;
    const result = spawnSync('node', [buildScript, ...args], { encoding: 'utf8' });
    const memEnd = process.memoryUsage().heapUsed;
    const end = process.hrtime.bigint();
    return {
      status: result.status,
      stdout: result.stdout,
      stderr: result.stderr,
      duration: Number(end - start) / 1e6, // ms
      memory: memEnd - memStart // bytes
    };
  }

  it('should process a large YAML file within time and memory limits', () => {
    const { status, duration, memory } = runBuild([largeYaml]);
    expect(status).toBe(0);
    expect(duration).toBeLessThan(TIME_LIMIT_LARGE);
    // Arbitrary memory limit: 100MB
    expect(memory).toBeLessThan(100 * 1024 * 1024);
    console.log(`[PERF] Large file: ${duration.toFixed(1)}ms, ${Math.round(memory/1024/1024)}MB`);
  });

  it('should process 100 small files in batch efficiently', () => {
    const files: string[] = [];
    for (let i = 0; i < 100; i++) {
      const file = path.join(fixturesDir, `small-${i}.yaml`);
      fs.writeFileSync(file, 'key: value');
      files.push(file);
      tempFiles.push(file);
    }
    const { status, duration } = runBuild(files);
    expect(status).toBe(0);
    expect(duration).toBeLessThan(TIME_LIMIT_BATCH);
    console.log(`[PERF] Batch 100 files: ${duration.toFixed(1)}ms`);
  });

  it('should handle 50 consecutive builds without degradation', () => {
    const times: number[] = [];
    for (let i = 0; i < 50; i++) {
      const { status, duration } = runBuild([validYaml]);
      expect(status).toBe(0);
      times.push(duration);
    }
    const avg = times.reduce((a, b) => a + b, 0) / times.length;
    expect(avg).toBeLessThan(AVG_LIMIT_STRESS); // ms average
    console.log(`[PERF] 50x stress avg: ${avg.toFixed(1)}ms`);
  });

  it('should not degrade performance with edge-case files', () => {
    const edgeFiles = [
      path.join(fixturesDir, 'malformed.yaml'),
      path.join(fixturesDir, 'duplicate-keys.yaml'),
      path.join(fixturesDir, 'circular.yaml'),
      path.join(fixturesDir, 'empty.yaml')
    ];
    const { duration } = runBuild(edgeFiles);
    expect(duration).toBeLessThan(TIME_LIMIT_LARGE);
    console.log(`[PERF] Edge-cases batch: ${duration.toFixed(1)}ms`);
  });

  it('should handle 5 parallel builds efficiently', (done) => {
    const files = Array(5).fill(validYaml);
    const { spawn } = require('child_process');
    let completed = 0;
    let errors = 0;
    const start = Date.now();
    for (let i = 0; i < 5; i++) {
      const child = spawn('node', [buildScript, files[i]], { encoding: 'utf8' });
      child.on('exit', (code: number) => {
        if (code !== 0) errors++;
        completed++;
        if (completed === 5) {
          const duration = Date.now() - start;
          expect(errors).toBe(0);
          expect(duration).toBeLessThan(TIME_LIMIT_PARALLEL);
          console.log(`[PERF] 5 parallel builds: ${duration}ms`);
          done();
        }
      });
    }
  });
});
