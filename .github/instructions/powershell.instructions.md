---
description: "Use when writing or editing PowerShell scripts, modules, and manifests in this repository."
applyTo: "**/*.ps1,**/*.psm1,**/*.psd1"
---
# PowerShell instructions

- Keep PowerShell code automation-friendly. Prefer cmdlet-style functions, explicit parameters, and object output over host-only behavior.
- Use approved PowerShell verbs and `Verb-Noun` names for functions and script entry points.
- Do not use aliases in committed code. Use full cmdlet names so scripts stay readable and predictable.
- Use 4-space indentation and keep formatting consistent within each file.

## Script and function structure

- Entry-point scripts and exported functions should include comment-based help with at least a synopsis and a runnable example when the usage is not obvious.
- Scripts and advanced functions that accept parameters should use `[CmdletBinding()]`.
- Use typed parameters and validation attributes where they clarify the contract, such as `[Parameter(Mandatory)]`, `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`, and `[ValidatePattern()]`.
- For scripts and modules with executable logic, enable strict behavior near the top with:

  ```powershell
  Set-StrictMode -Version Latest
  $ErrorActionPreference = 'Stop'
  ```

## Naming

- Functions: `Verb-NounPhrase` using approved PowerShell verbs.
- Prefer names that describe intent clearly using standard verbs such as `Get`, `Set`, `New`, `Remove`, `Test`, `Import`, `Export`, `Start`, `Stop`, `Invoke`, `Update`, and `Resolve`.
- File names should be descriptive and consistent with the script or module purpose. Do not rely on naming conventions from another repository unless this repository adopts them explicitly.

## Error handling

- Validate inputs early and fail clearly.
- Use `throw` for terminating failures. Use `Write-Warning`, `Write-Verbose`, and `Write-Information` for non-fatal diagnostics.
- Avoid `Write-Host` unless the script is intentionally interactive and the output is meant only for a human.
- Use `try`/`catch` only when you can add useful context, translate the error, or clean up resources. Do not swallow errors.
- Validate paths with `Test-Path -LiteralPath` and distinguish files from directories with `-PathType` where relevant.
- Trim and null-check user-provided strings with `[string]::IsNullOrWhiteSpace()` when empty input is invalid.

## Strings and types

- Single quotes for literal strings: `'value'`.
- Double quotes only when string interpolation or escape sequences are needed.
- Use typed parameters, strongly shaped objects, and explicit casts when values come from untyped input such as data files or environment variables.

## Files, configuration, and output

- Prefer `.psd1` PowerShell data files for structured configuration when PowerShell-native configuration is appropriate, and load them with `Import-PowerShellDataFile`.
- Keep `.psd1` files as data only; do not put executable logic in them.
- Never hard-code secrets, machine-specific paths, or environment-specific values when they can be supplied through parameters, configuration, or environment variables.
- Prefer `Join-Path` over string concatenation for paths.
- Use `$PSScriptRoot` to resolve files relative to the script or module.
- Return objects from functions instead of formatted text when the output may be consumed by another command or script.

## Safe command design

- For commands that change state, consider `[CmdletBinding(SupportsShouldProcess)]` and use `$PSCmdlet.ShouldProcess(...)` for destructive or high-impact operations.
- Prefer splatting for long command invocations so parameter intent stays readable.
- Use `System.Collections.Generic.List[T]` or pipeline-based accumulation when building collections incrementally. Avoid `+=` on arrays inside loops.
