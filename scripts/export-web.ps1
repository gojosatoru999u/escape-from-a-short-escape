param([string]$Godot = 'godot')
$ErrorActionPreference = 'Stop'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$gameRoot = Join-Path $repoRoot 'game'
$exportRoot = Join-Path $repoRoot 'web/public/game'
New-Item -ItemType Directory -Path $exportRoot -Force | Out-Null
& $Godot --headless --editor --path $gameRoot --import
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
& $Godot --headless --path $gameRoot --export-release Web
if ($LASTEXITCODE -ne 0) { throw 'Godot Web export failed. Check Godot 4.3 export templates.' }
Write-Output "Godot Web export ready: $exportRoot"
