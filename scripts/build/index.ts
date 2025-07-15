// index.ts - Main build orchestrator for modular Echo Protocol build system

import logger from './logger';
import { handleError } from '../utils/error-handler';
import { fileExists } from './file-ops';
import { buildIndividualInstructions, buildInstructions, BuildConfig } from './echo-merge';
import { isValidEcho } from './validation';
import { createBuildMetrics, finalizeBuildMetrics, getMetricsReport, BuildMetrics } from './metrics';
import { loadYamlFile } from './yaml-loader';
import { getEchoCategory } from './utils';
import * as fs from 'fs';
import * as path from 'path';

function loadBuildConfig(): BuildConfig | null {
  // Search for real configuration file in instructions-source or scripts/build
  const configPaths = [
    path.join(__dirname, 'build-config.json'),
    path.join(__dirname, '../instructions-source/build-config.json')
  ];
  
  for (const configPath of configPaths) {
    if (fileExists(configPath)) {
      try {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8')) as BuildConfig;
        // Convert relative paths to absolute paths
        config.sourceDir = path.resolve(__dirname, config.sourceDir);
        config.outputDir = path.resolve(__dirname, config.outputDir);
        config.instructionsDir = path.resolve(__dirname, config.instructionsDir);
        config.echoProtocolDir = path.resolve(__dirname, config.echoProtocolDir);
        return config;
      } catch (e: any) {
        logger.error('Error parsing build config', { error: e.message });
      }
    }
  }
  
  logger.warn('No build config found, using default config');
  return null;
}

function printErrorsToStderr(errors: string[]) {
  if (errors && errors.length > 0) {
    errors.forEach(e => console.error('ERROR:', e));
  }
}

function main(): void {
  const buildMetrics: BuildMetrics = createBuildMetrics();
  logger.info('Starting modular build process...');

  try {
    // 1. Load real configuration
    const buildConfig = loadBuildConfig();
    if (!buildConfig) {
      logger.error('No build configuration found. Aborting build.');
      buildMetrics.errors.push('No build configuration found');
      finalizeBuildMetrics(buildMetrics);
      logger.info(getMetricsReport(buildMetrics));
      printErrorsToStderr(buildMetrics.errors);
      process.exit(1);
    }

    // 2. Validate echos defined in configuration
    if (!Array.isArray(buildConfig.echos) || buildConfig.echos.length === 0) {
      logger.error('No echos defined in build configuration.');
      buildMetrics.errors.push('No echos defined in build configuration');
      finalizeBuildMetrics(buildMetrics);
      logger.info(getMetricsReport(buildMetrics));
      printErrorsToStderr(buildMetrics.errors);
      process.exit(1);
    }

    // 3. Process and validate each echo
    buildConfig.echos.forEach((echoConfig: any) => {
      if (!isValidEcho(echoConfig)) {
        const echoName = (echoConfig && echoConfig.name) ? echoConfig.name : 'unnamed';
        logger.error(`Invalid echo config: ${echoName}`);
        buildMetrics.errors.push(`Invalid echo config: ${echoName}`);
        return;
      }
      // Note: processedFiles tracking happens during actual file generation in echo-merge.ts
    });

    // 4. Execute merge/instructions generation
    let hadCriticalError = false;
    try {
      // Build individual instruction files
      buildIndividualInstructions(
        buildConfig,
        (filePath: string) => loadYamlFile(filePath, logger, buildMetrics),
        logger,
        buildMetrics
      );

      // Build main instructions index
      buildInstructions(
        buildConfig,
        (filePath: string) => loadYamlFile(filePath, logger, buildMetrics),
        logger,
        buildMetrics,
        getEchoCategory
      );
    } catch (mergeErr: any) {
      logger.error('Error during echo merge/buildInstructions', { error: mergeErr.message });
      buildMetrics.errors.push('Error during echo merge/buildInstructions');
      hadCriticalError = true;
    }

    // 5. Finalize metrics and report
    finalizeBuildMetrics(buildMetrics);
    logger.info(getMetricsReport(buildMetrics));
    if (buildMetrics.errors.length > 0 || hadCriticalError) {
      printErrorsToStderr(buildMetrics.errors);
      process.exit(1);
    }
  } catch (err: any) {
    handleError(err, logger, buildMetrics);
    finalizeBuildMetrics(buildMetrics);
    logger.info(getMetricsReport(buildMetrics));
    printErrorsToStderr(buildMetrics.errors);
    process.exit(1);
  }
}

if (require.main === module) {
  // Handle command line arguments like the original build.js
  const args = process.argv.slice(2);

  if (args.length > 0) {
    // Check for specific build modes
    if (args.includes('--individual') || args.includes('-i')) {
      // Build individual instructions only
      const buildMetrics: BuildMetrics = createBuildMetrics();
      const buildConfig = loadBuildConfig();
      if (buildConfig) {
        buildIndividualInstructions(
          buildConfig,
          (filePath: string) => loadYamlFile(filePath, logger, buildMetrics),
          logger,
          buildMetrics
        );
        finalizeBuildMetrics(buildMetrics);
        logger.info(getMetricsReport(buildMetrics));
        if (buildMetrics.errors.length > 0) {
          printErrorsToStderr(buildMetrics.errors);
          process.exit(1);
        }
      }
    } else if (args.includes('--copilot') || args.includes('-c')) {
      // Build copilot instructions only
      const buildMetrics: BuildMetrics = createBuildMetrics();
      const buildConfig = loadBuildConfig();
      if (buildConfig) {
        buildInstructions(
          buildConfig,
          (filePath: string) => loadYamlFile(filePath, logger, buildMetrics),
          logger,
          buildMetrics,
          getEchoCategory
        );
        finalizeBuildMetrics(buildMetrics);
        logger.info(getMetricsReport(buildMetrics));
        if (buildMetrics.errors.length > 0) {
          printErrorsToStderr(buildMetrics.errors);
          process.exit(1);
        }
      }
    } else {
      // Default: run full build
      main();
    }
  } else {
    // No arguments: run full build
    main();
  }
}

// Export main functions for use by other modules if needed
export { buildIndividualInstructions, buildInstructions } from './echo-merge';
export { main as buildAll };
