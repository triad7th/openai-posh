function Get-OpenAIToken {
  [CmdletBinding()]
  param (
  )
  begin {
    # $token = Get-Content -Path ../api.token | ConvertTo-SecureString -AsPlainText -Force
  }
  process {
    $OpenAI.Cfg.OpenAIToken = (Get-Credential -UserName 'OpenAI' -Message 'Type OpenAI Token').Password
  }
  end {
  }
}