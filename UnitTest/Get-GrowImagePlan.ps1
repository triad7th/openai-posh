[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [object]$SrcInfo,
  [decimal]$GrowAmount = 1024
)

$GoHeadPhase = $false
$GoBodyPhase = $true
$GoTailPhase = $true
# override width/height if they are too small
#if (($SrcInfo.Width -lt $GrowAmount) -and ($SrcInfo.Height -lt $GrowAmount)) { $GoBodyPhase = $false; $GoTailPhase = $false }
if ($SrcInfo.Width -lt $GrowAmount) { $SrcInfo.Width = $GrowAmount; $GoHeadPhase = $true }
if ($SrcInfo.Height -lt $GrowAmount) { $SrcInfo.Height = $GrowAmount; $GoHeadPhase = $true }

$plan = [PSCustomObject]@{
  blocks   = 0
  list     = @()
  paddings = @{}
}

function step([float]$x, [float]$y, [int]$phase) {
  if (($x -lt - $SrcInfo.Width / 2) -or ($x -gt $SrcInfo.Width / 2)) { $plan.blocks++; return }
  if (($y -lt - $SrcInfo.Height / 2) -or ($y -gt $SrcInfo.Height / 2)) { $plan.blocks++; return }  
  if ($plan.list | Where-Object x -eq $x | Where-Object y -eq $y) { $plan.blocks++; return }  
  $plan.list = @($plan.list) + ([PSCustomObject]@{phase = $phase; x = $x; y = $y; filePath = $null })
}

# head phase
if ($GoHeadPhase) { step 0 0 0 }
# body phase
if ($GoBodyPhase) {
  for ($phase = 1; $plan.blocks -lt 8; $phase++) {
    $plan.blocks = 0
    step (+$SrcInfo.Width / 2) ((+$GrowAmount / 2) * $phase) $phase
    step (+$SrcInfo.Width / 2) ((-$GrowAmount / 2) * $phase) $phase
    step (-$SrcInfo.Width / 2) ((+$GrowAmount / 2) * $phase) $phase
    step (-$SrcInfo.Width / 2) ((-$GrowAmount / 2) * $phase) $phase
    step ((+$GrowAmount / 2) * $phase) (+$SrcInfo.Height / 2) $phase
    step ((-$GrowAmount / 2) * $phase) (+$SrcInfo.Height / 2) $phase
    step ((+$GrowAmount / 2) * $phase) (-$SrcInfo.Height / 2) $phase
    step ((-$GrowAmount / 2) * $phase) (-$SrcInfo.Height / 2) $phase
  }
}
# tail phase
if ($GoTailPhase) {
  step (+$SrcInfo.Width / 2) (+$SrcInfo.Height / 2) $phase
  step (+$SrcInfo.Width / 2) (-$SrcInfo.Height / 2) $phase
  step (-$SrcInfo.Width / 2) (+$SrcInfo.Height / 2) $phase
  step (-$SrcInfo.Width / 2) (-$SrcInfo.Height / 2) $phase
}

$plan.paddings = @{
  phase = ($plan.list.phase | Sort-Object -Descending | Select-Object -First 1).ToString().Length
  x     = [int]($plan.list.x | Select-Object @{Name = 'v'; Expression = { ($_.ToString() -replace '-', '').Length + 1 } } | Sort-Object -Property v -Descending | Select-Object -First 1).v
  y     = [int]($plan.list.y | Select-Object @{Name = 'v'; Expression = { ($_.ToString() -replace '-', '').Length + 1 } } | Sort-Object -Property v -Descending | Select-Object -First 1).v
}
return $plan