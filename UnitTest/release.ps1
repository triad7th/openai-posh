[CmdletBinding()]
param (            
  [string]$Subject,
  [string]$timestamp = "*"
)

$scenePath = "C:\repos\alan\alan\sets\ff-alex\scene"
$fam = @(
  @{ name = "dad"; path = "$scenePath\hand\family\dad\dad.png" },
  @{ name = "mom"; path = "$scenePath\hand\family\mom\mom.png" },
  @{ name = "bro"; path = "$scenePath\hand\family\bro\bro.png" },
  @{ name = "sis"; path = "$scenePath\hand\family\sis\sis.png" },
  @{ name = "beb"; path = "$scenePath\hand\family\beb\beb.png" },
  @{ name = "bg"; path = "$scenePath\set.png" }
)

foreach ($mem in $fam) {
  $src = Get-ChildItem -Path "./images/$Subject-$($mem.name)-$Timestamp.png" | Sort-Object -Property Name | Select-Object -First 1
  Copy-Item -Path $src.FullName -Destination $mem.path -Force -Verbose
}

# New-OpenAIImage
#   -Path './b-image-edited.png' `
#   -SourcePath './b-image-original.png' `
#   -MaskPath './b-image-mask.png' `
#   -Prompt 'just extend the source image. no background. no added stuff.' `
#   -Token $Token
  

# make white background transparent
# magick '.\Monster Truck-sis-20221221_234332_094 copy.png' -fuzz 2% -transparent white output3.png

# image clipping solution
# https://imgur.com/a/BPHyHeT

# idea - upscale image from the clipping solution above.