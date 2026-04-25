# Template developer README

This file is for template maintainers only. It is intentionally **not** included in generated solutions.

The template output is controlled by `.template.config\template.json`, which only includes `.github`, `.gitignore`, `README.md`, `docs`, and `src`.

## Build the repository

```powershell
dotnet build src\Template.Aspire.slnx
dotnet test src\Tests\Tests.Core\Tests.Core.csproj
```

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

## Publish the template package

Push the generated package to the target NuGet feed:

```powershell
dotnet nuget push artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<version>.nupkg --source <feed-url> --api-key <api-key>
```

## Validate the packaged template

Install the packed `.nupkg` and scaffold a throwaway instance:

```powershell
dotnet new install artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<version>.nupkg
dotnet new template-aspire -n Contoso -o C:\temp\Contoso
dotnet new uninstall Peppe426.Template.Aspire.SolutionTemplate
```
