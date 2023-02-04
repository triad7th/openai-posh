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

  "rectangle $absX, $absY $($absX + $w), $($absY + $h)"

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

# $width  = 3096
# $height = 2048

# $lefts = @()
# $tops = @()
# $i = 0

# $left = @{ x = -1 * ($width / 2); y = -512 * $i }
# $top = @{ x = -512 * $i; y = -1 * ($height / 2) }
        
# $lefts += $left
# $tops += $top

# Write-HostTitle "lefts"
# $lefts

# Write-HostTitle "tops"
# $tops

$ow = 309.6
$oh = 204.8

$gw = $ow + 102.4
$gh = $oh + 102.4

canvas ($gw) ($gh) test
box $gw $gh (-$ow / 2) (-$oh / 2) 309.6 204.8 test

box $gw $gh (-154.8 - 51.2) -51.2 102.4 102.4 test
box $gw $gh -51.2 (-102.4 - 51.2) 102.4 102.4 test

box $gw $gh (-154.8 - 51.2) (-51.2 - 51.2) 102.4 102.4 test
box $gw $gh (-51.2 - 51.2) (-102.4 - 51.2) 102.4 102.4 test

box $gw $gh (-154.8 - 51.2) (-51.2 - 51.2 - 51.2) 102.4 102.4 test
#box $gw $gh (-51.2 - 51.2 - 51.2) (-102.4 - 51.2) 102.4 102.4 test

box $gw $gh (154.8 - 51.2) -51.2 102.4 102.4 test
box $gw $gh -51.2 (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (154.8 - 51.2) (-51.2 + 51.2) 102.4 102.4 test
box $gw $gh (-51.2 + 51.2) (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (154.8 - 51.2) (-51.2 + 51.2 + 51.2) 102.4 102.4 test
#box $gw $gh (-51.2 + 51.2 + 51.2) (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (-154.8 - 51.2) -51.2 102.4 102.4 test
box $gw $gh -51.2 (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (-154.8 - 51.2) (-51.2 + 51.2) 102.4 102.4 test
box $gw $gh (-51.2 - 51.2) (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (-154.8 - 51.2) (-51.2 + 51.2 + 51.2) 102.4 102.4 test
#box $gw $gh (-51.2 - 51.2 - 51.2) (102.4 - 51.2) 102.4 102.4 test

box $gw $gh (+154.8 - 51.2) -51.2 102.4 102.4 test
box $gw $gh -51.2 (-102.4 - 51.2) 102.4 102.4 test

box $gw $gh (+154.8 - 51.2) (-51.2 - 51.2) 102.4 102.4 test
box $gw $gh (-51.2 + 51.2) (-102.4 - 51.2) 102.4 102.4 test

box $gw $gh (+154.8 - 51.2) (-51.2 - 51.2 - 51.2) 102.4 102.4 test
#box $gw $gh (-51.2 + 51.2 + 51.2) (-102.4 - 51.2) 102.4 102.4 test