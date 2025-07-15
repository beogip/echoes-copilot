# 📦 Installation Guide - Echo Protocol + GitHub Copilot

This guide provides comprehensive installation instructions for the Echo Protocol integration with GitHub Copilot. For project overview and concepts, see the [main README](README.md).

## 🎯 Prerequisites

Before installing, ensure you have:

- **Git** installed and configured
- **Node.js** (version 14 or higher) for JavaScript/TypeScript projects
- **GitHub Copilot** subscription and VS Code extension installed
- A **GitHub repository** or local project where you want to use Echo-enhanced Copilot

## 🚀 Installation Methods

### Method 1: Automatic Installation (Recommended)

The automatic installation script will:

- Download the latest Echo instructions
- Configure GitHub Copilot integration
- Create backups of existing configurations
- Set up your preferred installation mode

#### For Unix/macOS/Linux:

```bash
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.sh | bash
```

#### For Windows PowerShell:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/beogip/echos-copilot/main/install.ps1" -OutFile "install.ps1"
.\install.ps1
```

#### For Node.js (Cross-platform):

```bash
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.js | node
```

### Method 2: Local Installation (Development)

If you want to modify the Echo instructions or contribute to the project:

```bash
# Clone the repository
git clone https://github.com/beogip/echos-copilot.git
cd echos-copilot

# Install dependencies
npm install

# Build the instructions
npm run build

# Install in your target project
./install-local.sh /path/to/your/project
```

### Method 3: Manual Installation

For full control over the installation process:

1. **Download the repository**:

   ```bash
   git clone https://github.com/beogip/echos-copilot.git
   cd echos-copilot
   ```

2. **Build the instructions**:

   ```bash
   npm install
   npm run build
   ```

3. **Copy files to your project**:

   ```bash
   # For individual instructions mode
   cp -r .github/instructions/ /path/to/your/project/.github/

   # OR for comprehensive mode
   cp .github/copilot-instructions.md /path/to/your/project/.github/
   ```

## ⚙️ Installation Modes

The installer supports two different modes to suit your workflow:

### Instructions Mode (Default)

Creates individual `.instructions.md` files that GitHub Copilot loads automatically:

```bash
./install.sh --mode instructions
```

**Files created:**

- `.github/instructions/coherence.instructions.md`
- `.github/instructions/diagnostic.instructions.md`
- `.github/instructions/evaluation.instructions.md`
- `.github/instructions/optimization.instructions.md`
- `.github/instructions/planning.instructions.md`
- `.github/instructions/prioritization.instructions.md`

**Advantages:**

- ✅ Automatic loading by Copilot
- ✅ Modular organization
- ✅ Easy to enable/disable specific echos

### Comprehensive Mode

Creates a single `copilot-instructions.md` file with all Echo instructions:

```bash
./install.sh --mode comprehensive
```

**Files created:**

- `.github/copilot-instructions.md`

**Advantages:**

- ✅ Single file management
- ✅ Full control over instruction content
- ✅ Easier version control

## 🔧 Advanced Installation Options

### Force Installation

Overwrites existing Echo instructions without prompting:

```bash
./install.sh --force
```

### Verbose Mode

Shows detailed installation progress:

```bash
./install.sh --verbose
```

### Custom Target Directory

Install in a specific directory:

```bash
./install.sh --target /custom/path
```

### Backup and Rollback

The installer automatically creates backups:

```bash
# Automatic backup location
.github/echos-backup-YYYYMMDD-HHMMSS/

# Manual rollback
./install.sh --rollback
```

## 🛠️ Post-Installation Configuration

### 1. Verify Installation

Check that the files were created correctly:

```bash
# For instructions mode
ls -la .github/instructions/

# For comprehensive mode
ls -la .github/copilot-instructions.md
```

### 2. Test Echo Integration

Create a test file to verify the integration works:

```javascript
// test-echo.js

// ECHO: diagnostic
// Test if the diagnostic echo is working properly
function buggyFunction() {
  // This function has a potential issue
  return undefined.someProperty;
}
```

Expected behavior: Copilot should provide structured diagnostic analysis following the systematic steps.

### 3. Configure VS Code (if needed)

Ensure GitHub Copilot is properly configured:

1. Open VS Code settings (`Cmd/Ctrl + ,`)
2. Search for "copilot"
3. Verify that "GitHub Copilot: Enable" is checked
4. Restart VS Code if needed

## 📁 Project Structure After Installation

After successful installation, your project will have:

```
your-project/
├── .github/
│   ├── instructions/                     # Instructions mode
│   │   ├── coherence.instructions.md
│   │   ├── diagnostic.instructions.md
│   │   ├── evaluation.instructions.md
│   │   ├── optimization.instructions.md
│   │   ├── planning.instructions.md
│   │   └── prioritization.instructions.md
│   │
│   ├── copilot-instructions.md          # Comprehensive mode
│   └── echos-backup-YYYYMMDD-HHMMSS/    # Backup directory
│
└── (your existing project files)
```

## 🧪 Testing Your Installation

### Basic Echo Test

Verify that individual echo patterns work correctly:

```python
# ECHO: planning
# Plan the implementation of a user authentication system

class UserAuth:
    # Copilot should provide structured planning with steps:
    # 1. Objective clarification
    # 2. Context collection
    # 3. Current state diagnosis
    # 4. Execution modules
    pass
```

### Advanced Echo Test

Test echo chaining capabilities:

```typescript
// ECHO: diagnostic → optimization
// First diagnose performance issues, then optimize the solution

function slowFunction(data: any[]) {
    // Copilot should:
    // 1. Analyze performance problems systematically
    // 2. Then propose optimized implementation
    return data.map(item => /* complex processing */);
}
    return data.map(item => /* complex processing */);
}
```

## 🔄 Updating Your Installation

### Automatic Update

```bash
# Re-run the installer to get the latest version
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.sh | bash
```

### Manual Update

```bash
# Pull latest changes
cd echos-copilot
git pull origin main

# Rebuild instructions
npm run build

# Reinstall
./install.sh --force
```

## 🚨 Troubleshooting

### Installation Issues

**Problem**: Permission denied during installation

```bash
# Solution: Run with appropriate permissions
sudo ./install.sh
```

**Problem**: Files not found after installation

```bash
# Solution: Verify you're in the correct directory
pwd
ls -la .github/
```

**Problem**: Copilot not recognizing Echo instructions

```bash
# Solution: Restart VS Code and check file paths
# Ensure files are in .github/instructions/ or .github/copilot-instructions.md
```

### Echo Activation Issues

**Problem**: Echo comments not triggering structured responses

1. **Check instruction files exist**:

   ```bash
   ls -la .github/instructions/
   ```

2. **Verify file content**:

   ```bash
   head -n 20 .github/instructions/diagnostic.instructions.md
   ```

3. **Restart VS Code** and try again

4. **Check Copilot status** in VS Code status bar

### Common Issues

| Issue                   | Solution                                       |
| ----------------------- | ---------------------------------------------- |
| Echos not working       | Restart VS Code, check file permissions        |
| Installation fails      | Run with `--verbose` to see detailed errors    |
| Files overwritten       | Use backup directory to restore previous state |
| Wrong installation mode | Re-run installer with desired `--mode` option  |

## 🔧 Uninstallation

### Automatic Uninstallation

```bash
./install.sh --uninstall
```

### Manual Uninstallation

```bash
# Remove instruction files
rm -rf .github/instructions/
rm -f .github/copilot-instructions.md

# Restore from backup if needed
cp -r .github/echos-backup-YYYYMMDD-HHMMSS/* .github/
```

## 📚 Next Steps After Installation

Once installation is complete:

1. **Review the [main README](README.md)** for project concepts and usage examples
2. **Explore the `examples/` directory** for practical implementations in different languages
3. **Check individual instruction files** in `.github/instructions/` to understand each Echo type
4. **Start using Echo comments** in your development workflow
5. **Review troubleshooting section** if you encounter any issues

## 🤝 Getting Help

If you encounter installation issues:

1. **Check the logs**: `/tmp/echos-copilot-install.log`
2. **Review troubleshooting steps** above
3. **Open an issue** on the [GitHub repository](https://github.com/beogip/echos-copilot)
4. **Check existing issues** for similar problems
5. **Include your system info** (OS, shell, Node.js version) when reporting issues

## 📝 License

This installation guide is part of the Echo Protocol + GitHub Copilot integration project, licensed under MIT License.

---

**Happy coding with structured reasoning! 🧠🤖**
