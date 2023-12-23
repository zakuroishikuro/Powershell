function clockEmojiNow {
  $now = Get-Date
  clockEmoji $now.Hour $now.Minute
}

function clockEmoji($h, $m) {
  $h = $h % 12
  $code = 128335
  $code += $h -ne 0 ? $h : 12
  $code += $m -lt 30 ? 0 : 12
  [char]::ConvertFromUtf32($code)
}
