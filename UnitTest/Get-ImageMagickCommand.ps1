[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [ValidateSet('FakeGrow', 'Grow', 'Finalize', 'Cut')]
  [string]$Type,
  [string]$SrcPath,
  [string]$DestPath,
  [decimal]$Width,
  [decimal]$Height,
  [decimal]$MaxWidth,
  [decimal]$MaxHeight,
  [decimal]$GrowAmount,
  [Array]$GrowPlan,
  [object]$GrowItem  
)
begin {
  try {
  }
  catch {
    "File IO error!"
    exit
  }  
}
process {
  function pos([decimal] $v) {
    if ($v -ge 0) { return "+$v" }
      else { return "$v" }
  }

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
    Finalize {
      $crop = "$($Width)x$($Height)+0+0"

      $cmd += "magick convert $SrcPath ``"
      $cmd += " -gravity center -crop $crop ``"
      $cmd += " $DestPath"
    }
    Cut {
      $size = "$($Width)x$($Height)"
      $crop = "$($GrowAmount)x$($GrowAmount)$(pos $GrowItem.x)$(pos $GrowItem.y)"

      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      $cmd += " -gravity center -crop $crop ``"
      $cmd += " $DestPath"
    }
  }
  return $cmd
}
end {      
}
