function Get-ImageInformation {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )
  begin {
    try {
      $Src = Get-Item -Path $Path    
    }
    catch {
      "File IO error!"
      exit
    }  
  }
  process {
    # make white background transparent
    # magick '.\Monster Truck-sis-20221221_234332_094 copy.png' -fuzz 2% -transparent white output3.png
    # $backgroundPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_bg_$([Guid]::NewGuid())$($item.Extension)"
  
    #magick -size 1024x1024 canvas:white -transparent white abc_background.png
    $response = (& $OpenAI.cfg.MagickPath identify $Src.FullName).split(' ')
    $response[3] -match '([\d\.]+)x([\d\.]+)([+-][\d\.]+)([+-][\d\.]+)' | Out-Null
    return [PSCustomObject]@{
      Filename = $response[0]
      ImageFormat = $response[1]
      Width = [decimal]$response[2].split('x')[0]
      Height = [decimal]$response[2].split('x')[1]
      PageWidth = [decimal]$matches[1]
      PageHeight = [decimal]$matches[2]
      XOffset = [decimal]$matches[3]
      YOffset = [decimal]$matches[4]
      Depth = $response[4]
      Colorspace = $response[5]
      FileSize = $response[6]
      UserTime = $response[7]
      ElapsedTime = $response[8]
    }
  }
  end {      
  }  
}
