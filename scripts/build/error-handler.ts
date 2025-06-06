// error-handler.ts - Error and warning logging helpers for build scripts

import winston from 'winston';

interface BuildMetrics {
  errors: string[];
  warnings: string[];
}

const buildMetrics: BuildMetrics = {
  errors: [],
  warnings: []
};

function handleError(error: Error, logger: winston.Logger, buildMetrics: any): void {
  logger.error('Fatal error occurred', { 
    error: error.message,
    stack: error.stack 
  });
  buildMetrics.errors.push(error.message);
}

function logError(logger: winston.Logger, message: string | Error, context: any = {}): void {
  const messageStr = typeof message === 'string' ? message : message.message;
  logger.error(messageStr, context);
  buildMetrics.errors.push(messageStr);
}

function logWarning(logger: winston.Logger, message: string | Error, context: any = {}): void {
  const messageStr = typeof message === 'string' ? message : message.message;
  logger.warn(messageStr, context);
  buildMetrics.warnings.push(messageStr);
}

export {
  BuildMetrics,
  handleError,
  logError,
  logWarning,
  buildMetrics
};
