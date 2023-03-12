[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$Path
)

try {
  $SrcItem = Get-Item -Path $Path -ErrorAction Stop
}
catch {
  Write-Host "File IO error!"
  return
}

if ($SrcItem.Extension.ToLower() -eq ".gif" ) {
  $items = Get-ImageInformation -Path $Path
  if ($items.Length -gt 0) {
    $folderPath = "$($SrcItem.Directory)\$($SrcItem.BaseName)-frames"
    if (Test-Path -Path $folderPath ) { 
      Remove-Item -Path "$folderPath\*.gif" -Force -Verbose
    }
    else {
      New-Item -Path "$($SrcItem.Directory)\$($SrcItem.BaseName)-frames" -ItemType Directory -Force -Verbose
    }
    & $OpenAI.cfg.MagickPath convert $SrcItem.FullName -coalesce "$folderPath\$($SrcItem.BaseName)-%d$($SrcItem.Extension)"

    $info = @()
    $ms = 0
    $info = [PSCustomObject]@{
      TotalDurationMs = $null
      Sequence        = @()
    }
    foreach ($i in 0..($items.Length - 1)) {
      $framePath = "$folderPath\$($SrcItem.BaseName)-$i$($srcItem.Extension)"
      $frameItem = Get-Item -Path $framePath
      $info.Sequence += [PSCustomObject]@{
        Path       = $frameItem.Name
        DelayMs    = $items[$i].Delay * 10
        FromTimeMs = $ms
        ToTimeMs   = $ms + $items[$i].Delay * 10
        Width      = $items[$i].PageWidth
        Height     = $items[$i].PageHeight
      }
      $ms += $items[$i].Delay * 10
    }
    $info.TotalDurationMs = $ms
    $info | ConvertTo-Json | Out-File -Path "$folderPath\$($SrcItem.BaseName)-info.json"
  }  
}
