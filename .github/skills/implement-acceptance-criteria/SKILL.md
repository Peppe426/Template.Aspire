---
name: implement-acceptance-criteria
description: Guides interactive implementation of an existing acceptance-criteria document into a Clean Architecture vertical slice. Use this when asked to take a completed acceptance test from docs\AcceptanceCriteria and turn it into tests, application slice code, domain language, infrastructure adapters, and validation.
---

# Implement Acceptance Criteria Skill

## Purpose
This skill guides the interactive implementation of a feature that already has a business-facing acceptance test under `docs\AcceptanceCriteria`.

It turns agreed behavior into a vertical slice that respects:

- Clean Architecture boundaries
- acceptance-test-first delivery
- TDD
- DDD language in the domain
- the repository's test and folder conventions

## Target Output
- Source input: `docs\AcceptanceCriteria\*.md`
- Application slice: `src\WindowsImageTool\src\WindowsImageTool.Application\Features\<Area>\<UseCase>\`
- Domain model: `src\WindowsImageTool\src\WindowsImageTool.Domain\`
- Infrastructure adapters: `src\WindowsImageTool\src\WindowsImageTool.Infrastructure\`
- Tests:
  - `src\WindowsImageTool\src\Tests\Tests.Application\`
  - `src\WindowsImageTool\src\Tests\Tests.Domain\`
  - `src\WindowsImageTool\src\Tests\Tests.Infrastructure\` when needed
- Validation:
  - targeted `dotnet test` runs for touched test projects
  - a final repository build using the relevant solution file for the workspace

## Working Style
1. Start from conversation and a named acceptance-criteria file. Do not guess which document or scenario should be implemented, feel free to give suggestions and the user can choose one or give an other name.
2. Ask one focused question at a time when scope, rules, or behavior are unclear.
3. Stay with one feature or one clearly scoped scenario set until that slice is complete.
4. Use the acceptance-criteria language as the source of names for commands, results, aggregates, value objects, and business rules.
5. Write failing automated tests before production code.
6. Create the smallest useful application slice shell early so tests and contracts have a stable home.
7. Keep business rules in `Domain`, orchestration in `Application`, and technical details in `Infrastructure`.
8. Finish with targeted verification, not just file creation.
9. If the acceptance criteria and the requested behavior conflict, stop and clarify before coding.
10. Existing feature folders in this repo include older flat examples, but new slices should prefer `Features\<Area>\<UseCase>\`.

## Opening Question Rule
The very first question must be a generic, freeform request for the acceptance criteria to implement.

Recommended opening prompts:
- What acceptance criteria should we implement?
- Which acceptance-criteria file should we turn into a slice?
- What is the name of the acceptance criteria you want to implement?

Do not begin with a canned list of feature choices unless the user explicitly asks for suggestions.

## Working Boundaries
- Do implement code, automated tests, and required wiring for the selected slice.
- Do not invent behavior that is missing from the acceptance criteria without asking.
- Do not broaden scope into adjacent features just because they share infrastructure.
- Do not put infrastructure concerns into `Domain`.
- Do not put API, host, or transport concerns into `Application`.
- Do not extract shared abstractions too early. Keep ports inside the slice unless real reuse already exists.
- Prefer targeted test-project runs instead of solution-wide `dotnet test` in this repository.

## Recommended Workflow

### 1. Choose the Acceptance Criteria and Scope
Start by identifying:

- the acceptance-criteria file
- the scenario or scenarios in scope
- what is explicitly out of scope for this implementation
- the business outcome that marks the slice done

If the file contains multiple scenarios, ask which scenario should be implemented first.

### 2. Identify the Slice Boundary
Clarify:

- whether the slice is a command or a query
- the business inputs and outputs
- validation rules that belong to the use case
- domain concepts that must exist or change
- persistence or integration needs
- which rules belong in `Application`, `Domain`, or `Infrastructure`

This step keeps the implementation focused and reduces accidental spread across unrelated concerns.

### 3. Plan the Failing Tests First
Before production code, decide which tests should fail:

- `Tests.Domain` for invariants, value objects, aggregates, policies, and domain events
- `Tests.Application` for orchestration, request and response behavior, validation, and port usage
- `Tests.Infrastructure` only for adapters with meaningful technical behavior

Follow repository test conventions:

- use NUnit + FluentAssertions
- structure tests with `Given / When / Then`
- name tests `Should_<ExpectedBehavior>_When_<Condition>`

### 4. Create the Minimal Application Slice Shell
Create the feature folder early so the slice has a stable home:

- `src\WindowsImageTool\src\WindowsImageTool.Application\Features\<Area>\<UseCase>\`

Common slice artifacts may include:

- command or query contract
- result contract
- service or handler
- validator when needed
- slice-specific ports or interfaces for outside dependencies

Reason for this order:

- the application layer defines the use-case boundary
- ports make infrastructure dependencies explicit
- tests can compile against a stable slice shape

Keep this shell minimal. Do not move business rules into `Application` just because the folder exists first.

### 5. Model the Domain DSL
Use the acceptance-criteria language to shape the domain:

- value objects for validated concepts without identity
- entities or aggregates where lifecycle and consistency rules matter
- policies or domain services when rules do not fit a single object
- domain events only when the business meaning requires them, and only aggregate roots raise them

This is where invariants live. The domain should explain the business, not the technical mechanism.

### 6. Implement the Application Behavior
Once the domain concepts and ports are clear:

- orchestrate the use case in the application slice
- call domain behavior instead of duplicating rules
- keep transport and infrastructure details out
- return clear result models aligned with the acceptance scenarios

### 7. Implement Infrastructure Adapters
Only after the ports and domain behavior are known:

- add persistence, filesystem, messaging, or external-service adapters in `Infrastructure`
- implement the exact contracts required by `Application`
- register implementations in infrastructure dependency injection
- keep side effects and subscriptions in `Infrastructure`, not `Application`

### 8. Wire Outer Layers Only If Needed
If the acceptance criteria requires a CLI, API, host, or presentation entry point:

- keep the entry point thin
- translate transport data into application contracts
- avoid business logic in outer layers

### 9. Validate and Align
Finish by:

- running targeted tests for the touched projects
- running a repository build
- checking names against the acceptance criteria
- updating the acceptance criteria if behavior intentionally changed
- confirming the slice is complete end to end

## Sequencing Guidance
Use this order by default:

1. acceptance criteria
2. scope and slice boundary
3. failing tests
4. minimal application slice and ports
5. domain DSL and invariants
6. application orchestration
7. infrastructure adapters and dependency injection
8. outer wiring if needed
9. targeted validation

This is slightly different from a strict application-first flow. The application shell can come before the domain implementation, but the domain language should be defined as soon as the slice boundary is clear. Infrastructure should come after the ports and domain behavior are known.

## Conversation Prompts
Use prompts like these while scoping the implementation:

- What acceptance-criteria file should we implement?
- Which scenario in that file is in scope first?
- Is this a command that changes state or a query that returns information?
- What business rule must always hold true?
- What output should the use case return on success?
- What should happen when the request violates a business rule?
- What data must be persisted or retrieved?
- Does this slice need a new infrastructure adapter or can it reuse an existing one?
- Should this port stay inside the slice, or is it truly shared?

## Writing and Coding Rules
- Prefer business names from the acceptance criteria over technical names.
- Keep new work inside the slice folder, not root-level technical buckets.
- Prefer `Features\<Area>\<UseCase>\` for new slices, even if older examples are flatter.
- Put application-owned interfaces in the slice unless they are clearly cross-cutting.
- Put invariants in `Domain`, not `Infrastructure`.
- Keep infrastructure implementations thin and explicit.
- Avoid silent fallbacks and broad catches.
- Update dependency injection when adding new ports or adapters.
- Verify behavior with automated tests before considering the slice done.

## Definition of Done
The workflow is complete when:

- the acceptance-criteria file and in-scope scenario are explicitly identified
- failing automated tests were written first
- the application slice exists with clear contracts and a use-case entry point
- the domain expresses the needed business language and rules
- infrastructure implements the required ports
- targeted tests pass for touched projects
- the relevant solution builds
- docs, tests, and code use consistent language

After the slice is complete, ask whether the user wants to implement the next scenario from the same acceptance-criteria file or review the finished slice.
