# Instructions Source

This directory contains the modular source files for building the final `copilot-instructions.md` file.

## Structure

- **`header.md`** - Introduction and context about Echo Protocol
- **`footer.md`** - Examples, best practices, and advanced usage
- **`echos/`** - Individual echo definitions (PRS versions)

## Building Instructions

The build script automatically:

1. **Loads header** from `header.md`
2. **Processes each echo** from the echo-protocol repository (PRS versions)
3. **Converts YAML to Markdown** with proper formatting
4. **Adds footer** from `footer.md`
5. **Generates** final `.github/copilot-instructions.md`

## Development Workflow

1. **Edit source files** in this directory
2. **Run build script**: `npm run build`
3. **Test with Copilot** using the generated instructions
4. **Iterate** as needed

## Echo Configuration

Echos are configured in `../build/build.js` with:

```javascript
{
  name: 'diagnostic',
  file: 'diagnostic-technical.prs.yaml',
  emoji: '🛠️',
  trigger: 'diagnostic'
}
```

The build script will:

- First try to load from `echo-protocol/echos/{name}/{file}`
- Fall back to local `echos/{name}.prs.yaml` if needed
- Convert YAML structure to Copilot-friendly Markdown

## Benefits

- **Modularity**: Edit individual components
- **Reusability**: Leverage official echo-protocol definitions
- **Maintainability**: Easier to update and version
- **Consistency**: Automated formatting and structure

## YAML Validation Utility

You can validate all echo YAML files or a single file for schema and formatting:

```bash
# Validate all .yaml files in echos-sources/
npx ts-node scripts/validate-prs-yaml.ts

# Validate a single file
e.g.
npx ts-node scripts/validate-prs-yaml.ts echos-sources/creativity/creativity-divergent.prs.es.yaml
```

- The validator reports formatting, object root, and YAML syntax errors.
- Useful for CI/CD, PR review, and local development.
