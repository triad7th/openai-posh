[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$Src,
  [string]$Dest,
  [decimal]$GrowAmount,
  [decimal]$MaxWidth,
  [decimal]$MaxHeight
)
begin {
  try {
    $SrcItem = Get-Item -Path $Src
    $SrcInfo = Get-ImageInformation -Path $SrcItem
    if (!$Dest) { 
      $Dest = "$($SrcItem.Directory)\$($SrcItem.BaseName)_result_$([Guid]::NewGuid())$($SrcItem.Extension)"
      New-Item -Path $Dest | Out-Null
    }
    $DestItem = Get-Item -Path $Dest
    if (!$GrowAmount) { $GrowAmount = [Math]::Max($SrcInfo.Width, $SrcInfo.Height) * 0.1 }
    if (!$MaxWidth) { $MaxWidth = $SrcInfo.Width + $GrowAmount }
    if (!$MaxHeight) { $MaxHeight = $SrcInfo.Height + $GrowAmount }
    $DestInfo = [PSCustomObject]@{
      GrowAmount = $GrowAmount
      MaxWidth = $MaxWidth
      MaxHeight = $MaxHeight
    }
  }
  catch {
    "File IO error!"
    exit
  }  
}
process {
  # make white background transparent
  # magick '.\Monster Truck-sis-20221221_234332_094 copy.png' -fuzz 2% -transparent white output3.png
  # $backgroundPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_bg_$([Guid]::NewGuid())$($item.Extension)"

  #magick -size 1024x1024 canvas:white -transparent white abc_background.png
  # & $OpenAI.cfg.MagickPath -size 1024x1024 canvas:red -transparent red $backgroundPath  
  $SrcInfo
  $DestInfo
  
  Write-OutputTitle "Source"
  $SrcItem
  Write-OutputTitle "Destination"
  $DestItem

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

  function mock() {
    $size = "$($MaxWidth + 1)x$($MaxHeight + 1)"
    $centerX = $MaxWidth / 2
    $centerY = $MaxHeight / 2
        
    $cmd = @()
    $cmd += "magick convert ``"
    $cmd += " -size $size xc:none ``"    
    foreach ($item in $touchResult.List) {
      $hsl = "hsl($(Get-Random -Minimum 1 -Maximum 360), 100%, 50%)"  
      $cmd += " -strokewidth 1 -fill none -stroke '$hsl' ``"

      $left = $centerX + $item.x - $GrowAmount / 2
      $top = $centerY + $item.y - $GrowAmount / 2      
      $right = $left + $GrowAmount
      $bottom = $top + $GrowAmount
      
      $cmd += " -draw ""rectangle $left, $top $right, $bottom"" ``"      
    }
    $cmd += " $($DestItem.FullName)"
    return $cmd
  }

  $g = $DestInfo.GrowAmount
  for ($i = 0; $touchResult.blocks -lt 8; $i++) {
    $touchResult.blocks = 0
    touch (+$SrcInfo.Width/2) ((+$g/2) * $i) $g $i
    touch (+$SrcInfo.Width/2) ((-$g/2) * $i) $g $i
    touch (-$SrcInfo.Width/2) ((+$g/2) * $i) $g $i
    touch (-$SrcInfo.Width/2) ((-$g/2) * $i) $g $i
    touch ((+$g/2) * $i) (+$SrcInfo.Height/2) $g $i
    touch ((-$g/2) * $i) (+$SrcInfo.Height/2) $g $i
    touch ((+$g/2) * $i) (-$SrcInfo.Height/2) $g $i
    touch ((-$g/2) * $i) (-$SrcInfo.Height/2) $g $i
    #Write-Host "blocks: $($touchResult.blocks)" 
  }

  touch (+$SrcInfo.Width/2) (+$SrcInfo.Height/2) $g $i
  touch (+$SrcInfo.Width/2) (-$SrcInfo.Height/2) $g $i
  touch (-$SrcInfo.Width/2) (+$SrcInfo.Height/2) $g $i
  touch (-$SrcInfo.Width/2) (-$SrcInfo.Height/2) $g $i

  $touchResult.List | ft
  Invoke-Expression -Command (mock | Out-String)
}
end {      
}
