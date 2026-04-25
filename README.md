# Template

A .NET Aspire solution starter with the AppHost, shared service defaults, shared test infrastructure, and repository Copilot instructions already wired in.

[![Latest release](https://img.shields.io/github/v/release/Peppe426/Template.Aspire?display_name=tag)](https://github.com/Peppe426/Template.Aspire/releases/latest)

## Solution contents

- `src\Template.Aspire.slnx` is the main solution entrypoint.
- `src\Template.Aspire.AppHost` hosts the Aspire orchestration boundary.
- `src\Template.Aspire.ServiceDefaults` centralizes service discovery, resilience, health checks, and OpenTelemetry defaults.
- `src\Tests\Tests.Core` provides the shared NUnit and FluentAssertions test stack.
- `.github\copilot-instructions.md` and `.github\instructions\*` carry the repository guidance used by Copilot.
- `.github\skills\*` contains repository-specific Copilot skills for acceptance-criteria-driven workflows.

## Getting started

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
dotnet run --project src\Template.Aspire.AppHost\Template.Aspire.AppHost.csproj
```

## Copilot skills

This repository currently includes two custom Copilot skills under `.github\skills`.

| Skill | What it does | When to use it |
| --- | --- | --- |
| `create-acceptance-test` | Guides an interactive BDD conversation and turns the result into business-facing acceptance criteria written in Markdown with Gherkin-style scenarios. | Use this when you want to discover behavior, clarify edge cases, and document acceptance tests before any coding starts. |
| `implement-acceptance-criteria` | Takes an existing acceptance-criteria document and drives implementation work from it, including tests, slice boundaries, domain language, and required wiring. | Use this when the behavior is already agreed and you want Copilot to implement a focused vertical slice from that acceptance criteria. |

Typical prompts:

- `Create acceptance tests for customer registration`
- `Write BDD scenarios for invoice approval`
- `Implement the acceptance criteria for order submission`

The intended workflow is to define behavior first with `create-acceptance-test`, then move to implementation with `implement-acceptance-criteria`.

## Publishing a GitHub release

Use a semantic version tag and publish the release from that tag.

```powershell
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
gh release create v0.1.0 --generate-notes
```

If you prefer the GitHub web UI, push the tag first and then create a release from **Releases** using the same version tag.
