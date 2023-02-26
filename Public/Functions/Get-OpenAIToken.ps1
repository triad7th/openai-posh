function Get-OpenAIToken {
  [CmdletBinding()]
  param (
  )

  $OpenAI.Cfg.OpenAIToken = (Get-Credential -UserName 'OpenAI' -Message 'Type OpenAI Token').Password
}