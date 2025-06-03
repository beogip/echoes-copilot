# AI Assistant Configuration for Echo-Copilot Template

## Purpose

This project uses the `ai-assistant/` folder to maintain context and institutional knowledge for AI assistants working on the Echo Protocol + GitHub Copilot integration template.

## Folder Structure

```
ai-assistant/
├── context/                 # Background information and methodologies
│   ├── development-context.md      # Software development best practices
│   └── echo-protocol-context.md    # Echo Protocol philosophy and structure
├── planning/                # Implementation plans and roadmaps
│   └── echo-copilot-implementation-plan.md  # Current project plan (PRS-generated)
└── echos/                  # Development-specific echo templates
    └── README.md           # Documentation of custom echo adaptations
```

## Usage Guidelines

### For AI Assistants

When working on this project:

1. **Reference existing context** - Check `context/` files for background information
2. **Update plans** - Modify files in `planning/` as the project evolves
3. **Store analysis** - Save diagnostic results, evaluations, and other echo outputs
4. **Maintain continuity** - Use stored context to maintain consistency across sessions

### For Human Developers

- **Review context files** to understand the project methodology
- **Check planning documents** for current roadmap and status
- **Add new context** when significant decisions or discoveries are made
- **Keep plans updated** to reflect actual progress

## Template Integration

This folder structure should be copied when using this template in new projects, providing:

- Immediate context for AI assistants about Echo Protocol
- Development best practices and quality standards
- Planning templates for structured project management
- Examples of how to store and organize AI assistant context

## File Naming Conventions

- **Context files**: `{topic}-context.md`
- **Planning files**: `{project-name}-{plan-type}-plan.md`
- **Analysis files**: `{analysis-type}-{date}-{topic}.md`
- **Configuration**: `{tool-name}-config.{ext}`

## Maintenance

- Review and update context files quarterly
- Archive completed planning documents
- Clean up outdated analysis files
- Keep the folder structure documented and consistent

---

_This configuration is part of the Echo-Copilot Template v1.0_
