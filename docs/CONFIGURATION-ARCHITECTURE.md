# Echo Configuration Architecture

This document describes the centralized configuration system for Echo Protocol paths, file extensions, and echo definitions.

## 📁 Configuration Files

### `config/echo-constants.json`

**Main configuration file** - Single source of truth for all echo-related constants:

```json
{
  "paths": {
    "github_dir": ".github",
    "prompts_dir": ".github/prompts",
    "copilot_instructions": ".github/copilot-instructions.md"
  },
  "files": {
    "extension": ".prompt.md",
    "copilot_filename": "copilot-instructions.md"
  },
  "echos": [
    {
      "name": "diagnostic",
      "file": "diagnostic/diagnostic-technical.prs.yaml",
      "emoji": "🛠️",
      "category": "Technical Debugging",
      "trigger": "Bugs, unexpected behavior, or technical issues"
    }
    // ... more echos
  ],
  "build": {
    "source_dir": "instructions-source",
    "echo_protocol_dir": "echos-sources",
    "output_file": "copilot-instructions.md"
  }
}
```

## 🔧 Configuration Utilities

### JavaScript/Node.js: `config/config-loader.js`

```javascript
const EchoConfig = require("./config/config-loader.js");
const config = new EchoConfig();

config.getPromptsDir(); // ".github/prompts"
config.getFileExtension(); // ".prompt.md"
config.getEchoFiles(); // ["diagnostic.prompt.md", ...]
config.getAllEchos(); // [{ name: "diagnostic", ... }, ...]
```

### Shell/Bash: `config/load-config.sh`

```bash
source config/load-config.sh

get_echo_files      # "diagnostic.prompt.md planning.prompt.md ..."
get_prompts_dir     # ".github/prompts"
get_file_extension  # ".prompt.md"
```

### PowerShell: `config/load-config.ps1`

```powershell
. ./config/load-config.ps1

Get-EchoFiles       # @("diagnostic.prompt.md", ...)
Get-PromptsDir      # ".github/prompts"
Get-FileExtension   # ".prompt.md"
```

## 🏗️ Build System Integration

### Automatic Build Config Generation

The build system automatically generates `scripts/build/build-config.json` from the centralized constants:

```bash
npm run config:generate  # Generate build-config.json
npm run build           # Auto-generates config, then builds
```

### Build Scripts Updated

- `scripts/build/echo-merge.ts` - Uses centralized paths and extensions
- `scripts/build/generate-build-config.js` - Generates build config from constants

## 📦 Installation Scripts Updated

### `install.js` (Node.js installer)

- Loads `config/config-loader.js` for echo files and paths
- Automatically adapts to configuration changes

### `install.sh` (Bash installer)

- Sources `config/load-config.sh` for shell functions
- Uses dynamic file lists and paths

### `install.ps1` (PowerShell installer)

- Uses `config/load-config.ps1` for PowerShell functions
- Configurable paths and extensions

### `install-local.sh` (Local development)

- Sources configuration utilities
- Dynamic path resolution

## ✅ Benefits

### 1. **Single Source of Truth**

- All paths, extensions, and echo definitions in one place
- No more scattered hardcoded values

### 2. **Easy Maintenance**

- Change file extension in one place → updates everywhere
- Add/remove echos in one configuration file

### 3. **Consistency Across Languages**

- JavaScript, Shell, and PowerShell all use same source
- Fallback values ensure compatibility

### 4. **Build Integration**

- Build configuration generated from constants
- No manual synchronization needed

## 🔄 Migration Benefits

**Before**: 60+ hardcoded references across 15+ files  
**After**: 1 configuration file + utilities

**Before**: Manual updates needed in multiple scripts  
**After**: Change once, applies everywhere

## 🚀 Usage Examples

### Adding a New Echo

1. Add to `config/echo-constants.json`:

```json
{
  "name": "newecho",
  "file": "newecho/newecho-mode.prs.yaml",
  "emoji": "🆕",
  "category": "New Category",
  "trigger": "When to use new echo"
}
```

2. Run build:

```bash
npm run build  # Automatically includes new echo everywhere
```

### Changing File Extension

1. Update `config/echo-constants.json`:

```json
{
  "files": {
    "extension": ".instruction.md" // Changed from .prompt.md
  }
}
```

2. All scripts automatically use new extension.

### Changing Directory Structure

1. Update `config/echo-constants.json`:

```json
{
  "paths": {
    "prompts_dir": ".github/instructions" // Changed directory
  }
}
```

2. All references update automatically.

---

This centralized architecture eliminates hardcoding and makes the entire echo system maintainable from a single configuration source.
