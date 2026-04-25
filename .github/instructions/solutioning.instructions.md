---
applyTo: "src/**/*.slnx,src/**/*.csproj,src/aspire.config.json,src/**/AppHost.cs,src/**/Extensions.cs"
---
# Solutioning instructions

- Keep `src/Template.Aspire.slnx` as the main solution entrypoint and add new projects there.
- Add new test projects under `src/Tests/` and place them in the `/Tests/` solution folder in `src/Template.Aspire.slnx`.
- Keep Aspire orchestration and distributed application composition in `src/Template.Aspire.AppHost/AppHost.cs`.
- Put reusable service bootstrapping in `src/Template.Aspire.ServiceDefaults` instead of duplicating telemetry, health check, resilience, or service discovery setup in each service.
- New service projects should reference `Template.Aspire.ServiceDefaults` and call `AddServiceDefaults()` during host setup.
- Web services that use the shared defaults should call `MapDefaultEndpoints()` so local readiness and liveness behavior stays consistent.
- Keep new projects aligned with the current baseline unless there is a deliberate reason to diverge: `TargetFramework` `net10.0`, `Nullable` enabled, and `ImplicitUsings` enabled.
- Update `src/aspire.config.json` only when the AppHost entry project changes.
