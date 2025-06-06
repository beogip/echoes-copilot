# 🧠🤖 Echos + Copilot Template

A template for integrating the **Echo Protocol** with **GitHub Copilot**, creating a programming assistant that uses structured reasoning patterns to solve software development problems.

> **⚠️ IMPORTANT NOTE**: This project demonstrates both correct AND incorrect echo usage. The files `ai-assistant/planning/M1-M6` initially contained echo labels without following systematic steps (wrong approach). The file `M1-build-system-diagnostic.md` has been corrected to show proper echo execution. This serves as a learning example of the difference between echo labels vs. actual echo reasoning.

## 🎯 What is this template?

This repository combines two powerful technologies:

- **Echo Protocol**: Modular functional reasoning architecture for structuring cognitive processes
- **GitHub Copilot**: AI assistant for programming

The result is an assistant that not only generates code, but **reasons in a structured way** about development problems, following validated cognitive patterns.

## 🧠 What are Echos?

**Thought Echos** are structured cognitive units that define specific reasoning processes:

- **Functional units** with defined purpose, trigger, steps, and output
- **Reusable** across different contexts and projects
- **Auditable** with explicit and traceable steps
- **Modular** that can be combined into complex flows
- **Agent-agnostic** (executable by humans, AIs, or hybrids)

### Echo Types for Development

This template includes echos especially useful for programming:

| Echo                  | Description                                        | Use in Development                        |
| --------------------- | -------------------------------------------------- | ----------------------------------------- |
| 🛠️ **Diagnostic**     | Technical analysis to detect the root of a problem | Debug, troubleshooting, error analysis    |
| 🧭 **Planning**       | Step-by-step structure for learning or execution   | Software architecture, project roadmaps   |
| 🧪 **Evaluation**     | Critical evaluation with explicit criteria         | Code review, quality analysis, validation |
| ⚙️ **Optimization**   | Refactor without losing original intention         | Refactoring, performance improvement      |
| ✅ **Coherence**      | Self-correction when losing focus                  | Maintain code consistency                 |
| 🔢 **Prioritization** | Order alternatives with decision criteria          | Feature management, bug prioritization    |

## 🚀 Quick Start

Get started in seconds with automatic installation:

```bash
# Unix/macOS/Linux
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.sh | bash

# Windows PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/beogip/echos-copilot/main/install.ps1" -OutFile "install.ps1"; .\install.ps1

# Node.js (Cross-platform)
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.js | node
```

> 📋 **Need detailed installation instructions?** See the [Installation Guide](INSTALLATION-GUIDE.md) for comprehensive setup options, troubleshooting, and advanced configuration.

### 2. Start using echos in your code

Once installed, activate echos using special comments:

```javascript
// ECHO: diagnostic
// Need to understand why this function fails with large arrays

function processLargeArray(data) {
  // Current code...
}
```

```python
# ECHO: planning
# Want to refactor this module for better maintainability

class DataProcessor:
    # Current code...
```

### 3. Available echo patterns

| Command                   | Description                |
| ------------------------- | -------------------------- |
| `// ECHO: diagnostic`     | Analyze and debug problems |
| `// ECHO: planning`       | Create structured plans    |
| `// ECHO: evaluation`     | Review code and proposals  |
| `// ECHO: optimization`   | Improve efficiency         |
| `// ECHO: coherence`      | Verify consistency         |
| `// ECHO: prioritization` | Rank tasks and features    |

## 📁 Project Architecture

```
echos-copilot/
├── .github/
│   ├── copilot-instructions.md      # Complete instructions (comprehensive mode)
│   └── instructions/                # Individual instruction files (default mode)
├── build/                           # Build system and automation
├── instructions-source/             # Source templates for instruction generation
├── examples/                        # Usage examples in multiple languages
├── ai-assistant/                    # Development context and planning
└── install.sh                       # Cross-platform installer
```

## 🔧 For Developers

### Build System

Generate customized instructions from modular sources:

```bash
npm install          # Install dependencies
npm run build        # Build all instruction formats
npm run build:watch  # Development mode with auto-rebuild
```

### Testing Suite

Run comprehensive tests with optimized performance monitoring:

```bash
# Complete test suite
npm test             # Run all tests (same as npm run test:all)
npm run test:all     # Complete testing suite

# Individual test categories
npm run test:edge    # Edge case tests (optimized with timing)
npm run test:installer     # Installer functionality tests
npm run test:integration   # Integration tests
npm run test:unit    # Unit tests

# Specialized test modes
npm run test:edge-only     # Only edge cases via test runner
npm run test:quick   # Quick validation (installer + unit tests)
npm run test:verbose # Detailed output with additional logging
```

> 🧪 **Optimized Edge Cases**: The edge case tests now include performance monitoring, reduced code duplication (75% less), and cross-platform compatibility for macOS/Linux.

### YAML Validation Utility

Validate all YAML echo files or a single file for schema and formatting:

```bash
# Validar todos los archivos .yaml en echos-sources/
npx ts-node scripts/validate-prs-yaml.ts

# Validar un solo archivo específico
e.g.
npx ts-node scripts/validate-prs-yaml.ts echos-sources/creativity/creativity-divergent.prs.es.yaml
```

- El validador reporta errores de formato, raíz de objeto y sintaxis YAML.
- Útil para CI/CD, revisión de PRs y desarrollo local.

### Customization

1. **Edit sources** in `instructions-source/`
2. **Add custom echos** with YAML files
3. **Rebuild**: `npm run build`
4. **Test** with your Copilot setup

> 📚 **Full development documentation** available in `instructions-source/README.md`

## 🎯 Benefits of this approach

### For individual developers:

- **Structured reasoning** about complex problems
- **More systematic debugging process**
- **More consistent code reviews**
- **Clearer architecture planning**

### For teams:

- **Shared thinking patterns**
- **More structured communication about technical decisions**
- **More effective onboarding with clear processes**
- **Documentation of architectural decisions**

### For projects:

- **Traceability of technical decisions**
- **More predictable maintenance**
- **Safer refactoring**
- **More manageable technical debt**

## 🧪 Usage examples

### Bug diagnosis

```javascript
// ECHO: diagnostic
// Login fails intermittently in production

async function authenticateUser(credentials) {
  // Copilot will analyze the problem following:
  // 1. Problem isolation
  // 2. Symptom collection
  // 3. Technical hypothesis
  // 4. Hypothesis prioritization
  // 5. Test proposal
}
```

### Feature planning

```python
# ECHO: planning
# Implement distributed cache system

class CacheManager:
    # Copilot will create a plan including:
    # 1. Clear objectives
    # 2. Context and constraints
    # 3. Current state diagnosis
    # 4. Obstacle detection
    # 5. Execution modules
    # 6. Tracking system
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add or improve echo patterns
4. Include usage examples
5. Submit a pull request

## 📚 Resources

- [📦 Installation Guide](INSTALLATION-GUIDE.md) - Detailed setup and troubleshooting
- [Echo Protocol Repository](https://github.com/beogip/echo-protocol) - Complete protocol documentation
- [GitHub Copilot Docs](https://docs.github.com/en/copilot) - Official Copilot documentation

## 📄 License

MIT License - Use freely in your projects.

---

**Ready to enhance your coding with structured reasoning?** 🧠🚀

Install now and start using Echo patterns in your development workflow.
