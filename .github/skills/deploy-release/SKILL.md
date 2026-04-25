---
name: deploy-release
description: Generates JSON changelogs for every tagged release from Conventional Commit history, then packages and publishes the real release build to GitHub Releases. Use this when asked to prepare a release, publish a release, deploy a release, or regenerate release changelogs.
---

# Deploy Release Skill

## Purpose

This skill prepares and publishes a release using the repository's Conventional Commit history.

It has three linked responsibilities:

1. generate one JSON changelog per tagged release under `docs\changelog`
2. maintain `docs\changelog\changelog.json` as the quick lookup for the latest production release and the latest RC per stage
3. package the real release artifact and publish it to GitHub Releases

The changelog files are intended to be durable release records, not ad hoc terminal output.

## Target Output

- Changelog folder: `docs\changelog`
- Changelog index: `docs\changelog\changelog.json`
- Changelog files: one JSON file per release version, for example `docs\changelog\v1.1.0.json`
- Build artifact: `artifacts\packages\Peppe426.Template.Aspire.SolutionTemplate.<version>.nupkg`
- Publish target: the matching GitHub release for the requested tag
- Companion module: `.github\skills\deploy-release\ReleaseDeployment.psm1`

## Working Style

1. Use `docs\changelog\changelog.json` as the convenient lookup for `latestProduction` and `latestReleaseCandidatesByStage`.
2. Start from an explicit release version when publishing. If the user did not provide one and the index does not resolve it cleanly, ask for it.
3. Regenerate changelog JSON for all tagged releases before publishing the target release.
4. Regenerate the root changelog index so the latest production release and stage RC candidates stay current.
5. Treat Conventional Commit subjects as the source for release summaries and type counts.
6. Preserve non-standard commit types instead of collapsing everything into a fixed shortlist.
7. Use the real packed artifact from the repository, not a placeholder file.
8. Keep the release tag aligned with `.template.config\Template.Aspire.TemplatePackage.csproj`.
9. Treat RC tags in the form `v<major>.<minor>.<patch>.rc-<n>` as stage candidates and derive the stage key from the release commits' dominant scope.
10. Prefer the companion script for repeatable changelog generation and publishing steps.

## Working Boundaries

- Do generate one JSON changelog file per tagged release.
- Do generate or refresh `docs\changelog\changelog.json`.
- Do include an overall release description plus commit counts grouped by type.
- Do publish the actual packaged build to GitHub Releases when the user wants the release deployed.
- Do not invent release notes that are unsupported by the commit history.
- Do not publish a package whose version does not match the release tag.
- Do not leave the release process half-finished after packaging the real build.

## Recommended Workflow

### 1. Confirm the release target

If the user asked to publish a release, identify the exact version tag first.

- Preferred format: `v<major>.<minor>.<patch>`
- RC format: `v<major>.<minor>.<patch>.rc-<n>`
- The package version in `.template.config\Template.Aspire.TemplatePackage.csproj` must match the tag without the `v` prefix
- `docs\changelog\changelog.json` should be the first place you check for the latest production release or the latest RC by stage

### 2. Regenerate changelog JSON files

Import the companion module and run the deployment function without publish switches to rebuild the changelog files:

```powershell
Import-Module .\.github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment
```

This should produce or refresh:

- `docs\changelog\changelog.json`
- `docs\changelog\v1.0.0.json`
- `docs\changelog\v1.1.0.json`
- and future release files that follow the same naming pattern

### 3. Review the target changelog

Check that the target release JSON includes:

- release metadata
- an overall summary of the release
- counts by Conventional Commit type such as `feat`, `fix`, `docs`, and `chore`
- the supporting commit entries

Also check that `docs\changelog\changelog.json` points to the latest production release and the latest RC entry for each stage key.

### 4. Publish the real release build

When the user wants the release deployed, run:

```powershell
Import-Module .\.github\skills\deploy-release\ReleaseDeployment.psm1 -Force
Invoke-ReleaseDeployment -ReleaseVersion v1.1.0 -PublishToGitHub
```

This should:

1. regenerate the changelog JSON files
2. regenerate `docs\changelog\changelog.json`
3. pack the real `.nupkg`
4. upload the package to the matching GitHub release, or create that release if it does not exist yet

### 5. Confirm the result

After publishing:

- confirm the changelog file exists under `docs\changelog`
- confirm `docs\changelog\changelog.json` points at the expected latest versions
- confirm the package artifact exists under `artifacts\packages`
- confirm the GitHub release has the real package attached

## Conversation Prompts

Use prompts like these when the release target is unclear:

- What release version should we publish?
- Which stage key in `docs\changelog\changelog.json` should I use for the RC target?
- Should I regenerate the changelog files for all tagged releases before publishing?
- Do you want to publish the real package to GitHub now, or only generate the changelog files?

## Definition of Done

This workflow is complete when:

- the release version is identified
- `docs\changelog` contains one JSON changelog per tagged release
- `docs\changelog\changelog.json` reflects the latest production release and latest RCs by stage
- the target release JSON has an overall summary and type counts
- the real package has been built
- the GitHub release has the packaged build attached when publishing was requested
