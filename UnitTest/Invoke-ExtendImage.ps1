[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$Src,
  [string]$Dest,
  [decimal]$Width,
  [decimal]$Height,
  [decimal]$GrowAmount = 1024,
  [switch]$WhatIf
)

try {
  $SrcItem = Get-Item -Path $Src -ErrorAction Stop
  $TempSrc = "$($SrcItem.Directory)\$($SrcItem.BaseName)_src_$([Guid]::NewGuid())$($SrcItem.Extension)"
  $TempDest = "$($SrcItem.Directory)\$($SrcItem.BaseName)_dest_$([Guid]::NewGuid())$($SrcItem.Extension)"
  New-Item -Path $TempSrc | Out-Null
  Copy-Item -Path $Src -Destination $TempDest -Force
  $TempSrcItem = Get-Item -Path $TempSrc
  $TempDestItem = Get-Item -Path $TempDest
  $SrcInfo = Get-ImageInformation -Path $SrcItem
  $BeginScore = $SrcInfo.Width + $SrcInfo.Height - 1
  $TargetScore = $Width + $Height
}
catch {
  "File IO error!"
  return
}

function progress() {
  $TempSrcInfo = Get-ImageInformation -Path $TempSrc
  $CurrentScore = $TempSrcInfo.Width + $TempSrcInfo.Height

  $percentage = [Math]::Max([Math]::Min(($CurrentScore - $BeginScore) / ($TargetScore - $BeginScore), 1) * 100 , 1)
  Write-Progress -Activity "Expanding Image" `
    -Status "$($TempSrcInfo.Width)x$($TempSrcInfo.Height)" `
    -PercentComplete $percentage
}

for ($stage = 0; $response.IsDone -ne $true; $stage++ ) {
  Write-OutPutTitle "Stage $($Stage)" -Large
  Copy-Item -Path $TempDest -Destination $TempSrc -Force
  progress
  if ($WhatIf) {
    $response = .\Invoke-GrowImage.ps1 `
      -Src $TempSrcItem.FullName `
      -Dest $TempDestItem.FullName `
      -GrowAmount $GrowAmount `
      -MaxWidth $Width `
      -MaxHeight $Height `
      -WhatIf
  }
  else {
    $response = .\Invoke-GrowImage.ps1 `
      -Src $TempSrcItem.FullName `
      -Dest $TempDestItem.FullName `
      -GrowAmount $GrowAmount `
      -MaxWidth $Width `
      -MaxHeight $Height
  }
  $response
  $response.GrowPlan
  # Get-ImageInformation $TempSrc | Format-Table -Property Filename, Width, Height
  # Get-ImageInformation $TempDest | Format-Table -Property Filename, Width, Height
}

Copy-Item -Path $TempDest -Destination $Dest -Force
Remove-Item -Path $TempSrc -Force
Remove-Item -Path $TempDest -Force