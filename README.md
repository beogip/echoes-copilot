# 🧠🤖 Echos + Copilot Template

A template for integrating the **Echo Protocol** with **GitHub Copilot**, creating a programming assistant that uses structured reasoning patterns to solve software development problems through intelligent chat interaction.

## 🎯 What is this template?

This repository enhances GitHub Copilot with structured reasoning capabilities:

- **Echo Protocol**: Modular reasoning patterns for systematic problem-solving
- **GitHub Copilot Integration**: Seamless activation through chat or automatic detection
- **Intelligent Reasoning**: AI that follows validated cognitive patterns for software development

The result is an enhanced Copilot that not only generates code, but **reasons systematically** about development problems, automatically applying the most appropriate reasoning pattern for your specific context.

## 🧠 What are Echos?

**Thought Echos** are structured cognitive units that define specific reasoning processes for GitHub Copilot:

- **Structured reasoning patterns** that guide AI analysis and problem-solving
- **Automatic activation** when appropriate context is detected
- **Manual invocation** through direct chat requests
- **Auditable processes** with explicit and traceable steps
- **Modular design** that can be combined for complex workflows

### How Echos Work with GitHub Copilot

1. **Automatic Detection**: Copilot analyzes your questions and code context to determine when to apply specific Echo patterns
2. **Manual Activation**: You can explicitly request an Echo (e.g., "Run the diagnostic echo on this error")
3. **Structured Output**: Each Echo follows a systematic approach with defined steps and validation criteria
4. **Contextual Adaptation**: Echos adapt their analysis to your specific programming language, framework, and problem domain

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
```

```bash
# Windows PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/beogip/echos-copilot/main/install.ps1" -OutFile "install.ps1"; .\install.ps1
```

```bash
# Node.js (Cross-platform)
curl -sSL https://raw.githubusercontent.com/beogip/echos-copilot/main/install.js | node
```

> 📋 **Need detailed installation instructions?** See the [Installation Guide](INSTALLATION-GUIDE.md) for comprehensive setup options, troubleshooting, and advanced configuration.

### 2. Start using Echos with GitHub Copilot

Once installed, GitHub Copilot will automatically load the Echo instructions. You can activate Echos in two ways:

#### **Direct Chat Activation (Recommended)**
Ask GitHub Copilot to use a specific Echo directly in your conversation:

```
"Run the diagnostic echo to analyze this performance issue"
"Execute the planning echo for implementing user authentication"
"Apply the evaluation echo to review this API design"
```

#### **AI-Driven Activation (Automatic)**
GitHub Copilot will automatically choose and execute the appropriate Echo based on your question or code context:

```
"This function is running slowly, help me understand why"
→ Copilot automatically applies the diagnostic echo

"I need to refactor this module safely"  
→ Copilot automatically applies the planning + optimization echos
```

### 3. Available Echo patterns

| Echo Type             | Purpose                    | Example Usage                           |
| --------------------- | -------------------------- | --------------------------------------- |
| **Diagnostic**        | Analyze and debug problems | "Run diagnostic echo on this error"    |
| **Planning**          | Create structured plans    | "Use planning echo for this feature"   |
| **Evaluation**        | Review code and proposals  | "Apply evaluation echo to this code"   |
| **Optimization**      | Improve efficiency         | "Execute optimization echo here"       |
| **Coherence**         | Verify consistency         | "Run coherence echo on this module"    |
| **Prioritization**    | Rank tasks and features    | "Use prioritization echo for backlog"  |

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

**Your request:**
> "This login function fails intermittently in production. Run the diagnostic echo to help me understand why."

**Copilot with Diagnostic Echo will:**
1. Isolate the intermittent failure pattern
2. Collect symptoms (timing, frequency, user patterns)  
3. Form technical hypotheses (token timing, race conditions, etc.)
4. Prioritize most likely causes
5. Propose specific tests to verify

```javascript
async function authenticateUser(credentials) {
  // Copilot provides structured analysis of potential issues:
  // - Race conditions in token validation
  // - Database connection timeouts
  // - Network latency patterns
  // With specific testing recommendations
}
```

### Feature planning

**Your request:**
> "I need to implement a distributed cache system. Use the planning echo to structure this."

**Copilot with Planning Echo will:**
1. Clarify objectives (performance targets, scalability requirements)
2. Analyze current context and constraints
3. Diagnose current state (existing session management)
4. Detect obstacles (consistency, network partitions)  
5. Define execution modules (cache layer, invalidation, monitoring)
6. Create progress tracking (metrics, validation points)

```python
class CacheManager:
    # Copilot provides structured implementation plan:
    # - Module breakdown with dependencies
    # - Performance benchmarks and validation
    # - Risk mitigation strategies
    # - Testing and rollout approach
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
