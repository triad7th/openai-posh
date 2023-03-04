function Invoke-GrowImage {
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
  
  try {
    $StartTime = Get-Date
    $SrcItem = Get-Item -Path $Src -ErrorAction Stop
    $SrcInfo = Get-ImageInformation -Path $SrcItem
    if (!$GrowAmount) { $GrowAmount = [Math]::Max($SrcInfo.Width, $SrcInfo.Height) * 0.1 }
    if (!$MaxWidth) { $MaxWidth = $SrcInfo.Width + $GrowAmount }
    if (!$MaxHeight) { $MaxHeight = $SrcInfo.Height + $GrowAmount }
  
    $IsGrowable = ($SrcInfo.Width -lt $MaxWidth) -or ($SrcInfo.Height -lt $MaxHeight)
    $IsDone = ($SrcInfo.Width -eq $MaxWidth) -and ($SrcInfo.Height -eq $MaxHeight)
    $IsTrimmable = ($SrcInfo.Width -gt $MaxWidth) -or ($SrcInfo.Height -gt $MaxHeight)
  
    if (!$IsDone) {
      if (!$Dest) { 
        $Dest = "$($SrcItem.Directory)\$($SrcItem.BaseName)_result_$([Guid]::NewGuid())$($SrcItem.Extension)"
      }
      $cmd = Get-ImageMagickCommand `
        -Type New `
        -SrcPath $Src `
        -DestPath $Dest `
        -Width ($SrcInfo.Width + $GrowAmount) `
        -Height ($SrcInfo.Height + $GrowAmount)
      Invoke-Expression -Command ($cmd | Out-String) | Out-Null
  
      $DestItem = Get-Item -Path $Dest
      $DestInfo = [PSCustomObject]@{
        GrowAmount = $GrowAmount
        MaxWidth   = $MaxWidth
        MaxHeight  = $MaxHeight
      }
    }    
  }
  catch {
    "File IO error!"
    return
  }
  
  if ($IsGrowable) {        
    $growPlan = Get-GrowImagePlan `
      -SrcInfo $SrcInfo.PSObject.Copy() `
      -GrowAmount $GrowAmount
    $index = 0
    foreach ($phase in ($growPlan.list.Phase | Select-Object -Unique)) {                
      $hsl = "hsl($(Get-Random -Minimum 1 -Maximum 360), 100%, 50%)"
      $phaseItems = $growPlan.list | Where-Object -Property Phase -eq $phase
      $jobs = @()
      $phaseIndex = $index
      foreach ($item in $phaseItems) {
        $index++
        Write-Progress -Activity "Grow Image" -PercentComplete (($index / $growPlan.List.Length) * 100)
        $item.filePath = 
        "$($OpenAI.Cfg.TempPath)\$($DestItem.BaseName)" +
        "_$(([Guid]::NewGuid()).Guid)" + 
        "_$($item.phase.ToString().PadLeft($growPlan.paddings.phase, '0'))" + 
        "_$(Get-ImageMagickPos $item.x $growPlan.paddings.x)" + 
        "_$(Get-ImageMagickPos $item.y $growPlan.paddings.y)" +
        "$($DestItem.Extension)"
        $cut = Get-ImageMagickCommand `
          -Type Cut `
          -SrcPath $Dest `
          -DestPath $item.filePath `
          -Width ($SrcInfo.Width + $GrowAmount) `
          -Height ($SrcInfo.Height + $GrowAmount) `
          -GrowAmount $GrowAmount `
          -GrowItem $item
        if ($WhatIf) {
          $fill = Get-ImageMagickCommand `
            -Type Fill `
            -SrcPath $item.filePath `
            -DestPath $item.filePath `
            -Width $GrowAmount `
            -Height $GrowAmount `
            -FillColor $hsl
          $paste = Get-ImageMagickCommand `
            -Type Paste `
            -SrcPath $DestItem.FullName `
            -DestPath $DestItem.FullName `
            -GrowPlan $item
          # Invoke-Expression -Command ($cut | Out-String)
          # Invoke-Expression -Command ($fill | Out-String)
          # Invoke-Expression -Command ($paste | Out-String)
          # Copy-Item `
          #   -Path $DestItem.FullName `
          #   -Destination "$($DestItem.Directory)\$($DestItem.BaseName)_$phase-$($item.name)-$($index - $phaseIndex)$($DestItem.Extension)"
          $jobs += Start-Job -ScriptBlock {
            Invoke-Expression -Command ($args[0] | Out-String) # cut
            Invoke-Expression -Command ($args[1] | Out-String) # cut
          } -ArgumentList $cut, $fill
        }
        else {
          $jobs += Start-Job -ScriptBlock {
            Invoke-Expression -Command ($args[0] | Out-String) # cut
            New-OpenAIImageEdit -Path $args[1] -SourcePath $args[1] -Prompt 'Extend image WITHOUT TEXT' # edit
          } -ArgumentList $cut, $item.filePath
        }
      }
      $jobs | Wait-Job | Out-Null
      # paste
      $paste = Get-ImageMagickCommand `
        -Type Paste `
        -SrcPath $DestItem.FullName `
        -DestPath $DestItem.FullName `
        -GrowPlan $phaseItems
      Invoke-Expression -Command ($paste | Out-String)
      if ($WhatIf) {
        Copy-Item `
          -Path $DestItem.FullName `
          -Destination "$($DestItem.Directory)\$($DestItem.BaseName)_$phase-$($item.name)-$($index - $phaseIndex)$($DestItem.Extension)"
      }
      $phaseItems.filePath | ForEach-Object { Remove-Item -Path $_ }
    }
  }
  # trim
  if ($IsTrimmable) {
    $cmd = Get-ImageMagickCommand `
      -Type Finalize `
      -SrcPath $DestItem.FullName `
      -DestPath $DestItem.FullName `
      -Width ([Math]::Min($SrcInfo.Width, $MaxWidth)) `
      -Height ([Math]::Min($SrcInfo.Height, $MaxHeight))
    Invoke-Expression -Command ($cmd | Out-String) | Out-Null
  }
  else {
    if (!$IsDone) {
      $cmd = Get-ImageMagickCommand `
        -Type Finalize `
        -SrcPath $DestItem.FullName `
        -DestPath $DestItem.FullName `
        -Width ($SrcInfo.Width + $GrowAmount) `
        -Height ($SrcInfo.Width + $GrowAmount)
      Invoke-Expression -Command ($cmd | Out-String) | Out-Null
    }
  }
  return [PSCustomObject]@{
    SourceItem      = $SrcItem
    SourceInfo      = $SrcInfo
    DestinationItem = $DestItem
    DestinationInfo = $DestInfo
    IsGrowable      = $IsGrowable
    IsDone          = $IsDone
    IsTrimmable     = $IsTrimmable
    GrowPlan        = $growPlan.List
    ElapsedTime     = (Get-Date) - $startTime
  }
}
