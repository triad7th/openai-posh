function New-OpenAIImage {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $Path,
    [Parameter(Mandatory)]
    [string]$Prompt,
    [securestring]$Token = $OpenAI.cfg.OpenAIToken,
    [int]$RetryCount = 5,
    [switch]$ImproveBorders,
    [switch]$WhiteBackgroundTransparent    
  )

  try {      
    New-Item -Path $Path -ItemType File -Force -Verbose | Out-Null
    $Item = Get-Item -Path $Path -ErrorAction Stop
    $filename = (Get-Item -Path $Item).FullName
    Remove-Item -Path $Item -Force -Verbose
  }
  catch {
    "File IO error!"
    return
  }
  
  $uri = "https://api.openai.com/v1/images/generations"
  $response = $null
  $body = @{
    prompt          = $Prompt
    n               = 1
    size            = "1024x1024"
    response_format = "b64_json"
  } | ConvertTo-Json
      
  try {
    while (!$response) {
      try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Authentication Bearer -Token $Token -Body $body -ContentType "application/json" -Verbose
      }
      catch {
        $RetryCount--
        if ($_.ToString() -ne 'No such host is known.') { throw }        
        if ($RetryCount -le 0) { throw }
        "API call limit reached. Wait 5 seconds and retry... ($RetryCount attempts left)"
        Start-Sleep -Seconds 5 -Verbose
      }
    }
    $bytes = [Convert]::FromBase64String($response.data.b64_json)
    [IO.File]::WriteAllBytes($filename, $bytes)
  }
  catch {
    "Something wrong!"
    $_
    return
  }

  if ($ImproveBorders) {
    $tempPath = Invoke-ShrinkImage -Path $Item
    if (Test-Path -Path $tempPath) {
      $improvedBordersPath = "$($OpenAI.cfg.TempPath)\$($Item.BaseName)_improved-borders_$([Guid]::NewGuid())$($Item.Extension)"
      $params = @{
        Path       = $improvedBordersPath
        SourcePath = $tempPath.FullName
        Prompt     = 'just extend the source image. no background. no added stuff.'
      }
      New-OpenAIImageEdit @params
      Remove-Item -Path $tempPath -Verbose
      if (Test-Path -Path $improvedBordersPath) {
        Copy-Item -Path $improvedBordersPath -Destination $Item -Force -Verbose
        Remove-Item -Path $improvedBordersPath -Verbose
      }
    }      
  }

  if ($WhiteBackgroundTransparent) {
    $tempPath = Invoke-CropBackground -Path $Item
    if (Test-Path -Path $tempPath) {
      Copy-Item -Path $tempPath -Destination $Item -Force -Verbose
      Remove-Item -Path $tempPath -Verbose
    }
  }
}