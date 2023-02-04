[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$Path,
  [int]$Width = 1024,
  [int]$Height = 1024
)
begin {
  try {
    $item = Get-Item -Path $Path
  }
  catch {
    "File IO error!"
    exit
  }  
}
process {  
  # update canvas size with centered image
  # magick convert .\a.png -background none -gravity center -extent 2048x2048 new_a.png

  # crop images - centered -512x0
  # magick convert .\new_a.png -gravity center -crop 1024x1024-512+0 cropped_a.png

  # identify images
  # magick identify .\cropped_a.png
  # .\cropped_a.png PNG 1024x1024 3128x2048+540+512 8-bit sRGB 194509B 0.000u 0:00.000
  # (filename format dimension page-geometry ...)

  # write a text
  # magick convert .\cropped_a.png -gravity center -fill white -stroke black -font Arial -pointsize 72 -annotate -512+0 "Hello World" texted_cropped_a.png

  # paste an image
  # magick composite .\texted_cropped_a.png .\new_a.png -gravity center -geometry -512+0 -compose over compisted.png

  function Get-TempPath($item, $type) {
    return "$($OpenAI.cfg.TempPath)\$($item.BaseName)_$($type)_$((Get-Date).ToString("yyyyMMddhhmmssfff"))_$([Guid]::NewGuid())$($item.Extension)"
  }
  
  function position($posX, $posY) {
    if ($posX -ge 0) { $dimension += "+" }
    $dimension += $posX
    if ($posY -ge 0) { $dimension += "+" }
    $dimension += $posY

    return $dimension
  }

  function partial_outpaint($canvasPath, $posX, $posY) {
    $position = position $posX $posY

    # crop
    $cursorPath = Get-TempPath $item "cursor"
    & $OpenAI.cfg.MagickPath convert $canvasPath -gravity center -crop "1024x1024$position" $cursorPath

    # outpaint
    $outpaintPath = Get-TempPath $item "outpaint"
    $params = @{
      Path       = $outpaintPath
      SourcePath = $cursorPath
      Prompt     = 'extend'
    }
    New-OpenAIImageEdit @params  

    # paste to a canvas
    $newCanvasPath = Get-TempPath $item "canvas"
    & $OpenAI.cfg.MagickPath composite $outpaintPath $canvasPath -gravity center -geometry $position -compose over $newCanvasPath

    return $newCanvasPath
  }

  function topleft_grow($canvasPath) {
    $left = @(@{
      x = -1 * ($Width / 2)
      y = 0
    })   
    $top = @(@{
      x = 0
      y = -1 * ($Width / 2)
    })

    $i = 0
    
    if (($left[$i].x -eq $top[$i].x) -and ($left[$i].y -eq $top[$i].y)) {
      return @{
        left = $left
        top = $top
      }
    } else {
      $i = $i + 1
      $left[$i]
    }
  }

  # create a canvas
  $canvasPath = Get-TempPath $item "canvas"
  & $OpenAI.cfg.MagickPath convert $Path -background none -gravity center -extent "$($Width)x$($Height)" $canvasPath

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath -512 0

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath 512 0

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath -256 -512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath 256 -512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath -256 512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath 256 512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath -512 -512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath 512 -512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath -512 512

  # partial outpaint
  $canvasPath = partial_outpaint $canvasPath 512 512

  $canvasPath
}
end {      
}
