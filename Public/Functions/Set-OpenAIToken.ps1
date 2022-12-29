function Set-OpenAIToken {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeLine, Mandatory)]
    [securestring]$Token    
  )
  begin {
  }
  process {
    $OpenAI.Cfg.OpenAIToken = $Token
  }
  end {
  }
}