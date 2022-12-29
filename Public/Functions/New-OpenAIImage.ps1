function New-OpenAIImage {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$Prompt,
    [Parameter(Mandatory)]
    [securestring]$Token,
    [int]$RetryCount = 5        
  )
  begin {
    try {
      New-Item -Path $Path -ItemType File -Force -Verbose | Out-Null
      $filename = (Get-Item -Path $Path).FullName
      Remove-Item -Path $Path -Force -Verbose
    }
    catch {
      "File IO error!"
      exit
    }  
    $uri = "https://api.openai.com/v1/images/generations"
    # $token = Get-Content -Path ../api.token | ConvertTo-SecureString -AsPlainText -Force
  }
  process {  
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
    }
  }
  end {
      
  }
}