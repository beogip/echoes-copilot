# Development-Specific Echo Templates

This directory contains YAML templates for echos specifically adapted for software development contexts. These are based on the core echo-protocol templates but optimized for programming scenarios.

## Available Echo Templates

### diagnostic-dev.yaml

Technical problem diagnosis for debugging and troubleshooting.

### planning-dev.yaml

Structured planning for feature implementation and architecture design.

### evaluation-dev.yaml

Code review and technical assessment with explicit quality criteria.

### optimization-dev.yaml

Systematic code improvement while preserving functionality.

### coherence-dev.yaml

Consistency checking for code style, patterns, and conventions.

### prioritization-dev.yaml

Decision-making for task ordering, feature prioritization, and technical debt management.

## Usage

These templates are referenced in the main Copilot instructions (`/.github/copilot-instructions.md`) and activated through code comments:

```javascript
// ECHO: diagnostic
// Description of the problem to diagnose
```

```python
# ECHO: planning
# Description of what needs to be planned
```

The templates provide the structured reasoning framework that Copilot follows when processing these echo triggers.
