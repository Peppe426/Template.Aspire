---
name: deploy-release
description: Generates JSON changelogs for every tagged release from Conventional Commit history, then packages and publishes the real release build to GitHub Releases. Use this when asked to prepare a release, publish a release, deploy a release, or regenerate release changelogs.
---

# Deploy Release Skill

## Purpose

This skill prepares and publishes a release using the repository's Conventional Commit history.

It has two linked responsibilities:

1. generate one JSON changelog per tagged release under `docs\changelog`
2. package the real release artifact and publish it to GitHub Releases

The changelog files are intended to be durable release records, not ad hoc terminal output.

## Target Output

- Changelog folder: `docs\changelog`
- Changelog files: one JSON file per release version, for example `docs\changelog\v1.1.0.json`
- Build artifact: `artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<version>.nupkg`
- Publish target: the matching GitHub release for the requested tag
- Companion module: `.github\skills\deploy-release\ReleaseDeployment.psm1`

## Working Style

1. Start from an explicit release version when publishing. If the user did not provide one, ask for it.
2. Regenerate changelog JSON for all tagged releases before publishing the target release.
3. Treat Conventional Commit subjects as the source for release summaries and type counts.
4. Preserve non-standard commit types instead of collapsing everything into a fixed shortlist.
5. Use the real packed artifact from the repository, not a placeholder file.
6. Keep the release tag aligned with `.template.config\Template.Aspire.TemplatePackage.csproj`.
7. Prefer the companion script for repeatable changelog generation and publishing steps.

## Working Boundaries

- Do generate one JSON changelog file per tagged release.
- Do include an overall release description plus commit counts grouped by type.
- Do publish the actual packaged build to GitHub Releases when the user wants the release deployed.
- Do not invent release notes that are unsupported by the commit history.
- Do not publish a package whose version does not match the release tag.
- Do not leave the release process half-finished after packaging the real build.

## Recommended Workflow

### 1. Confirm the release target

If the user asked to publish a release, identify the exact version tag first.

- Preferred format: `v<major>.<minor>.<patch>`
- The package version in `.template.config\Template.Aspire.TemplatePackage.csproj` must match the tag without the `v` prefix

### 2. Regenerate changelog JSON files

Import the companion module and run the deployment function without publish switches to rebuild the changelog files:

```powershell
Import-Module .github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment
```

This should produce or refresh:

- `docs\changelog\v1.0.0.json`
- `docs\changelog\v1.1.0.json`
- and future release files that follow the same naming pattern

### 3. Review the target changelog

Check that the target release JSON includes:

- release metadata
- an overall summary of the release
- counts by Conventional Commit type such as `feat`, `fix`, `docs`, and `chore`
- the supporting commit entries

### 4. Publish the real release build

When the user wants the release deployed, run:

```powershell
Import-Module .github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment -ReleaseVersion v1.1.0 -PublishToGitHub
```

This should:

1. regenerate the changelog JSON files
2. pack the real `.nupkg`
3. upload the package to the matching GitHub release, or create that release if it does not exist yet

### 5. Confirm the result

After publishing:

- confirm the changelog file exists under `docs\changelog`
- confirm the package artifact exists under `artifacts\packages`
- confirm the GitHub release has the real package attached

## Conversation Prompts

Use prompts like these when the release target is unclear:

- What release version should we publish?
- Should I regenerate the changelog files for all tagged releases before publishing?
- Do you want to publish the real package to GitHub now, or only generate the changelog files?

## Definition of Done

This workflow is complete when:

- the release version is identified
- `docs\changelog` contains one JSON changelog per tagged release
- the target release JSON has an overall summary and type counts
- the real package has been built
- the GitHub release has the packaged build attached when publishing was requested
