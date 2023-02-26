function Get-ImageMagickPos {
  [CmdletBinding()]
  param (
    [decimal]$v,
    [int]$pad = 1
  )
  
  if ($v -ge 0) { return "+$($v.ToString().PadLeft($pad - 1, '0'))" }
  else { return "-$([Math]::Abs($v).ToString().PadLeft($pad - 1, '0'))" }
}