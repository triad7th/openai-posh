$targetPath = "$Home\Documents\PowerShell\Modules\OpenAI"
Write-Host "Remove old copy..."
if (Test-Path $targetPath) {
    Remove-Item -Path $targetPath -Recurse -Force -Verbose
}
Write-Host "Installation..."
New-Item -Type Directory -Path $targetPath -Verbose | Out-Null
foreach ($item in @('Public', 'Private', 'OpenAI.*')) {
    Copy-Item -Path "$PSScriptRoot\$item" $targetPath -Recurse -Force -Verbose
}

Write-Host "Installed!"
Write-Host ""
Write-Host "Usage"
Write-Host "-----"
Write-Host "Import-Module OpenAI"