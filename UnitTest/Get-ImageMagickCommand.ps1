[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [ValidateSet('FakeGrow', 'Grow')]
  [string]$Type,
  [string]$SrcPath,
  [string]$DestPath,
  [decimal]$Width,
  [decimal]$Height,
  [decimal]$MaxWidth,
  [decimal]$MaxHeight,
  [decimal]$GrowAmount,
  [Array]$GrowPlan
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
  $size = "$($Width)x$($Height)"
  $centerX = $Width / 2
  $centerY = $Height / 2
      
  $cmd = @()

  switch ($Type)
  {
    FakeGrow {
      $cmd += "magick convert ``"
      $cmd += " -size $size xc:none ``"    
      $cmd += " -gravity center $SrcPath -composite ``"
      foreach ($item in $GrowPlan) {
        $hsl = "hsl($(Get-Random -Minimum 1 -Maximum 360), 100%, 50%)"  
        $cmd += " -strokewidth 1 -fill none -stroke '$hsl' ``"
    
        $left = $centerX + $item.x - $GrowAmount / 2
        $top = $centerY + $item.y - $GrowAmount / 2      
        $right = $left + $GrowAmount
        $bottom = $top + $GrowAmount
        
        $cmd += " -draw ""rectangle $left, $top $right, $bottom"" ``"
      }
      $cmd += " $DestPath"
    } 
    Grow {
      $cmd += "Hello Grow!"
    }
  }
  return $cmd
}
end {      
}
