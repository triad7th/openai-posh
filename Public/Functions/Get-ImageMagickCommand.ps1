function Get-ImageMagickCommand {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateSet('FakeGrow', 'Grow', 'Finalize', 'Cut', 'Fill', 'New', 'Paste')]
    [string]$Type,
    [string]$SrcPath,
    [string]$DestPath,
    [decimal]$Width,
    [decimal]$Height,
    [decimal]$MaxWidth,
    [decimal]$MaxHeight,
    [decimal]$GrowAmount,
    [Array]$GrowPlan,
    [object]$GrowItem,
    [string]$FillColor
  )
  
  $cmd = @()
  switch ($Type)
  {
    FakeGrow {
      $size = "$($Width)x$($Height)"
      $centerX = $Width / 2
      $centerY = $Height / 2
  
      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      $hsl = "hsl($(Get-Random -Minimum 1 -Maximum 360), 100%, 50%)"
      foreach ($item in $GrowPlan) {
        $cmd += " -strokewidth 1 -fill '$hsl' -stroke '$hsl' ``"
    
        $left = $centerX + $item.x - $GrowAmount / 2
        $top = $centerY + $item.y - $GrowAmount / 2      
        $right = $left + $GrowAmount
        $bottom = $top + $GrowAmount
        
        $cmd += " -draw ""fill-opacity 0.1 rectangle $left, $top $right, $bottom"" ``"
      }
      $cmd += " $DestPath"
    }
    Grow {
      $cmd += "Hello Grow!"
    }
    New {
      $size = "$($Width)x$($Height)"
  
      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      $cmd += " $DestPath"
    }
    Paste {
      $cmd += "magick convert $SrcPath ``"
      foreach ($item in $GrowPlan) {
        $cmd += " -gravity center $($item.filePath) -geometry $(Get-ImageMagickPos $item.x)$(Get-ImageMagickPos $item.y) -composite ``"
      }
      $cmd += " $DestPath"
    }
    Finalize {
      $crop = "$($Width)x$($Height)+0+0"
  
      $cmd += "magick convert $SrcPath ``"
      $cmd += " -gravity center -crop $crop ``"
      $cmd += " $DestPath"
    }
    Cut {
      $size = "$($Width)x$($Height)"
      $crop = "$($GrowAmount)x$($GrowAmount)$(Get-ImageMagickPos $GrowItem.x)$(Get-ImageMagickPos $GrowItem.y)"
  
      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      $cmd += " -gravity center -crop $crop ``"
      $cmd += " $DestPath"
    }
    Fill {
      $size = "$($Width)x$($Height)"
  
      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      $cmd += " -strokewidth 2 -fill '$FillColor' -stroke '$FillColor' ``"      
      $cmd += " -draw ""fill-opacity 0.1 rectangle 0, 0 $($Width - 1), $($Height - 1)"" ``"
      $cmd += " $DestPath"
    }
  }
  
  return $cmd
}
