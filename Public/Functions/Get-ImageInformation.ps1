function Get-ImageInformation {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )

  try {
    $Src = Get-Item -Path $Path -ErrorAction Stop
  }
  catch {
    Write-Host "File IO error!"
    return
  } 

  $response = & $OpenAI.cfg.MagickPath identify $Src.FullName
  if ($response) {
    $response = $response.split(' ')
    $response[3] -match '([\d\.]+)x([\d\.]+)([+-][\d\.]+)([+-][\d\.]+)' | Out-Null
    return [PSCustomObject]@{
      Filename    = $response[0]
      ImageFormat = $response[1]
      Width       = [decimal]$response[2].split('x')[0]
      Height      = [decimal]$response[2].split('x')[1]
      PageWidth   = [decimal]$matches[1]
      PageHeight  = [decimal]$matches[2]
      XOffset     = [decimal]$matches[3]
      YOffset     = [decimal]$matches[4]
      Depth       = $response[4]
      Colorspace  = $response[5]
      FileSize    = $response[6]
      UserTime    = $response[7]
      ElapsedTime = $response[8]
    }
  }
  else {
    return [PSCustomObject]@{
      Filename = "No Image Found!"
    }  
  }
}
