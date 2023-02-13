[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$Src,
  [string]$Dest,
  [decimal]$GrowAmount,
  [decimal]$MaxWidth,
  [decimal]$MaxHeight,
  [switch]$WhatIf
)
begin {
  try {
    $SrcItem = Get-Item -Path $Src
    $SrcInfo = Get-ImageInformation -Path $SrcItem
    if (!$GrowAmount) { $GrowAmount = [Math]::Max($SrcInfo.Width, $SrcInfo.Height) * 0.1 }
    if (!$MaxWidth) { $MaxWidth = $SrcInfo.Width + $GrowAmount }
    if (!$MaxHeight) { $MaxHeight = $SrcInfo.Height + $GrowAmount }

    $IsGrowable = ($SrcInfo.Width -lt $MaxWidth) -or ($SrcInfo.Height -lt $MaxHeight)
    if ($IsGrowable) {
      if (!$Dest) { 
        $Dest = "$($SrcItem.Directory)\$($SrcItem.BaseName)_result_$([Guid]::NewGuid())$($SrcItem.Extension)"
        New-Item -Path $Dest | Out-Null
      }
      $DestItem = Get-Item -Path $Dest
      $DestInfo = [PSCustomObject]@{
        GrowAmount = $GrowAmount
        MaxWidth = $MaxWidth
        MaxHeight = $MaxHeight
      }
    }
  }
  catch {
    "File IO error!"
    exit
  }  
}
process {
  $touchResult = [PSCustomObject]@{
    blocks = 0
    list = @()
  }

  function touch([float]$x, [float]$y, [int]$phase) {
    if (($x -lt -$SrcInfo.Width/2) -or ($x -gt $SrcInfo.Width/2)) { $touchResult.blocks++; return }
    if (($y -lt -$SrcInfo.Height/2) -or ($y -gt $SrcInfo.Height/2)) { $touchResult.blocks++; return }
  
    if ($touchResult.list | Where-Object x -eq $x | Where-Object y -eq $y) { $touchResult.blocks++; return }
  
    $touchResult.list = @($touchResult.list) + ([PSCustomObject]@{phase = $phase;x = $x; y = $y})
  }

  if ($IsGrowable) {
    $g = $DestInfo.GrowAmount
    for ($i = 0; $touchResult.blocks -lt 8; $i++) {
      $touchResult.blocks = 0
      touch (+$SrcInfo.Width/2) ((+$g/2) * $i)$i
      touch (+$SrcInfo.Width/2) ((-$g/2) * $i) $i
      touch (-$SrcInfo.Width/2) ((+$g/2) * $i) $i
      touch (-$SrcInfo.Width/2) ((-$g/2) * $i) $i
      touch ((+$g/2) * $i) (+$SrcInfo.Height/2) $i
      touch ((-$g/2) * $i) (+$SrcInfo.Height/2) $i
      touch ((+$g/2) * $i) (-$SrcInfo.Height/2) $i
      touch ((-$g/2) * $i) (-$SrcInfo.Height/2) $i
      #Write-Host "blocks: $($touchResult.blocks)" 
    }
  
    touch (+$SrcInfo.Width/2) (+$SrcInfo.Height/2) $i
    touch (+$SrcInfo.Width/2) (-$SrcInfo.Height/2) $i
    touch (-$SrcInfo.Width/2) (+$SrcInfo.Height/2) $i
    touch (-$SrcInfo.Width/2) (-$SrcInfo.Height/2) $i
     
    if (!$WhatIf) {
      $cmd = .\Get-ImageMagickCommand.ps1 `
        -Type FakeGrow `
        -SrcPath $SrcItem.FullName `
        -DestPath $DestItem.FullName `
        -Width ($SrcInfo.Width + $GrowAmount) `
        -Height ($SrcInfo.Height + $GrowAmount) `
        -GrowAmount $GrowAmount `
        -GrowPlan $touchResult.List

      Invoke-Expression -Command ($cmd | Out-String) | Out-Null
    }
  }  

  return [PSCustomObject]@{
    SourceItem = $SrcItem
    SourceInfo = $SrcInfo
    DestinationItem = $DestItem
    DestinationInfo = $DestInfo
    IsGrowable = ($SrcInfo.Width -lt $DestInfo.MaxWidth) -or ($SrcInfo.Height -lt $DestInfo.MaxHeight)
    GrowPlan = $touchResult.List
  }
}
end {      
}
