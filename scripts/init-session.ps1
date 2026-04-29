# Initialize planning database for a new session
# Usage: .\init-session.ps1 [project-name]

param(
    [string]$ProjectName = "project"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DbPath = Join-Path (Get-Location) "planning.db"

Write-Host "Initializing planning database for: $ProjectName"

if (-not (Test-Path $DbPath)) {
    python "$ScriptDir\init_db.py" $DbPath
} else {
    Write-Host "planning.db already exists, skipping initialization"
}

Write-Host ""
Write-Host "Planning database initialized at: $DbPath"
