[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Install
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$destination = Join-Path $repoRoot 'plugins/workiq'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("work-iq-sync-" + [guid]::NewGuid().ToString('N'))
$clonePath = Join-Path $tempRoot 'upstream'

if ((Test-Path $destination) -and -not $Force) {
    throw "'$destination' already exists. Re-run with -Force to replace it."
}

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    git clone --depth 1 --filter=blob:none --sparse https://github.com/microsoft/work-iq.git $clonePath
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone microsoft/work-iq.' }

    Push-Location $clonePath
    try {
        git sparse-checkout set plugins/workiq
        if ($LASTEXITCODE -ne 0) { throw 'Could not retrieve plugins/workiq from upstream.' }
        $upstreamCommit = (git rev-parse HEAD).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Could not determine the upstream commit.' }
    }
    finally {
        Pop-Location
    }

    $source = Join-Path $clonePath 'plugins/workiq'
    $manifestPath = Join-Path $source '.claude-plugin/plugin.json'
    if (-not (Test-Path (Join-Path $source 'skills/workiq/SKILL.md'))) {
        throw 'Upstream package is missing the Work IQ skill entry point.'
    }
    if (-not (Test-Path $manifestPath)) {
        throw 'Upstream package is missing its plugin manifest.'
    }
    $manifest = Get-Content -Raw -Path $manifestPath | ConvertFrom-Json

    if (Test-Path $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
    Copy-Item -Path $source -Destination $destination -Recurse

    Write-Host "Synced Work IQ $($manifest.version) from microsoft/work-iq commit $upstreamCommit."
    Write-Host "Plugin and skills copied to: $destination"

    if ($Install) {
        copilot plugin install $destination
        if ($LASTEXITCODE -ne 0) { throw 'Copilot CLI plugin installation failed.' }
        Write-Host 'Restart the Copilot CLI session to load the updated plugin.'
    }
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
