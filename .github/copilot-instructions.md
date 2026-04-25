# Copilot Instructions

## Build and test

- Build the current solution with `dotnet build src\Template.Aspire.slnx`.
- Run the current test project with `dotnet test src\Tests\Tests.Core\Tests.Core.csproj`.
- Run a single NUnit test with `dotnet test src\Tests\Tests.Core\Tests.Core.csproj --filter "FullyQualifiedName~Namespace.ClassName.TestName"`.
- Run the Aspire orchestrator locally with `dotnet run --project src\Template.Aspire.AppHost\Template.Aspire.AppHost.csproj`.
- There is no dedicated repository lint or format command checked in today.
- Never use emojis in repository files, generated content, or suggested edits.

## High-level architecture

- `src\Template.Aspire.slnx` is the main solution entrypoint. It currently includes the sample API service, the Aspire AppHost, the shared service defaults project, and the shared test project.
- `src\aspire.config.json` points Aspire tooling at `Template.Aspire.AppHost`.
- `src\Template.Aspire.AppHost\AppHost.cs` is the orchestration boundary. Add distributed resource registrations there and keep it focused on composition and startup.
- `src\Template.ApiService` is a minimal API service wired through the AppHost and shared defaults so the template orchestrates a real service on first run.
- `src\Template.Aspire.ServiceDefaults\Extensions.cs` is the shared infrastructure layer for service projects. It centralizes OpenTelemetry logging, metrics, tracing, default health checks, service discovery, and standard HTTP resilience.
- `src\Tests\Tests.Core` is the shared test project. It uses NUnit and FluentAssertions and currently includes baseline tests covering the shared service defaults behavior.

## Key conventions

- Put cross-cutting runtime setup in `Template.Aspire.ServiceDefaults`, not separately in each service project. New services should reference that project and call `AddServiceDefaults()` during host setup.
- Web services that use the shared defaults should expose readiness and liveness through `MapDefaultEndpoints()`. Those endpoints are development-only and fixed to `/health` and `/alive`.
- Tracing intentionally filters out `/health` and `/alive`, so avoid reintroducing those paths into telemetry unless the shared defaults are updated.
- Telemetry export is environment-driven: OTLP export only turns on when `OTEL_EXPORTER_OTLP_ENDPOINT` is set. Azure Monitor export is scaffolded in the shared defaults but intentionally commented out.
- `Tests.Core` currently provides `NUnit.Framework` as a global using for its own source files.
- Keep `FluentAssertions` pinned only in `src\Tests\Tests.Core\Tests.Core.csproj`; other test projects should reference `Tests.Core` instead of adding a direct `FluentAssertions` package reference.
- All current projects target `net10.0` with nullable reference types and implicit usings enabled. Keep new projects aligned with that baseline unless there is a deliberate reason to diverge.
- Use Semantic Versioning for package and release numbers. Package versions should be `<major>.<minor>.<patch>`, and GitHub release tags should be `v<major>.<minor>.<patch>`.
- Keep the template package version in `.template.config\Template.Aspire.TemplatePackage.csproj` as the manual source of truth. When cutting a release, bump that `<Version>` value first, then create the matching Git tag and GitHub release using the same number with a `v` prefix.

## Layered instructions

- For test files and test project changes under `src\Tests`, also apply [tests instructions](instructions/tests.instructions.md).
- For solution, project, and Aspire composition changes under `src`, also apply [solutioning instructions](instructions/solutioning.instructions.md).
- For PowerShell scripts, modules, and manifests, also apply [PowerShell instructions](instructions/powershell.instructions.md).

## Commit messages

- Use **Conventional Commits** when suggesting or creating commit messages.
- Preferred commit types in this repository are: `feat`, `chore`, `docs`, `test`, and `issue`.
- **Do not suggest `fix` by default.** `fix` is reserved for actual bug fixes only.
- Keep subjects short, imperative, and lowercase where practical.
- If a scope helps clarity, use the standard Conventional Commits shape: `<type>(<scope>): <subject>`.
- Prefer scopes that reflect the repo area or stage when useful, such as `stage-1`, `stage-3`, `pipeline`, or `docs`.
- If a change spans stages, make that visible in the scope or subject.
- If you are unsure how to phrase a commit, follow the Conventional Commits specification and choose the closest allowed type from the preferred list.
