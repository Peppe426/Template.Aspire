# Template

A .NET Aspire solution starter with the AppHost, shared service defaults, shared test infrastructure, and repository Copilot instructions already wired in.

## Solution contents

- `src\Template.Aspire.slnx` is the main solution entrypoint.
- `src\Template.Aspire.AppHost` hosts the Aspire orchestration boundary.
- `src\Template.Aspire.ServiceDefaults` centralizes service discovery, resilience, health checks, and OpenTelemetry defaults.
- `src\Tests\Tests.Core` provides the shared NUnit and FluentAssertions test stack.
- `.github\copilot-instructions.md` and `.github\instructions\*` carry the repository guidance used by Copilot.

## Getting started

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
dotnet run --project src\Template.Aspire.AppHost\Template.Aspire.AppHost.csproj
```
