function Invoke-ShrinkImage {
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
    $backgroundPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_bg_$([Guid]::NewGuid())$($item.Extension)"
    $scaledPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_scaled_$([Guid]::NewGuid())$($item.Extension)"
    $resultPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_result_$([Guid]::NewGuid())$($item.Extension)"

    #magick -size 1024x1024 canvas:white -transparent white abc_background.png
    & $OpenAI.cfg.MagickPath -size 1024x1024 canvas:red -transparent red $backgroundPath
    & $OpenAI.cfg.MagickPath $Path -scale 70%x70% $scaledPath
    & $OpenAI.cfg.MagickPath composite -gravity center $scaledPath $backgroundPath $resultPath

    Remove-Item $backgroundPath -Verbose -Force
    Remove-Item $scaledPath -Verbose -Force

    return Get-Item -Path $resultPath
  }
  end {      
  }
}