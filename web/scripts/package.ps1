$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$distRoot = Join-Path $projectRoot 'dist'
$launcher = Join-Path $distRoot 'game/index.html'
if (-not (Test-Path -LiteralPath (Join-Path $distRoot 'index.html'))) {
    throw 'Run npm run build first.'
}
# Only the authenticated host is an HTML entry in the production package.
if (Test-Path -LiteralPath $launcher) { Remove-Item -LiteralPath $launcher }
$archivePath = Join-Path $projectRoot 'escape-island-web.zip'
Compress-Archive -Path (Join-Path $distRoot '*') -DestinationPath $archivePath -Force
Get-Item -LiteralPath $archivePath | Select-Object FullName, Length
