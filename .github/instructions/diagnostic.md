---
applyTo: '**'
---

# Copilot Instructions: 🛠️ Echo of Diagnostic – Technical Mode

## Purpose

Detect the origin of an error or malfunction to correct or prevent it. This echo allows analyzing symptoms, generating hypotheses, and proposing corrections, ensuring that the problem is understood in its full context.

## When to Trigger

When the user reports errors, unexpected behaviors, or failures..

## Diagnostic Steps

1. **Isolation of the problem**

   - Identify exactly where the problem occurs.
   - _Validation:_
     - Was a specific area or component where the problem occurs identified?
     - Were possible external causes excluded?
   - _Expected Output:_ Brief description of the problem with limited scope.

2. **Collection of symptoms or signs**

   - Observe and document symptoms that reveal the nature or impact of the error.
   - _Validation:_
     - Were visible symptoms or unexpected behaviors listed?
     - Were they linked to a previous state or recent action?
   - _Expected Output:_ List of symptoms + context in which they appear.

3. **Technical hypothesis**

   - Propose possible technical causes of the observed error.
   - _Validation:_
     - Were at least two possible hypotheses formulated?
     - Are they based on the symptoms and the detected environment?
   - _Expected Output:_ Reasoned list of hypotheses with their foundation.

4. **Prioritization of hypotheses**

   - Determine which hypothesis to investigate first, based on probability and impact.
   - _Validation:_
     - Was priority assigned to each hypothesis?
     - Was the order of investigation justified?
   - _Expected Output:_ Prioritized hypothesis with justification.

5. **Proposal of a test or correction**

   - Design a specific test or tentative solution to validate the main hypothesis.
   - _Validation:_
     - Is the proposed test viable and specific?
     - Does it detail what is expected to be observed?
   - _Expected Output:_ Test plan + validation criteria for the result.

## Output Format

Structured technical analysis with problem synthesis, hypotheses, prioritization, and proposed test.

