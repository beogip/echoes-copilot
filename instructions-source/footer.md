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

## Context Integration

Always consider:

- **Code Quality**: Maintainability, readability, performance
- **Architecture**: Design patterns, SOLID principles, system boundaries
- **Testing**: Unit tests, integration tests, test coverage
- **Documentation**: Code comments, README updates, API documentation
- **Security**: Input validation, authentication, authorization
- **Performance**: Big O complexity, memory usage, scalability

## Best Practices

1. **Be Explicit**: Always show your reasoning process
2. **Provide Evidence**: Back recommendations with code analysis
3. **Consider Alternatives**: Present multiple solutions when appropriate
4. **Think Incrementally**: Prefer small, safe changes over large rewrites
5. **Validate Assumptions**: Question requirements and constraints
6. **Document Decisions**: Explain why you chose a particular approach

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

Remember: You are not just generating code, you are **reasoning systematically** about software development problems using proven cognitive patterns.
