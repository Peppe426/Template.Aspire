---
name: create-acceptance-test
description: Guides interactive discovery and documentation of behavior-driven acceptance tests. Use this when asked to discuss behavior, clarify scenarios, and write acceptance-test markdown files in Gherkin style under src\AcceptanceCriteria.
---

# Create Acceptance Test Skill

## Purpose
This skill guides the iterative discovery and documentation of acceptance test scenarios for a feature, page, or workflow using Behavior-Driven Development (BDD) practices.

The workflow is intentionally interactive and scenario-driven. The assistant should discover one scenario at a time through focused conversation, then write the test cases afterward in Gherkin format with clear Given-When-Then statements.

## Target Output
- Target folder: `src\AcceptanceCriteria`
- Target files: one Markdown file per feature, page, or workflow with a descriptive business-facing name
- Output format: behavior-driven acceptance tests in Markdown using Gherkin style
- Primary deliverable: acceptance-test documents that describe what the user should be able to do from a business perspective
- Intended future use: these Markdown files will later guide coding and implementation work

## Working Style
1. Start with conversation and do not assume missing behavior.
2. Ask one focused question at a time.
3. Stay with one feature or scenario until the behavior is clear.
4. Clarify the role, preconditions, user actions, and expected outcomes before writing.
5. Convert the clarified behavior into Gherkin only after the flow is understood.
6. Keep the wording user-facing and business-oriented.
7. The very first question must be a generic, freeform request for the acceptance test name.
8. Do not begin with a predefined list of feature choices unless the user explicitly asks for suggestions.

## Working Boundaries
- Focus on discovering and documenting behavior only.
- Do not write application code, automated test code, or implementation details.
- Do not start coding from the acceptance tests in the same workflow.
- Use the Markdown acceptance-test files later as inputs for coding work.

## Recommended Workflow

### 1. Name the Acceptance Test
Always begin by asking the user what the acceptance test should be called.

Recommended opening prompts:
- What should this acceptance test be called?
- What name should we use for this acceptance test?

Use the user's answer as the working feature name and future Markdown filename. If the name is too broad, unclear, or overly technical, ask a focused follow-up question to refine it into a business-facing title.

Do not present a canned list of features in the first question.

The name should describe a distinct user capability or business workflow, such as customer creation, invoice approval, or a status transition flow.

### 2. Discover the Scenario Through Conversation
Ask short, focused questions to uncover the behavior.

Question areas:
- Who is the user (role/persona)?
- What state is the system in before the scenario?
- What permissions or data must exist?
- What does the user do?
- What input is required?
- What system event triggers the behavior?
- What visible result should the user see?
- What data changes or is created?
- What business rules apply?
- What should happen if data is missing or invalid?
- What happens if the action violates a business rule?
- Are there duplicate-detection, ordering, or permission checks?
- Are there alternate success paths?
- What about boundary conditions or special cases?

### 3. Build the Scenario Skeleton
Once the behavior is clear, organize it into BDD structure:

- Feature
- User role
- Goal
- Business value
- Shared context or background
- Main scenario
- Alternate or validation scenario

### 4. Write the Scenario in Gherkin Format
Translate the conversation into clear, testable acceptance criteria.

Use this template:

```gherkin
Feature: <feature name>
  As a <role>
  I want <goal>
  So that <business value>

  Background:
    Given <shared context>

  Scenario: <happy path>
    Given <starting state>
    When <action>
    Then <expected outcome>

  Scenario: <validation or alternate path>
    Given <starting state>
    When <action>
    Then <expected validation or response>
```

### 5. Document in the Acceptance Test File
Create or update a focused Markdown file under `src\AcceptanceCriteria`.

File naming guidance:
- Use descriptive business-oriented filenames.
- Prefer one file per feature, page, or workflow.
- Keep related scenarios together in the same file.

Examples:
- `src\AcceptanceCriteria\Customer Creation.md`
- `src\AcceptanceCriteria\User Registration Workflow.md`
- `src\AcceptanceCriteria\Build Order Creation.md`

Organization:
- Group scenarios by feature
- Keep related scenarios together
- Prefer several focused scenarios over one oversized scenario
- Include the happy path and important negative paths
- Avoid implementation details such as controllers, methods, or database language

### 6. Continue the Scenario Discovery Loop
After documenting a feature, ask what scenario should be captured next or whether the current acceptance-test Markdown should be refined.

## Writing Rules
- Use the user's business terminology.
- Describe what the user sees and does, not how the system is implemented.
- Keep one scenario focused on one workflow.
- Use `Feature`, `Background`, `Scenario`, and `Scenario Outline` when useful.
- Use clear and testable `Given`, `When`, and `Then` steps.
- Do not invent missing behavior.
- If something is unclear, ask another question before writing.
- Capture assumptions explicitly.
- Avoid technical implementation details.

## Scenario Question Prompts
Use prompts like these during the conversation:
- What user role is involved in this scenario?
- What must already exist before this action starts?
- What exact action does the user take?
- What result should the user see if everything succeeds?
- What should happen if the entered data is invalid?
- Are duplicates allowed?
- Does the current status of the record change what the user is allowed to do?
- What should happen if the action is cancelled or reversed?

## Definition of Done
The workflow is complete for a feature when:
- the scenario has been clarified through questions
- the acceptance tests are written in BDD style
- success and key failure cases are covered
- the tests have been added to an appropriate Markdown file under `src\AcceptanceCriteria`
