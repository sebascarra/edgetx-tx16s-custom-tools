# Run from PowerShell: powershell -ExecutionPolicy Bypass -File .\apply.ps1
# Or hit the play button on VSCode.
$WIDGETS_PATH = 'C:\Users\sebas\Documents\Volar aviones\TX16S\SD_sync\WIDGETS'
$sourceFolder = Join-Path $PSScriptRoot './SwitchMap'
$destinationFolder = Join-Path $WIDGETS_PATH 'SwitchMap'

if (-not (Test-Path $sourceFolder)) {
    throw "Source folder not found: $sourceFolder"
}

New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null

if (Test-Path $destinationFolder) {
    Remove-Item $destinationFolder -Recurse -Force
}

Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse -Force