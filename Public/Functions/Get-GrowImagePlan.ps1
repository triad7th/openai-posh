function Get-GrowImagePlan {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [object]$SrcInfo,
    [decimal]$GrowAmount = 1024
  )
  
  $plan = [PSCustomObject]@{
    block    = 0
    phase    = 0
    list     = @()
    paddings = @{}
  }
  function intersectPt($p1, $p2) {
    $d = $GrowAmount / 2
    if ($p2.x -lt $p1.x - $d) { return $false }
    if ($p2.x -gt $p1.x + $d) { return $false }
    if ($p2.y -lt $p1.y - $d) { return $false }
    if ($p2.y -gt $p1.y + $d) { return $false }
    return $true
  }
  function intersectRect($p1, $p2) {
    if (intersectPt $p1 @{x = $p2.x - $d; y = $p2.y }) { return $true }
    if (intersectPt $p1 @{x = $p2.x + $d; y = $p2.y }) { return $true }
    if (intersectPt $p1 @{x = $p2.x; y = $p2.y - $d }) { return $true }
    if (intersectPt $p1 @{x = $p2.x; y = $p2.y + $d }) { return $true }
    return $false
  }
  function step([float]$x, [float]$y, [string]$name, [float]$w = $SrcInfo.Width, [float]$h = $SrcInfo.Height) {
    if (($x -lt - $w / 2) -or ($x -gt $w / 2)) { $plan.block++; return }
    if (($y -lt - $h / 2) -or ($y -gt $h / 2)) { $plan.block++; return }  
    if ($plan.list | Where-Object x -eq $x | Where-Object y -eq $y) { $plan.block++; return }
    $plan.list = @($plan.list) + ([PSCustomObject]@{phase = $plan.phase; name = $name; x = $x; y = $y; filePath = $null })
  }
  
  # pre phase (centered)
  if (($SrcInfo.Width -lt $GrowAmount) -or ($SrcInfo.Height -lt $GrowAmount)) { 
    step 0 0 pre ([Math]::Max($SrcInfo.Width, $GrowAmount)) ([Math]::Max($SrcInfo.Height, $GrowAmount))
    $plan.phase++
  }
  # head phase (cross shape)
  step (+$SrcInfo.Width / 2) 0 head
  step (-$SrcInfo.Width / 2) 0 head
  step 0 (+$SrcInfo.Height / 2) head
  step 0 (-$SrcInfo.Height / 2) head
  $plan.phase++
  # body phase (expand from the head pahse)
  for ($body = 1; $plan.block -lt 8; $body++) {
    $plan.block = 0
    step (+$SrcInfo.Width / 2) ((+$GrowAmount / 2) * $body) body
    step (+$SrcInfo.Width / 2) ((-$GrowAmount / 2) * $body) body
    step (-$SrcInfo.Width / 2) ((+$GrowAmount / 2) * $body) body
    step (-$SrcInfo.Width / 2) ((-$GrowAmount / 2) * $body) body
    if (($plan.block -lt 4) -and ((((+$GrowAmount / 2) * $body) + (+$GrowAmount / 2)) -gt ($SrcInfo.Width / 2))) { $plan.phase++ }
    step ((+$GrowAmount / 2) * $body) (+$SrcInfo.Height / 2) body
    step ((-$GrowAmount / 2) * $body) (+$SrcInfo.Height / 2) body
    step ((+$GrowAmount / 2) * $body) (-$SrcInfo.Height / 2) body
    step ((-$GrowAmount / 2) * $body) (-$SrcInfo.Height / 2) body
    if ($plan.block -lt 8) { $plan.phase++ }
  }
  # tail phase (corner shape)
  step (+$SrcInfo.Width / 2) (+$SrcInfo.Height / 2) tail
  step (+$SrcInfo.Width / 2) (-$SrcInfo.Height / 2) tail
  step (-$SrcInfo.Width / 2) (+$SrcInfo.Height / 2) tail
  step (-$SrcInfo.Width / 2) (-$SrcInfo.Height / 2) tail
  
  $plan.paddings = @{
    phase = ($plan.list.phase | Sort-Object -Descending | Select-Object -First 1).ToString().Length
    x     = [int]($plan.list.x | Select-Object @{Name = 'v'; Expression = { ($_.ToString() -replace '-', '').Length + 1 } } | Sort-Object -Property v -Descending | Select-Object -First 1).v
    y     = [int]($plan.list.y | Select-Object @{Name = 'v'; Expression = { ($_.ToString() -replace '-', '').Length + 1 } } | Sort-Object -Property v -Descending | Select-Object -First 1).v
  }
  return $plan
}