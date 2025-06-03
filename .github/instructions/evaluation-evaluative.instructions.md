---
applyTo: '**'
---

# Copilot Instructions: 🧪 Structured Evaluation Echo

## Purpose

To issue a structured judgment on an object (idea, result, process, code, or design), using clear and validated criteria. This echo supports both general (critical) and technical evaluations, ensuring traceability, neutrality, and actionable feedback.

## When to Trigger

Triggered when evaluating any object (submission, result, proposal, technical artifact) to determine its quality, effectiveness, or alignment with expectations..

## Evaluative Steps

1. **Identification of the object to evaluate**

   - Clearly identify the object to be evaluated, its purpose, and the reason for evaluation.
   - _Validation:_
     - Is the object explicitly named?
     - Is its purpose or context explained?
     - Is the reason for evaluating it stated?
   - _Expected Output:_ A clear description of the object, its purpose, and relevance.

2. **Selection of evaluation mode**

   - Decide whether the evaluation will be general/critical or technical, and adapt the following analysis accordingly. This step requires explicit confirmation from the user before continuing.
   - _Validation:_
     - Was a mode suggested by the system?
     - Did the user confirm or modify it?
     - Were the following criteria adapted accordingly?
   - _Expected Output:_ User-confirmed evaluation mode (critical/technical), with contextual adjustments.

3. **Definition of evaluation criteria**

   - Establish the specific criteria to be used for judgment. This step requires explicit confirmation from the user before continuing.
   - _Validation:_
     - Were criteria suggested by the system?
     - Did the user confirm or modify them?
   - _Expected Output:_ Final list of confirmed criteria, with short descriptions.

4. **Evaluation per criterion**

   - Analyze the object according to each criterion, highlighting strengths and weaknesses.
   - _Validation:_
     - Was each criterion addressed?
     - Was each judgment justified with reasoning or evidence?
   - _Expected Output:_ Table or list with per-criterion analysis and supporting comments.

5. **Global judgment and recommendation**

   - Deliver an overall conclusion and an actionable recommendation (e.g., keep, revise, improve), justified by the findings.
   - _Validation:_
     - Was a global conclusion given?
     - Was a recommendation issued based on the evaluation?
     - Is the recommendation aligned with the criteria applied?
   - _Expected Output:_ Overall judgment with clear and justified recommendation.

## Output Format

Structured evaluation analysis with clear recommendations and actionable next steps.

## Notes

This echo unifies the former "Critical Evaluation" and "Technical Review" echoes.
It supports two submodes:
  • Critical – to assess proposals, ideas, outcomes, or general results
  • Technical – to assess code, design, architecture, or systems

Example uses:
  • Course proposal evaluation: goal clarity, pedagogical utility, feasibility.
  • React component review: code quality, performance, architecture alignment.

This echo pauses after steps 2 and 3 for user confirmation before continuing.

Compatible with:
  • 🧐 Metaevaluation – to audit past judgments
  • ⚙️ Optimization – to refine evaluated outputs
  • 🛠️ Diagnostic – to detect deeper structural flaws

Configuration:
- retry_on_fail: true
- max_retries_per_step: 3
