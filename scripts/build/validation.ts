// validation.ts - Echo Protocol validation utilities for build scripts

import { EchoConfig } from './utils';
import { validateYamlFile } from '../validate-prs-yaml';

/**
 * Interface for Echo Protocol data structure
 */
interface EchoData {
  id?: string;
  purpose?: string;
  objective?: string;
  steps?: Array<any>;
  name?: string;
  file?: string;
  trigger?: string;
  output?: string;
  examples?: Array<any>;
}

/**
 * Validates the structure and required fields of an Echo Protocol object.
 * @param echo - The echo object to validate.
 * @returns True if valid, false otherwise.
 */
function isValidEcho(echo: Partial<EchoConfig & EchoData>): echo is EchoConfig | EchoData {
  if (!echo || typeof echo !== 'object') return false;
  
  // Validate echo configuration (not echo data)
  if (echo.name && echo.file && echo.trigger) return true;
  
  // Validate echo data structure
  if (!echo.purpose && !echo.objective && !echo.steps) return false;
  
  return true;
}

/**
 * Validates a YAML file's contents for Echo Protocol compliance.
 * @param yamlData - Parsed YAML object.
 * @param buildMetrics - Optional build metrics object to push errors to.
 * @returns Array of error messages (empty if valid).
 */
function validateEchoYaml(
  yamlData: Partial<EchoConfig & EchoData>,
  buildMetrics?: { errors: string[], warnings?: string[] }
): string[] {
  // Use the same validation as validate-prs-yaml
  const tmpFile = '.tmp-echo-validation.yaml';
  const fs = require('fs');
  const yaml = require('js-yaml');
  let errors: string[] = [];
  let warnings: string[] = [];
  try {
    fs.writeFileSync(tmpFile, yaml.dump(yamlData), 'utf8');
    const result = require('../validate-prs-yaml').validateYamlFile(tmpFile);
    if (!result.valid && result.errors) {
      // Only treat as error if not an empty file warning
      const realErrors = result.errors.filter((e: string) => !/empty|whitespace/i.test(e));
      const realWarnings = result.errors.filter((e: string) => /empty|whitespace/i.test(e));
      errors = realErrors;
      warnings = realWarnings;
      if (buildMetrics) {
        if (realErrors.length > 0) buildMetrics.errors.push(...realErrors);
        if (realWarnings.length > 0 && buildMetrics.warnings) buildMetrics.warnings.push(...realWarnings);
      }
    }
    fs.unlinkSync(tmpFile);
  } catch (e: any) {
    errors.push('Internal error during YAML validation: ' + e.message);
    if (buildMetrics) buildMetrics.errors.push('Internal error during YAML validation: ' + e.message);
  }
  // Additional echo-specific checks (legacy)
  if (!yamlData || typeof yamlData !== 'object') {
    errors.push('YAML data is not an object');
    if (buildMetrics) buildMetrics.errors.push('YAML data is not an object');
    return errors;
  }
  if (!yamlData.purpose && !yamlData.objective && !yamlData.steps) {
    errors.push('Missing required fields: purpose/objective/steps');
    if (buildMetrics) buildMetrics.errors.push('Missing required fields: purpose/objective/steps');
  }
  return errors;
}

export {
  EchoData,
  isValidEcho,
  validateEchoYaml
};
