# Template

A .NET Aspire starter solution with a working AppHost, a sample API service, shared service defaults, shared tests, and Copilot guidance already wired in.

[![Latest release](https://img.shields.io/github/v/release/Peppe426/Template.Aspire?display_name=tag)](https://github.com/Peppe426/Template.Aspire/releases/latest)

## What you get

- `src\Template.Aspire.slnx` as the main solution entrypoint
- `src\Template.Aspire.AppHost` to orchestrate local development
- `src\Template.ApiService` as a minimal API service you can replace or extend
- `src\Template.Aspire.ServiceDefaults` for health checks, service discovery, resilience, and telemetry defaults
- `src\Tests\Tests.Core` for the shared NUnit and FluentAssertions test setup
- `.github\copilot-instructions.md`, `.github\instructions\*`, and `.github\skills\*` to guide day-to-day Copilot usage

## Get started with the template

Install the template and scaffold a new solution:

```powershell
dotnet new install .
dotnet new template-aspire -n Contoso -o C:\temp\Contoso
```

Then open the generated solution and run the usual development loop:

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
dotnet run --project src\Template.Aspire.AppHost\Template.Aspire.AppHost.csproj
```

The AppHost starts the sample API service. In development, the sample service exposes:

- `/` for a simple JSON response
- `/health` and `/alive` through `MapDefaultEndpoints()`

## Working with the skills

The template ships with three custom Copilot skills under `.github\skills`. A practical day-to-day flow looks like this:

| Goal | Skill | Example prompt |
| --- | --- | --- |
| Clarify behavior before coding | `create-acceptance-test` | `Create acceptance tests for customer registration` |
| Implement the agreed behavior | `implement-acceptance-criteria` | `Implement the acceptance criteria for order submission` |
| Cut or refresh a tagged release | `deploy-release` | `Deploy release v1.2.0` |

The usual rhythm is:

1. Start with `create-acceptance-test` when the behavior is still fuzzy.
2. Move to `implement-acceptance-criteria` once the scenarios are agreed.
3. Use normal build, test, and AppHost runs while you iterate.
4. Use `deploy-release` only when you are ready to publish a tagged version.

If you want a simple default prompt sequence, use:

1. `Create acceptance tests for <feature>`
2. `Implement the acceptance criteria for <feature>`
3. `Deploy release v<major>.<minor>.<patch>`

## Maintainer note

This README is meant to stay focused on getting started. For packing, versioning, and release details for the template repository itself, use `DEVELOPER-README.md`.
