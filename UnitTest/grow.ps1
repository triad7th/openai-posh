function sign($i) {
  if ($i -ge 0) { return "+$i" } else { return "$i" }
}
function point_centered($cw, $ch, $x = 0, $y = 0) {
  return "point $($cw / 2 + $x), $($ch / 2 + $y)"
}
function circle_centered($cw, $ch, $r = 5, $x = 0, $y = 0) {
  return "circle $($cw / 2 + $x), $($ch / 2 + $y) $($cw / 2 + $x + $r), $($ch / 2 + $y + $r)"
}
function canvas($cw, $ch, $name) {
  $canvasSize = "$($cw)x$($ch)"
  $path = "$($name).png"

  magick convert -size $canvasSize xc:none `
    -strokewidth 1 -fill red -stroke red `
    -draw (circle_centered $cw $ch 2) `
    $path
}

function box([float]$cw, [float]$ch, [float]$x, [float]$y, [float]$w, [float]$h, $name) {
  $canvasSize = "$($cw + 1)x$($ch + 1)"
  $canvasCenterX = $cw / 2
  $canvasCenterY = $ch / 2
  
  $absX = $canvasCenterX + $x
  $absY = $canvasCenterY + $y

  $hsl = "hsl($(Get-Random -Minimum 1 -Maximum 360), 100%, 50%)" 
  $box = "$($w)x$($h)$(sign($x))$(sign($y))"

  $path = "$($name).png"
  if (!(Test-Path -Path $path)) { magick convert -size $canvasSize xc:none $path }
  $item = Get-Item -Path $path  
  $originalPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_$([Guid]::NewGuid())$($item.Extension)"  
  $newPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_$([Guid]::NewGuid())$($item.Extension)"

  # "rectangle $absX, $absY $($absX + $w), $($absY + $h)"
  Copy-Item -Path $item -Destination $originalPath -Force
  magick convert `
    -size $canvasSize xc:none `
    -strokewidth 1 -fill none -stroke $hsl `
    -draw "rectangle $absX, $absY $($absX + $w), $($absY + $h)" `
    $newPath
    #-strokewidth 1 -fill $hsl -stroke $hsl -pointsize 36 -gravity center `
    #-draw "text $($x + $w / 2), $($y + $h / 2) '$box'" `
  magick composite $originalPath $newPath $item.FullName

  Remove-Item -Path $originalPath -Force
  Remove-Item -Path $newPath -Force
}

# begin
$ow = [float]648.6
$oh = [float]35.8
$l = [float]102.4
$gw = $ow + $l
$gh = $oh + $l
$name = "test"

canvas ($gw) ($gh) $name
box $gw $gh (-$ow / 2) (-$oh / 2) $ow $oh $name

$vault = [PSCustomObject]@{
  blocks = 0
  list = @()
}

function square([float]$x, [float]$y, [float]$l) {
  if (($x -lt -$ow/2) -or ($x -gt $ow/2)) { $vault.blocks++; return }
  if (($y -lt -$oh/2) -or ($y -gt $oh/2)) { $vault.blocks++; return }

  if ($vault.list | Where-Object x -eq $x | Where-Object y -eq $y) { $vault.blocks++; return }

  #box $gw $gh ($x - $l/2) ($y - $l/2) $l $l $name
  $vault.list = @($vault.list) + ([PSCustomObject]@{x = $x; y = $y})
}

for ($i = 0; $vault.blocks -lt 8; $i++) {
  $vault.blocks = 0
  square (+$ow/2) ((+$l/2) * $i) $l
  square (+$ow/2) ((-$l/2) * $i) $l
  square (-$ow/2) ((+$l/2) * $i) $l
  square (-$ow/2) ((-$l/2) * $i) $l
  square ((+$l/2) * $i) (+$oh/2) $l
  square ((-$l/2) * $i) (+$oh/2) $l
  square ((+$l/2) * $i) (-$oh/2) $l
  square ((-$l/2) * $i) (-$oh/2) $l
  Write-Host "blocks: $($vault.blocks)"    
}

square (+$ow/2) (+$oh/2) $l
square (+$ow/2) (-$oh/2) $l
square (-$ow/2) (+$oh/2) $l
square (-$ow/2) (-$oh/2) $l

$vault.list