// metrics.ts - Build performance and metrics collection utilities

/**
 * Interface for build metrics tracking
 */
interface BuildMetrics {
  processedFiles: string[];
  errors: string[];
  warnings: string[];
  totalOutputSize: number;
  startTime: number;
  endTime: number | null;
  durationMs?: number;
}

/**
 * Initializes a metrics object for build tracking.
 * @returns Metrics object with default counters and arrays.
 */
function createBuildMetrics(): BuildMetrics {
  return {
    processedFiles: [],
    errors: [],
    warnings: [],
    totalOutputSize: 0,
    startTime: Date.now(),
    endTime: null
  };
}

/**
 * Finalizes metrics, setting end time and calculating duration.
 * @param metrics - The metrics object to finalize.
 */
function finalizeBuildMetrics(metrics: BuildMetrics): void {
  if (!metrics || typeof metrics !== 'object') return;
  metrics.endTime = Date.now();
  metrics.durationMs = metrics.endTime - (metrics.startTime || metrics.endTime);
}

/**
 * Generates a summary report from the metrics object.
 * @param metrics - The metrics object.
 * @returns Human-readable summary.
 */
function getMetricsReport(metrics: BuildMetrics): string {
  if (!metrics || typeof metrics !== 'object') return 'No metrics available.';
  return `Build processed ${metrics.processedFiles.length} files, ${metrics.errors.length} errors, ${metrics.warnings.length} warnings, total output size: ${metrics.totalOutputSize} bytes, duration: ${metrics.durationMs || 0} ms.`;
}

export {
  BuildMetrics,
  createBuildMetrics,
  finalizeBuildMetrics,
  getMetricsReport
};
