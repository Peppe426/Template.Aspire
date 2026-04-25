# Template developer README

This file is for template maintainers only. It is intentionally **not** included in generated solutions.

The template output is controlled by `.template.config\template.json`, which only includes `.github`, `.gitignore`, `README.md`, `docs`, and `src`.
The generated solution now includes a minimal API service under `src\Template.ApiService` so the AppHost orchestrates a real project on first run.

## Build the repository

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
```

The test project now exercises the shared service defaults, so `dotnet test` validates actual repository behavior instead of discovering zero tests.

## Install and test the template locally

Install directly from the working tree when iterating on the template:

```powershell
dotnet new uninstall .
dotnet new install .
dotnet new template-aspire -n Contoso -o C:\temp\Contoso
```

Uninstall the local working-tree template when you are done:

```powershell
dotnet new uninstall .
```

## Pack the template

Create a distributable `.nupkg` from the template package project:

```powershell
dotnet pack .template.config\Template.Aspire.TemplatePackage.csproj -c Release -o artifacts\packages
```

## Versioning

Use **Semantic Versioning** for both template package versions and GitHub releases.

- NuGet package versions should use `<major>.<minor>.<patch>`, for example `1.0.0`.
- Git tags and GitHub releases should use `v<major>.<minor>.<patch>`, for example `v1.0.0`.
- The manual source of truth is `.template.config\Template.Aspire.TemplatePackage.csproj`. Bump its `<Version>` value first, then create the matching Git tag and GitHub release with the same number plus the `v` prefix.

## Publish the template package

Push the generated package to the target NuGet feed:

```powershell
dotnet nuget push artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<major>.<minor>.<patch>.nupkg --source <feed-url> --api-key <api-key>
```

## Release changelog and deployment skill

Use the deployment skill companion PowerShell module to regenerate the release changelog JSON files under `docs\changelog`:

```powershell
Import-Module .github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment
```

To publish the real packaged build to GitHub for an existing tag:

```powershell
Import-Module .github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment -ReleaseVersion v<major>.<minor>.<patch> -PublishToGitHub
```

The `docs\changelog` files are maintainer artifacts for this repository's release history and are excluded from generated solutions created from the template.

## Validate the packaged template

Install the packed `.nupkg` and scaffold a throwaway instance:

```powershell
dotnet new install artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<major>.<minor>.<patch>.nupkg
dotnet new template-aspire -n Contoso -o C:\temp\Contoso
dotnet new uninstall Peppe426.Template.Aspire.SolutionTemplate
```
