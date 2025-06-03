---
applyTo: '**'
---

# Copilot Instructions: Planning Echo – Formative Mode

## Purpose

Guide step-by-step planning of a learning, development, or implementation process, ensuring clarity, adaptability, and structured feedback. Supports roadmap creation for individuals, teams, or systems.

## When to Trigger

Triggered when the user wants to learn something, organize a complex task, improve a situation, or build an action plan..

## Formative Steps

1. **Clarification of the final objective**

   - Clearly define what is to be achieved.
   - _Validation:_
     - Is there a specific outcome or deliverable?
     - Is it expressed in measurable and concrete terms?
   - _Expected Output:_ A sentence or paragraph defining the final goal.

2. **Active collection of contextual information**

   - Ensure all relevant information is available before planning.
   - _Validation:_
     - Were all key questions asked?
     - Was relevant information documented?
     - Was flow halted if information was missing?
   - _Expected Output:_ Context map with user input, resources, constraints, and background.

3. **Diagnosis of the starting point**

   - Evaluate the current position in relation to the goal.
   - _Validation:_
     - Was the current state described in detail?
     - Were gaps toward the goal identified?
   - _Expected Output:_ Diagnostic summary with strengths and gaps.

4. **Definition of the learner or main actor role**

   - Adapt the plan to the person, team, or AI that will execute it.
   - _Validation:_
     - Was the executor described?
     - Were level, availability, style, and limitations considered?
   - _Expected Output:_ Summary profile of the executor.

5. **Detection of possible obstacles**

   - Anticipate what might block progress and how to address it.
   - _Validation:_
     - Were potential blockers identified (technical, motivational, time)?
     - Were preventive or mitigating strategies proposed?
   - _Expected Output:_ Obstacle list with contingency plan.

6. **Definition of the final deliverable**

   - Establish the product, skill, or knowledge to be acquired.
   - _Validation:_
     - Is it aligned with the initial objective?
     - Is it demonstrable, evaluable, or shareable?
   - _Expected Output:_ Clear description of the final output.

7. **Division into execution modules**

   - Split the path into concrete, sequential actions grounded in prior analysis.
   - _Validation:_
     - Does each module reflect an actionable step based on previous insights?
     - Does it have a clear operational purpose?
     - Is it justified and logically connected to the overall plan?
   - _Expected Output:_ Structured table with: - name - purpose - context_description - deliverables - dependencies

8. **Progress visualization + dynamic adaptation**

   - Define how progress will be measured and how the plan will be adjusted.
   - _Validation:_
     - Are there defined signals or metrics for progress?
     - Is a dynamic adjustment mechanism included?
   - _Expected Output:_ Tracking system with: - module indicators - review frequency - tracking format (dashboard, checklist, log) - adjustment criteria

## Output Format

Structured planning analysis with clear recommendations and actionable next steps.

## Notes

This optimized version improves traceability for AI-driven flows through contextual module descriptions and a structured format.
Useful for distributed, asynchronous, or progressive executions.
Can be combined with:
  - 🧪 Evaluation Echo for consistency checks
  - ✅ Coherence Echo for goal alignment
  - 🔁 Execution Echo for step-by-step modular execution
  - 🧩 Orchestration Echo for complex flow chaining
Serialization recommended using: name, purpose, context_description, deliverables, dependencies

Configuration:
- retry_on_fail: true
- max_retries_per_step: 3
