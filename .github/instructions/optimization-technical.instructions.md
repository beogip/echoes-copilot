---
applyTo: '**'
---

# Copilot Instructions: ⚙️ Echo of Optimization – Technical Mode

## Purpose

Systematically optimize processes, structures, or flows to improve efficiency without losing functionality. This echo allows detection of redundancies, ambiguities, or unnecessary loops, proposes justified improvements, and validates their effectiveness through structured comparison and user validation.

## When to Trigger

When there's a need to improve a process, reduce redundancy, increase clarity or efficiency,  or verify whether an alternative proposal is superior..

## Technical Steps

1. **Identification of the optimization goal**

   - Define what needs to be improved and record the original input.
   - _Validation:_
     - Is the element to be optimized clearly identified?
     - Was the original input noted without modification?
   - _Expected Output:_ Original input with specified area of improvement

2. **Analysis of current efficiency**

   - Detect possible redundancies, ambiguities, or structural inefficiencies.
   - _Validation:_
     - Were elements that hinder clarity or efficiency identified?
     - Was justification provided for why they should be improved?
   - _Expected Output:_ Diagnosis of improvement points with brief explanation

3. **Verification of constraints**

   - Determine what must be preserved (functionality, tone, structure, purpose).
   - _Validation:_
     - Were explicit user or system constraints listed?
     - Is it clear what must not be changed?
   - _Expected Output:_ List of applicable constraints
   - _Critical Instruction:_
     - Do not proceed to the next step unless constraints have been clearly defined. Ask the user what must be preserved and validate their response.

4. **Design of the optimized proposal**

   - Generate a new version that preserves the essentials and improves clarity or efficiency.
   - _Validation:_
     - Does the new version respect all defined constraints?
     - Were the previously diagnosed issues addressed?
   - _Expected Output:_ Optimized version aligned with defined goals

5. **Structural comparison between versions**

   - Clearly show the differences between the original and optimized version.
   - _Validation:_
     - Are the changes explained?
     - Is each change justified as an improvement?
   - _Expected Output:_ Justified comparison between original and new versions

6. **Validation of improvement**

   - Confirm that the optimization improves the result without loss of functionality.
   - _Validation:_
     - Were clarity, efficiency, and purpose evaluated?
     - Was the improvement marked as accepted or rejected?
   - _Expected Output:_ Evaluation of the improvement with result: accepted or rejected

7. **Iterative feedback (if applicable)**

   - Allow further adjustments based on user feedback.
   - _Validation:_
     - Was there room for comments or corrections?
     - Was a new iteration applied if requested?
   - _Expected Output:_ Final validated and adapted version

## Output Format

Structured optimization analysis with clear recommendations and actionable next steps.

## Notes

This echo can be used standalone or as part of broader flows.
It is compatible with the Echo of Diagnostic, Evaluation, Coherence, and Planning.
Ideal for refactoring, conversational cleanup, prompt simplification, or progressive idea refinement.

Configuration:
- retry_on_fail: true
- max_retries_per_step: 2
