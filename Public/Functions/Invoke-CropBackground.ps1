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
  $info = Get-ImageInformation -Path $Path
  & $OpenAI.cfg.MagickPath $Path -fuzz 10% -fill none -floodfill "+0+0" white $tempPath | Out-Null
  & $OpenAI.cfg.MagickPath $tempPath -fuzz 10% -fill none -floodfill "+$($info.Width - 1)+0" white $tempPath | Out-Null
  & $OpenAI.cfg.MagickPath $Path -fuzz 10% -fill none -floodfill "+0+$($info.Height - 1)" white $tempPath | Out-Null
  & $OpenAI.cfg.MagickPath $tempPath -fuzz 10% -fill none -floodfill "+$($info.Width - 1)+$($info.Height - 1)" white $tempPath | Out-Null
  return Get-Item -Path $tempPath
}