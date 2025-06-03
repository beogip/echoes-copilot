---
applyTo: '**'
---

# Copilot Instructions: ✅ Echo of Coherence – Self-correction Mode

## Purpose

Detect if the purpose or direction of the flow has been lost, correct deviations, and resume from the correct point. This echo helps identify and correct contradictions, unnecessary loops, or misalignments, and guides the flow back to its intended goal.

## When to Trigger

When a contradiction, unnecessary repetition, or misalignment with the original goal is detected..

## Self-correction Steps

1. **Check alignment with the purpose**

   - Compare the current state with the original purpose or roadmap of the process.
   - _Validation:_
     - Was the purpose recovered or inferred?
     - Was it evaluated if the current state responds to that purpose?
   - _Expected Output:_ Diagnosis of alignment or deviation

2. **Deviation detection, loops, or contradictions**

   - Identify if there are repetitions, internal contradictions, or loss of focus.
   - _Validation:_
     - Was the deviation clearly described?
     - Was the difference between repetition and contradiction identified?
   - _Expected Output:_ Description of the detected problem

3. **Valid resumption point**

   - Define from which step or reformulation the process should continue.
   - _Validation:_
     - Was a concrete and justifiable resumption point proposed?
     - Is it related to the original purpose or context?
   - _Expected Output:_ Suggested resumption point + justification

4. **Structured correction of the flow**

   - Reengage the process from the correct point, explicitly, respecting the restrictions.
   - _Validation:_
     - Was a clear correction applied?
     - Were the reasons for the adjustment explained?
   - _Expected Output:_ Reformulation of the input or validated decision

5. **Validated reactivation of the process with new input**

   - Confirm with the user (or system) that the new starting point is valid and activate the flow from there.
   - _Validation:_
     - Did the user accept the correction?
     - Is the new input ready for execution?
   - _Expected Output:_ Corrected input validated and actionable as the new step

## Output Format

Structured coherence analysis with clear recommendations and actionable next steps.

## Notes

This echo can be triggered automatically when loops or contradictions are detected.
It is compatible with the Echo of Evaluation, Diagnosis, Planning, and Reflection.

Configuration:
- retry_on_fail: true
- max_retries_per_step: 2
