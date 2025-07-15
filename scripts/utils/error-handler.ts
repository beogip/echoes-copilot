// error-handler.ts - Error and warning logging helpers for build scripts
// (moved from build/ to utils/ for cross-script use)

import winston from 'winston';

export interface BuildMetrics {
  errors: string[];
  warnings: string[];
}

export const buildMetrics: BuildMetrics = {
  errors: [],
  warnings: []
};

export function handleError(error: Error, logger: winston.Logger, buildMetrics: BuildMetrics): void {
  logger.error('Fatal error occurred', { 
    error: error.message,
    stack: error.stack 
  });
  buildMetrics.errors.push(error.message);
}

export function logError(logger: winston.Logger, message: string | Error, context: Record<string, unknown> = {}): void {
  const messageStr = typeof message === 'string' ? message : message.message;
  logger.error(messageStr, context);
  buildMetrics.errors.push(messageStr);
}

export function logWarning(logger: winston.Logger, message: string | Error, context: Record<string, unknown> = {}): void {
  const messageStr = typeof message === 'string' ? message : message.message;
  logger.warn(messageStr, context);
  buildMetrics.warnings.push(messageStr);
}
