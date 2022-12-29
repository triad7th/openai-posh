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

Get-OpenAIToken | Set-OpenAIToken
Export-ModuleMember -Variable OpenAI