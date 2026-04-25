# Template

A .NET Aspire solution starter with the AppHost, a sample API service, shared service defaults, shared test infrastructure, and repository Copilot instructions already wired in.

[![Latest release](https://img.shields.io/github/v/release/Peppe426/Template.Aspire?display_name=tag)](https://github.com/Peppe426/Template.Aspire/releases/latest)

## Solution contents

- `src\Template.Aspire.slnx` is the main solution entrypoint.
- `src\Template.Aspire.AppHost` hosts the Aspire orchestration boundary.
- `src\Template.ApiService` is a minimal API service wired through the AppHost and shared defaults.
- `src\Template.Aspire.ServiceDefaults` centralizes service discovery, resilience, health checks, and OpenTelemetry defaults.
- `src\Tests\Tests.Core` provides the shared NUnit and FluentAssertions test stack plus baseline tests for the shared defaults.
- `.github\copilot-instructions.md` and `.github\instructions\*` carry the repository guidance used by Copilot.
- `.github\skills\*` contains repository-specific Copilot skills for acceptance-criteria-driven workflows.

## Getting started

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
dotnet run --project src\Template.Aspire.AppHost\Template.Aspire.AppHost.csproj
```

Running the AppHost now starts the sample API service. The service exposes:

- `/` for a simple JSON response
- `/health` and `/alive` in development through `MapDefaultEndpoints()`

## Copilot skills

This repository currently includes three custom Copilot skills under `.github\skills`.

| Skill | What it does | When to use it |
| --- | --- | --- |
| `create-acceptance-test` | Guides an interactive BDD conversation and turns the result into business-facing acceptance criteria written in Markdown with Gherkin-style scenarios. | Use this when you want to discover behavior, clarify edge cases, and document acceptance tests before any coding starts. |
| `implement-acceptance-criteria` | Takes an existing acceptance-criteria document and drives implementation work from it, including tests, slice boundaries, domain language, and required wiring. | Use this when the behavior is already agreed and you want Copilot to implement a focused vertical slice from that acceptance criteria. |
| `deploy-release` | Regenerates JSON changelog files for each tagged release from Conventional Commit history, then packs and publishes the real release build to GitHub Releases. | Use this when you want Copilot to prepare a release, rebuild changelog history, or publish the real package for a tagged version. |

Typical prompts:

- `Create acceptance tests for customer registration`
- `Write BDD scenarios for invoice approval`
- `Implement the acceptance criteria for order submission`
- `Deploy release v1.2.0`

The intended workflow is to define behavior first with `create-acceptance-test`, then move to implementation with `implement-acceptance-criteria`.

## Publishing a GitHub release

This repository uses **Semantic Versioning**. The manual source of truth is `.template.config\Template.Aspire.TemplatePackage.csproj`, where the template package `<Version>` should be set to `<major>.<minor>.<patch>`, for example `1.1.0`.

Git tags and GitHub releases must use that same version with a `v` prefix, for example `v1.1.0`.

The `deploy-release` skill regenerates `docs\changelog\v<version>.json` files for each tagged release from Conventional Commit history before packaging and publishing the real `.nupkg`.

```powershell
dotnet pack .template.config\Template.Aspire.TemplatePackage.csproj -c Release -o artifacts\packages
git tag -a v1.1.0 -m "v1.1.0"
git push origin v1.1.0
gh release create v1.1.0 artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.1.1.0.nupkg --generate-notes
```

In practice:

1. Update `.template.config\Template.Aspire.TemplatePackage.csproj` to the next package version.
2. Regenerate `docs\changelog` so each tagged release has a current JSON changelog.
3. Pack the template so the `.nupkg` name matches that version.
4. Create the matching Git tag and GitHub release with the same version plus the `v` prefix.

If you prefer the GitHub web UI, push the tag first and then create a release from **Releases** using the same version tag.
