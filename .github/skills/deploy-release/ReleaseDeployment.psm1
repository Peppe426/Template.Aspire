Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:StandardCommitTypes = @(
    'feat',
    'fix',
    'docs',
    'chore',
    'refactor',
    'test',
    'perf',
    'build',
    'ci',
    'style',
    'revert',
    'other'
)

$script:ProductionReleaseTagPattern = '^v\d+\.\d+\.\d+$'
$script:ReleaseCandidateTagPattern = '^v\d+\.\d+\.\d+\.rc-\d+$'
$script:SupportedReleaseTagPattern = '^v\d+\.\d+\.\d+(?:\.rc-\d+)?$'

function Invoke-ToolCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string[]]$Arguments,

        [Parameter()]
        [switch]$AllowFailure
    )

    Get-Command -Name $FilePath -ErrorAction Stop | Out-Null

    $output = & $FilePath @Arguments 2>&1 | ForEach-Object { "$_" }
    $exitCode = $LASTEXITCODE

    if (-not $AllowFailure -and $exitCode -ne 0) {
        $message = ($output | Out-String).Trim()
        throw "Command '$FilePath $($Arguments -join ' ')' failed with exit code $exitCode. $message"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output)
    }
}

function Get-PackageMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ProjectPath
    )

    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Leaf)) {
        throw "Package project '$ProjectPath' was not found."
    }

    [xml]$project = Get-Content -LiteralPath $ProjectPath -Raw

    $packageId = "$($project.Project.PropertyGroup.PackageId)".Trim()
    $version = "$($project.Project.PropertyGroup.Version)".Trim()

    if ([string]::IsNullOrWhiteSpace($packageId)) {
        throw "PackageId was not found in '$ProjectPath'."
    }

    if ([string]::IsNullOrWhiteSpace($version)) {
        throw "Version was not found in '$ProjectPath'."
    }

    return [pscustomobject]@{
        PackageId = $packageId
        Version = $version
        Tag = "v$version"
    }
}

function Get-ReleaseTags {
    [CmdletBinding()]
    param()

    $result = Invoke-ToolCommand -FilePath 'git' -Arguments @('tag', '--sort=version:refname')

    return @(
        $result.Output |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -match $script:SupportedReleaseTagPattern }
    )
}

function Test-ProductionReleaseTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    return $Tag -match $script:ProductionReleaseTagPattern
}

function Test-ReleaseCandidateTag {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    return $Tag -match $script:ReleaseCandidateTagPattern
}

function Get-ReleaseDate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    $tagDate = (Invoke-ToolCommand -FilePath 'git' -Arguments @('for-each-ref', "refs/tags/$Tag", '--format=%(taggerdate:iso8601-strict)')).Output |
        Select-Object -First 1

    if (-not [string]::IsNullOrWhiteSpace($tagDate)) {
        return $tagDate.Trim()
    }

    return ((Invoke-ToolCommand -FilePath 'git' -Arguments @('log', '-1', '--format=%aI', $Tag)).Output |
        Select-Object -First 1).Trim()
}

function ConvertTo-CommitEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Sha,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Subject
    )

    $match = [regex]::Match($Subject, '^(?<type>[a-z]+)(\((?<scope>[^)]+)\))?(?<breaking>!)?: (?<description>.+)$')

    if ($match.Success) {
        return [ordered]@{
            sha = $Sha
            shortSha = $Sha.Substring(0, 7)
            subject = $Subject
            type = $match.Groups['type'].Value
            scope = if ($match.Groups['scope'].Success) { $match.Groups['scope'].Value } else { $null }
            isBreakingChange = $match.Groups['breaking'].Success
            isConventional = $true
            description = $match.Groups['description'].Value
        }
    }

    return [ordered]@{
        sha = $Sha
        shortSha = $Sha.Substring(0, 7)
        subject = $Subject
        type = 'other'
        scope = $null
        isBreakingChange = $false
        isConventional = $false
        description = $Subject
    }
}

function Get-ReleaseCommits {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag,

        [Parameter()]
        [string]$PreviousTag
    )

    $format = '--format=%H%x1f%s'
    $arguments = @('log', '--reverse', $format)

    if ([string]::IsNullOrWhiteSpace($PreviousTag)) {
        $arguments += $Tag
    }
    else {
        $arguments += "$PreviousTag..$Tag"
    }

    $lines = (Invoke-ToolCommand -FilePath 'git' -Arguments $arguments).Output
    $commits = [System.Collections.Generic.List[object]]::new()

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $parts = $line -split [char]0x1f, 2

        if ($parts.Count -lt 2) {
            continue
        }

        $commits.Add((ConvertTo-CommitEntry -Sha $parts[0] -Subject $parts[1]))
    }

    return @($commits)
}

function Get-TypeCounts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Commits
    )

    $counts = [ordered]@{}

    foreach ($type in $script:StandardCommitTypes) {
        $counts[$type] = 0
    }

    foreach ($commit in $Commits) {
        $type = "$($commit.type)".Trim()

        if ([string]::IsNullOrWhiteSpace($type)) {
            $type = 'other'
        }

        if (-not $counts.Contains($type)) {
            $counts[$type] = 0
        }

        $counts[$type]++
    }

    return $counts
}

function Get-PrimaryType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.IDictionary]$TypeCounts
    )

    $nonZeroTypes = @(
        $TypeCounts.GetEnumerator() |
            Where-Object { $_.Value -gt 0 } |
            Sort-Object -Property @{ Expression = 'Value'; Descending = $true }, @{ Expression = 'Name'; Descending = $false }
    )

    if ($nonZeroTypes.Count -eq 0) {
        return 'other'
    }

    return "$($nonZeroTypes[0].Name)"
}

function Get-TypeMixSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.IDictionary]$TypeCounts
    )

    $parts = @(
        $TypeCounts.GetEnumerator() |
            Where-Object { $_.Value -gt 0 } |
            Sort-Object -Property @{ Expression = 'Value'; Descending = $true }, @{ Expression = 'Name'; Descending = $false } |
            ForEach-Object { "$($_.Value) $($_.Name)" }
    )

    if ($parts.Count -eq 0) {
        return '0 commits'
    }

    return $parts -join ', '
}

function Get-ReleaseFocus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PrimaryType
    )

    switch ($PrimaryType) {
        'feat' { return 'Feature-focused release' }
        'fix' { return 'Fix-focused release' }
        'docs' { return 'Documentation-focused release' }
        'chore' { return 'Maintenance-focused release' }
        'refactor' { return 'Refactoring-focused release' }
        'test' { return 'Testing-focused release' }
        'perf' { return 'Performance-focused release' }
        'build' { return 'Build-focused release' }
        'ci' { return 'CI-focused release' }
        'style' { return 'Style-focused release' }
        'revert' { return 'Rollback-focused release' }
        default { return 'Release update' }
    }
}

function Get-ReleaseHighlights {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Commits
    )

    $priority = @('feat', 'fix', 'perf', 'refactor', 'docs', 'test', 'chore', 'build', 'ci', 'style', 'revert', 'other')
    $highlights = [System.Collections.Generic.List[string]]::new()

    foreach ($type in $priority) {
        foreach ($commit in $Commits | Where-Object { $_.type -eq $type }) {
            $candidate = "$($commit.description)".Trim()

            if ([string]::IsNullOrWhiteSpace($candidate)) {
                continue
            }

            if (-not $highlights.Contains($candidate)) {
                $highlights.Add($candidate)
            }

            if ($highlights.Count -ge 3) {
                return @($highlights)
            }
        }
    }

    return @($highlights)
}

function Get-ReleaseSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Commits,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.IDictionary]$TypeCounts
    )

    if ($Commits.Count -eq 0) {
        return 'Release recorded with no commits in the resolved range.'
    }

    $focus = Get-ReleaseFocus -PrimaryType (Get-PrimaryType -TypeCounts $TypeCounts)
    $mix = Get-TypeMixSummary -TypeCounts $TypeCounts
    $highlights = @(Get-ReleaseHighlights -Commits $Commits)

    if ($highlights.Count -eq 0) {
        return "$focus with $mix."
    }

    return "$focus with $mix. Key changes: $($highlights -join '; ')."
}

function Get-ScopeCounts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Commits
    )

    $counts = [ordered]@{}

    foreach ($commit in $Commits) {
        $scope = "$($commit.scope)".Trim()

        if ([string]::IsNullOrWhiteSpace($scope)) {
            continue
        }

        if (-not $counts.Contains($scope)) {
            $counts[$scope] = 0
        }

        $counts[$scope]++
    }

    return $counts
}

function Get-ReleaseStageKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Commits
    )

    $scopeCounts = Get-ScopeCounts -Commits $Commits
    $rankedScopes = @(
        $scopeCounts.GetEnumerator() |
            Sort-Object -Property @{ Expression = 'Value'; Descending = $true }, @{ Expression = 'Name'; Descending = $false }
    )

    if ($rankedScopes.Count -eq 0) {
        return 'unspecified'
    }

    return "$($rankedScopes[0].Name)"
}

function New-ChangelogIndexEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseDate,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageVersion,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ChangelogFileName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Summary
    )

    return [ordered]@{
        version = $Tag
        releaseDate = $ReleaseDate
        packageVersion = $PackageVersion
        changelogFile = $ChangelogFileName
        summary = $Summary
    }
}

function Write-JsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Value
    )

    $directoryPath = Split-Path -Path $FilePath -Parent

    if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
        New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 8
    Set-Content -LiteralPath $FilePath -Value $json -Encoding utf8
}

function Test-GitHubReleaseExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Tag
    )

    $result = Invoke-ToolCommand -FilePath 'gh' -Arguments @('release', 'view', $Tag, '--json', 'tagName') -AllowFailure
    return $result.ExitCode -eq 0
}

function Invoke-ReleaseDeployment {
    <#
    .SYNOPSIS
    Generates JSON changelog files for tagged releases and optionally publishes the real release package to GitHub.

    .EXAMPLE
    Import-Module .\.github\skills\deploy-release\ReleaseDeployment.psm1 -Force
    Invoke-ReleaseDeployment

    .EXAMPLE
    Import-Module .\.github\skills\deploy-release\ReleaseDeployment.psm1 -Force
    Invoke-ReleaseDeployment -ReleaseVersion 'v1.1.0' -PublishToGitHub
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [ValidatePattern('^v\d+\.\d+\.\d+(?:\.rc-\d+)?$')]
        [string]$ReleaseVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..')),

        [Parameter()]
        [switch]$PublishToGitHub
    )

    $packageProjectPath = Join-Path $RepositoryRoot '.template.config\Template.Aspire.TemplatePackage.csproj'
    $packageOutputDirectoryPath = Join-Path $RepositoryRoot 'artifacts\packages'
    $changelogDirectoryPath = Join-Path $RepositoryRoot 'docs\changelog'

    if (-not (Test-Path -LiteralPath $RepositoryRoot -PathType Container)) {
        throw "Repository root '$RepositoryRoot' was not found."
    }

    Push-Location -Path $RepositoryRoot

    try {
        $packageMetadata = Get-PackageMetadata -ProjectPath $packageProjectPath
        $targetReleaseTag = if ([string]::IsNullOrWhiteSpace($ReleaseVersion)) { $packageMetadata.Tag } else { $ReleaseVersion }
        $releaseTags = @(Get-ReleaseTags)
        $changelogIndexFilePath = Join-Path $changelogDirectoryPath 'changelog.json'

        if ($releaseTags.Count -eq 0) {
            throw 'No supported release tags were found in the repository.'
        }

        $generatedFiles = [System.Collections.Generic.List[string]]::new()
        $changelogIndex = [ordered]@{
            latestProduction = $null
            latestReleaseCandidatesByStage = [ordered]@{}
        }
        $previousTag = $null

        foreach ($tag in $releaseTags) {
            $commits = @(Get-ReleaseCommits -Tag $tag -PreviousTag $previousTag)
            $typeCounts = Get-TypeCounts -Commits $commits
            $artifactVersion = $tag.TrimStart('v')
            $changelogFileName = "$tag.json"
            $changelog = [ordered]@{
                version = $tag
                releaseDate = Get-ReleaseDate -Tag $tag
                range = [ordered]@{
                    from = if ([string]::IsNullOrWhiteSpace($previousTag)) { $null } else { $previousTag }
                    to = $tag
                }
                artifact = [ordered]@{
                    packageId = $packageMetadata.PackageId
                    packageVersion = $artifactVersion
                    fileName = "$($packageMetadata.PackageId).$artifactVersion.nupkg"
                }
                summary = Get-ReleaseSummary -Commits $commits -TypeCounts $typeCounts
                commitTotal = $commits.Count
                conventionalCommitTotal = @($commits | Where-Object { $_.isConventional }).Count
                breakingChangeTotal = @($commits | Where-Object { $_.isBreakingChange }).Count
                typeCounts = $typeCounts
                commits = @($commits)
            }

            $changelogFilePath = Join-Path $changelogDirectoryPath $changelogFileName
            Write-JsonFile -FilePath $changelogFilePath -Value $changelog
            $generatedFiles.Add($changelogFilePath)

            $indexEntry = New-ChangelogIndexEntry -Tag $tag -ReleaseDate $changelog.releaseDate -PackageVersion $artifactVersion -ChangelogFileName $changelogFileName -Summary $changelog.summary

            if (Test-ProductionReleaseTag -Tag $tag) {
                $changelogIndex.latestProduction = $indexEntry
            }
            elseif (Test-ReleaseCandidateTag -Tag $tag) {
                $stageKey = Get-ReleaseStageKey -Commits $commits
                $indexEntry.stage = $stageKey
                $changelogIndex.latestReleaseCandidatesByStage[$stageKey] = $indexEntry
            }

            $previousTag = $tag
        }

        Write-JsonFile -FilePath $changelogIndexFilePath -Value $changelogIndex
        $generatedFiles.Add($changelogIndexFilePath)

        $packagePath = $null

        if ($PublishToGitHub) {
            if ($targetReleaseTag -ne $packageMetadata.Tag) {
                throw "Release tag '$targetReleaseTag' does not match package version '$($packageMetadata.Version)'."
            }

            if ($releaseTags -notcontains $targetReleaseTag) {
                throw "Release tag '$targetReleaseTag' was not found. Create and push the tag before publishing."
            }

            if (-not (Test-Path -LiteralPath $packageOutputDirectoryPath -PathType Container)) {
                New-Item -ItemType Directory -Path $packageOutputDirectoryPath -Force | Out-Null
            }

            if ($PSCmdlet.ShouldProcess($packageProjectPath, "Pack release artifact for $targetReleaseTag")) {
                Invoke-ToolCommand -FilePath 'dotnet' -Arguments @(
                    'pack',
                    '.template.config\Template.Aspire.TemplatePackage.csproj',
                    '-c',
                    'Release',
                    '-o',
                    $packageOutputDirectoryPath
                ) | Out-Null
            }

            $packagePath = Join-Path $packageOutputDirectoryPath "$($packageMetadata.PackageId).$($packageMetadata.Version).nupkg"

            if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
                throw "Expected package '$packagePath' was not found after packing."
            }

            if (Test-GitHubReleaseExists -Tag $targetReleaseTag) {
                if ($PSCmdlet.ShouldProcess($targetReleaseTag, "Upload $packagePath to the existing GitHub release")) {
                    Invoke-ToolCommand -FilePath 'gh' -Arguments @(
                        'release',
                        'upload',
                        $targetReleaseTag,
                        $packagePath,
                        '--clobber'
                    ) | Out-Null
                }
            }
            elseif ($PSCmdlet.ShouldProcess($targetReleaseTag, "Create a GitHub release and upload $packagePath")) {
                Invoke-ToolCommand -FilePath 'gh' -Arguments @(
                    'release',
                    'create',
                    $targetReleaseTag,
                    $packagePath,
                    '--title',
                    $targetReleaseTag,
                    '--generate-notes'
                ) | Out-Null
            }
        }

        return [pscustomobject]@{
            ReleaseVersion = $targetReleaseTag
            GeneratedChangelogFiles = @($generatedFiles)
            PublishedToGitHub = $PublishToGitHub.IsPresent
            PackagePath = $packagePath
        }
    }
    finally {
        Pop-Location
    }
}

Export-ModuleMember -Function Invoke-ReleaseDeployment
