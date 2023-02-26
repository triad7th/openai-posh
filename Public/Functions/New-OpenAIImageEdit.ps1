function New-OpenAIImageEdit {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $Path,
    [Parameter(Mandatory)]
    [string]$SourcePath,
    [string]$MaskPath,
    [Parameter(Mandatory)]
    [string]$Prompt,
    [securestring]$Token = $OpenAI.cfg.OpenAIToken,
    [int]$RetryCount = 5
  )

  try {
    if (!(Test-Path -Path $Path)) {
      New-Item -Path $Path -ItemType File -Force -Verbose | Out-Null
    }      
    $Item = Get-Item -Path $Path -ErrorAction Stop
    $filename = (Get-Item -Path $Item).FullName      
  }
  catch {
    "File IO error!"
    return
  }  

  $uri = "https://api.openai.com/v1/images/edits"
  $response = $null
  $form = @{
    image           = Get-Item $SourcePath
    prompt          = $Prompt
    n               = 1
    size            = "1024x1024"
    response_format = "b64_json"  
  }
  if ($MaskPath) { $form.mask = Get-Item $MaskPath }
  
  try {
    while (!$response) {
      try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Authentication Bearer -Token $Token -Form $form -ContentType "multipart/form-data" -Verbose
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
  }
}