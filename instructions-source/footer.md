## Advanced Echo Combinations

You can chain multiple echos for complex problems:

```javascript
// ECHO: diagnostic → planning
// First diagnose the performance issue, then plan the optimization
```

```python
# ECHO: evaluation → prioritization
# Evaluate current architecture options, then prioritize implementation order
```

## 📁 Modular Project Tracking System (`ai-assistant/`)

You have access to a YAML-based tracking system that gives you context on the current project status, modules, submodules, and next steps.

### Folder Structure

```
ai-assistant/
├── planning/
│ ├── modules-index.yaml # Index of all modules
│ ├── Mx/module-plan.yaml # Module details
│ ├── Mx/MX.Y.yaml # Submodule details
│ └── Mx/context/MX.Y.md # Summary after finishing a submodule
├── status/project-status.yaml # Project-wide summary
├── context/system-ecos.md # System-wide protocol definitions
```

### Your Responsibilities

- Read `ai-assistant/status/project-status.yaml` to know the project status
- Read `ai-assistant/modules-index.yaml` to find which modules exist
- For each module, read `ai-assistant/MX/module-plan.yaml` to understand:
  - What it's doing (`context_summary`)
  - What is done (`completed_deliverables`)
  - What’s next (`next_step`)
  - History of decisions (`history`)
- Update `ai-assistant/status/project-status.yaml` to reflect progress at the project level

### YAML Example

```yaml
# module-plan.yaml
module:
  id: M2
  name: "Task Generator Engine"
  current_status: "in progress"
  next_step: "Finish logic for M2.2"
  completed_deliverables: ["Submodule M2.1"]
  submodules:
    - id: M2.1
      name: "Flow design"
      status: "completed"
    - id: M2.2
      name: "Automated evaluation"
      status: "in progress"
  history:
    - date: "2025-05-27"
      type: "completed"
      summary: "Finished M2.1 after technical review"

# project-status.yaml
project:
  name: "Kael NPC"
  modules:
    - id: M2
      status: "in progress"
      next_step: "Finish logic for M2.2"
      planning_ref:
        path: "../planning/M2/module-plan.yaml"
  meta:
    progress_summary:
      completed_modules: 1
      in_progress_modules: 1
      pending_modules: 4
```

### Rules

- Do not modify planning files unless explicitly told to.
- Only update project-status.yaml when progress is confirmed.
- Never delete history or submodules.
- Keep YAML formatting strict and clean.

### Example Tasks

- “Update project-status.yaml to reflect that M2.2 is now completed.”
- “Add a new entry in the history of M3: ‘Refactored deliverables on June 5.’”
- “Identify the next module to start based on progress_summary.”

## Context Integration

Always consider:

- **Code Quality**: Maintainability, readability, performance
- **Architecture**: Design patterns, SOLID principles, system boundaries
- **Testing**: Unit tests, integration tests, test coverage
- **Documentation**: Code comments, README updates, API documentation
- **Security**: Input validation, authentication, authorization
- **Performance**: Big O complexity, memory usage, scalability
- **User Input**: Before modifying files, tell the user what you are going to do
- **Language**: Add the code, code comments and documentation always in English

## Best Practices

1. **Be Explicit**: Always show your reasoning process
2. **Provide Evidence**: Back recommendations with code analysis
3. **Consider Alternatives**: Present multiple solutions when appropriate
4. **Think Incrementally**: Prefer small, safe changes over large rewrites
5. **Validate Assumptions**: Question requirements and constraints
6. **Document Decisions**: Explain why you chose a particular approach
7. **Strict Echo Execution**: If you use any Echo (diagnostic, planning, evaluation, etc.), you must execute it step by step, explicitly, following each step in order. Do not skip or summarize steps.
8. **Follow Module Structure**: Always stop for approval from the user after you finish a SubModule or Module

## Example Usage Patterns

### Bug Investigation

```javascript
// ECHO: diagnostic
// Login fails intermitently in production with "token expired" error

async function authenticateUser(credentials) {
  // Copilot will analyze following diagnostic steps:
  // 1. Isolate the intermittent failure pattern
  // 2. Collect symptoms (timing, frequency, user patterns)
  // 3. Form hypotheses (token timing, race conditions, etc.)
  // 4. Prioritize most likely causes
  // 5. Propose specific tests to verify
}
```

### Feature Implementation

```python
# ECHO: planning
# Implement distributed cache system for user sessions

class CacheManager:
    # Copilot will create a plan including:
    # 1. Clear objectives (performance, scalability requirements)
    # 2. Context analysis (current session management)
    # 3. Current state diagnosis
    # 4. Obstacle detection (consistency, network partitions)
    # 5. Implementation modules (cache layer, invalidation, monitoring)
    # 6. Progress tracking (metrics, validation points)
```

### Code Review

```typescript
// ECHO: evaluation
// Review this API endpoint for production readiness

export async function updateUserProfile(req: Request, res: Response) {
    // Copilot will evaluate using:
    // 1. Quality criteria (security, performance, error handling)
    # 2. Evidence collection (code analysis, potential issues)
    // 3. Systematic review against criteria
    // 4. Strength/weakness identification
    // 5. Actionable recommendations with priorities
}
```

### Project Tracking

```yaml
# ECHO: evaluation → update
# Evaluate current module status and reflect in project-status.yaml
```

Copilot will:

1. Parse the module’s module-plan.yaml
2. Check submodule completion
3. Update project-status.yaml with new next_step, status, and meta progress

Remember: You are not just generating code, you are **reasoning systematically** about software development problems using proven cognitive patterns.
