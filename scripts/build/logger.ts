// logger.ts - Winston logger setup and helpers for build scripts

import winston from 'winston';
import path from 'path';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    process.env.WINSTON_TIMESTAMP_FORMAT?.startsWith('fixed:')
      ? winston.format.timestamp({ format: () => process.env.WINSTON_TIMESTAMP_FORMAT!.replace('fixed:', '') })
      : winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.errors({ stack: true })
  ),
  transports: [
    new winston.transports.Console({
      stderrLevels: ['error', 'warn'],
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, stack }) => {
          return `${timestamp} [${level}]: ${message}${stack ? '\n' + stack : ''}`;
        })
      )
    }),
    new winston.transports.File({
      filename: path.join(__dirname, '..', '..', 'logs', 'build.log'),
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    })
  ]
});

export default logger;
