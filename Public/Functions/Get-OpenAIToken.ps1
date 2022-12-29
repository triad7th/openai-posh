function Get-OpenAIToken {
  [CmdletBinding()]
  param (
  )
  begin {
    # $token = Get-Content -Path ../api.token | ConvertTo-SecureString -AsPlainText -Force
  }
  process {
    (Get-Credential -UserName 'OpenAI' -Message 'Type OpenAI Token').Password
  }
  end {      
  }
}