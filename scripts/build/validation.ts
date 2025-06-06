// validation.ts - Echo Protocol validation utilities for build scripts

import { EchoConfig } from './utils';

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
function isValidEcho(echo: any): echo is EchoConfig | EchoData {
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
 * @returns Array of error messages (empty if valid).
 */
function validateEchoYaml(yamlData: any): string[] {
  const errors: string[] = [];
  if (!yamlData || typeof yamlData !== 'object') {
    errors.push('YAML data is not an object');
    return errors;
  }
  if (!yamlData.purpose && !yamlData.objective && !yamlData.steps) {
    errors.push('Missing required fields: purpose/objective/steps');
  }
  // Add more validation rules as needed
  return errors;
}

export {
  EchoData,
  isValidEcho,
  validateEchoYaml
};
