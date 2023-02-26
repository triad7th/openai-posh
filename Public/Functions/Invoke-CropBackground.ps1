function Invoke-CropBackground {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Path
  )

  try {
    $item = Get-Item -Path $Path -ErrorAction Stop
  }
  catch {
    "File IO error!"
    return
  }

  $tempPath = "$($OpenAI.cfg.TempPath)\$($item.BaseName)_$([Guid]::NewGuid())$($item.Extension)"
  & $OpenAI.cfg.MagickPath $Path -fuzz 10% -fill none -floodfill +0+0 white $tempPath | Out-Null
  return Get-Item -Path $tempPath
}