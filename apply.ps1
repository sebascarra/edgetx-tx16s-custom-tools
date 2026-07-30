# Run from PowerShell: powershell -ExecutionPolicy Bypass -File .\apply.ps1
# Or hit the play button on VSCode.
$WIDGETS_PATH = 'C:\Users\sebas\Documents\Volar aviones\TX16S\SD_sync\WIDGETS'
$SOURCE_FOLDERS = @('SwitchMap', 'FlyTime')

# Ensure we have a script root when running interactively in the console
if (-not $PSScriptRoot) {
    $scriptRoot = (Get-Location).ProviderPath
} else {
    $scriptRoot = $PSScriptRoot
}

foreach ($folderName in $SOURCE_FOLDERS) {
    $sourceFolder = Join-Path $scriptRoot $folderName
    $destinationFolder = Join-Path $WIDGETS_PATH $folderName

    if (-not (Test-Path $sourceFolder)) {
        Write-Warning "Source folder not found: $sourceFolder - skipping"
        continue
    }

    if (Test-Path $destinationFolder) {
        Remove-Item $destinationFolder -Recurse -Force
    }

    Copy-Item -Path $sourceFolder -Destination $destinationFolder -Recurse -Force
}