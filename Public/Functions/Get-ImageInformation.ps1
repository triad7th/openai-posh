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
  $format = @'
{
  Filename        : "%f",
  ImageFormat     : "%m",
  Width           : %w,
  Height          : %h,
  PageWidth       : %W,
  PageHeight      : %H,
  XOffset         : "%X",
  YOffset         : "%Y",
  Depth           : %z,
  Colorspace      : "%r",
  FileSize        : "%b",
  NumberOfImages  : %n,
  Delay           : %T  
},
'@
  
  $response = & $OpenAI.cfg.MagickPath identify -format $format $Src.FullName | Where-Object {$_ -ne ""} | Out-String
  "[$($response.TrimEnd().TrimEnd(","))]" | ConvertFrom-Json
}

New-Alias -Name gii -Value Get-ImageInformation