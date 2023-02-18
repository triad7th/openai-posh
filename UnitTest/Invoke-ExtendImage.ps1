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
begin {
  try {
    $SrcItem = Get-Item -Path $Src
    $TempSrc = "$($SrcItem.Directory)\$($SrcItem.BaseName)_temp_$([Guid]::NewGuid())$($SrcItem.Extension)"
    $TempDest = "$($SrcItem.Directory)\$($SrcItem.BaseName)_temp_$([Guid]::NewGuid())$($SrcItem.Extension)"
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
    exit
  }  
}
process {
  function progress()
  {
    $TempSrcInfo = Get-ImageInformation -Path $TempSrc
    $CurrentScore = $TempSrcInfo.Width + $TempSrcInfo.Height

    $percentage = [Math]::Max([Math]::Min(($CurrentScore - $BeginScore) / ($TargetScore - $BeginScore), 1) * 100 ,1)
    Write-Progress -Activity "Expanding Image" `
      -Status "$($TempSrcInfo.Width)x$($TempSrcInfo.Height)" `
      -PercentComplete $percentage
  }
  do {
    Copy-Item -Path $TempDest -Destination $TempSrc -Force
    progress  

    $response = .\Invoke-GrowImage.ps1 `
    -Src $TempSrcItem.FullName `
    -Dest $TempDestItem.FullName `
    -GrowAmount $GrowAmount `
    -MaxWidth $Width `
    -MaxHeight $Height
  } while ($response.IsDone -ne $true)  

  Copy-Item -Path $TempDest -Destination $Dest -Force
  Remove-Item -Path $TempSrc -Force
  Remove-Item -Path $TempDest -Force
}
end {      
}
