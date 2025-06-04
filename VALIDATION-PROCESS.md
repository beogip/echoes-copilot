# YAML Validation Process Documentation

## Overview

This document outlines the YAML validation process implemented for the Echo Protocol Integration project to ensure the integrity of `.prs.yaml` files in the build system.

## Validation Tools

### 1. Automated YAML Validator (`scripts/validate-prs-yaml.js`)

**Purpose**: Validates all `.prs.yaml` files in the `echos-sources/` directory using the `js-yaml` parser.

**Usage**:

```bash
npm run validate:prs
```

**Features**:

- Recursive scanning of all `.prs.yaml` files
- Detailed error reporting with line numbers
- Summary statistics (total files checked, errors found)
- Exit code 1 on validation errors for CI/CD integration

### 2. Build System Integration

The validation is integrated into the build process:

- `npm run build` - Builds the project (includes internal YAML parsing)
- `npm run validate:prs` - Standalone validation check

## Validation Process

### Step 1: Run Validation

```bash
cd /path/to/project
npm run validate:prs
```

### Step 2: Review Results

✅ **Success**: All files validated successfully

```
Summary: 17 files checked, 0 errors found.
```

❌ **Errors Found**: Fix reported issues

```
❌ /path/to/file.prs.yaml
   Error: bad indentation of a mapping entry at line 51, column 47
```

### Step 3: Fix Issues

Common YAML errors:

- **Indentation errors**: Ensure consistent spacing (2 spaces recommended)
- **Duplicate keys**: Remove or rename duplicate keys
- **Invalid syntax**: Check colons, quotes, and special characters

### Step 4: Re-validate

Re-run validation after fixes until all files pass.

## File Structure

```
scripts/
├── validate-prs-yaml.js    # Main validation script
└── build.js                # Build system (moved from build/)

echos-sources/
├── audit/
├── coherence/
├── diagnostic/
├── evaluation/
├── execution/
├── optimization/
├── planning/
├── prioritization/
└── [other echo folders]/
    └── *.prs.yaml          # Files validated by this process
```

## Historical Issues Resolved

### M1.1 Completion (June 4, 2025)

- **Issue**: Single YAML parsing error in `execution-prompt.prs.yaml`
- **Location**: Line 51, column 47 (bad indentation)
- **Resolution**: Manual indentation correction
- **Prevention**: Automated validation tooling implemented

### Build System Improvements

- **Issue**: Build system continued with warnings instead of failing on YAML errors
- **Resolution**: Separate validation step provides clear error reporting
- **Benefit**: Early detection of YAML issues before build process

## Maintenance

### Adding New Echo Files

1. Create new `.prs.yaml` files in appropriate `echos-sources/` subdirectories
2. Run `npm run validate:prs` to ensure syntax validity
3. Run `npm run build` to verify integration

### Troubleshooting

- **File not found errors**: Check that `validate-prs-yaml.js` uses correct relative paths
- **Permission errors**: Ensure script has read access to `echos-sources/` directory
- **Module errors**: Verify `js-yaml` dependency is installed (`npm install`)

### CI/CD Integration

The validation script exits with code 1 on errors, making it suitable for CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Validate YAML files
  run: npm run validate:prs
```

## Dependencies

- **js-yaml**: YAML parser and validator
- **Node.js**: Runtime environment
- **fs/path**: File system operations

## Future Improvements

- **Schema validation**: Add PRS-specific schema validation
- **Auto-fix**: Implement automatic indentation correction
- **Watch mode**: Real-time validation during development
- **IDE integration**: VS Code extension for live validation

---

_This documentation was created as part of M1.1 completion on June 4, 2025._
