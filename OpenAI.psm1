Write-Host "OpenAI Powershell Module" -ForegroundColor Black -BackgroundColor Yellow -NoNewLine;
Write-Host -BackgroundColor Black
#region Global Variables
Write-Host "Loading: `$OpenAI"
$OpenAI = [PSCustomObject]@{
  Cfg = (Get-Content -Path "$PSScriptRoot\OpenAI.json" | ConvertFrom-JSON)
}
#endregion
foreach ($directory in @('Public')) {    
  Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse -File | ForEach-Object { 
    Write-Host "Loading: $directory\$($_.Name)" -ForegroundColor White -BackgroundColor Black -NoNewLine;
    Write-Host -BackgroundColor Black
    . $_.FullName 
  }
}

"$($OpenAI.Cfg.OpenAIPath)\api.token"

if (Test-Path -Path "$($OpenAI.Cfg.OpenAIPath)\api.token") {
  Get-Content -Path "$($OpenAI.Cfg.OpenAIPath)\api.token" | ConvertTo-SecureString | Set-OpenAIToken
}
else {
  Get-OpenAIToken | Set-OpenAIToken
}

# export
Export-ModuleMember -Variable OpenAI -Alias gii
