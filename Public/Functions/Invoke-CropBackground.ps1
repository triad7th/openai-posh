function Invoke-CropBackground {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Path
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
    # make white background transparent
    # magick '.\Monster Truck-sis-20221221_234332_094 copy.png' -fuzz 2% -transparent white output3.png
    # magick .\iphone-dad-20230110_203700_783.png -fuzz 10% -fill none -floodfill +0+0 white result.png
    $tempPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_$([Guid]::NewGuid())$($item.Extension)"
    # & $OpenAI.cfg.MagickPath $Path -fuzz 4% -transparent white $tempPath | Out-Null
    & $OpenAI.cfg.MagickPath $Path -fuzz 10% -fill none -floodfill +0+0 white $tempPath | Out-Null
    return Get-Item -Path $tempPath
  }
  end {      
  }
}