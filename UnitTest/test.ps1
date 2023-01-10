[CmdletBinding()]
param (            
  [string]$Subject,
  [securestring]$Token
)

$fam = @(
  @{ name = "dad"; prompt = "A high-quality illustration of an anthropomorphic Daddy $Subject with mustache and thick glasses. Kids friendly cartoon style digital art. White background. No shadow." }
  @{ name = "mom"; prompt = "A high-quality illustration of an anthropomorphic Mommy $Subject with earrings and thick lips. Kids friendly cartoon style digital art. White background. No shadow." },
  @{ name = "bro"; prompt = "A high-quality illustration of an anthropomorphic Brother $Subject with baseball hat and silly smile. Kids friendly cartoon style digital art. White background. No shadow." },
  @{ name = "sis"; prompt = "A high-quality illustration of an anthropomorphic Sister $Subject with lady hat, earrings, pretty face and nice smile. Kids friendly cartoon style digital art. White background. No shadow." },
  @{ name = "beb"; prompt = "A high-quality illustration of an anthropomorphic Baby $Subject with pacifier on his mouth, Kids friendly cartoon style digital art. White background. No shadow." }  
  # @{ name = "bg"; prompt = "A high-quality background photo themed as '$Subject'. A realistic style. Sharp focus, Extremely detailed." }
)

$timestamp = Get-Timestamp

foreach ($mem in $fam) {
  $path = "./images/$Subject-$($mem.name)-$timestamp.png"
  Write-OutputTitle -String $path
  New-OpenAIImage -Path $path -Prompt $mem.prompt -ImproveBorders -WhiteBackgroundTransparent
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