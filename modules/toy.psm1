Import-Module "$PSScriptRoot/emoji_clock.psm1"

function rotateClock {
  $delayMs = 100
  for ($i = 0; $i -lt 12; $i++) {
    Write-Host "`b`b$(clockEmoji $i)" -NoNewline
    Start-Sleep -Milliseconds $delayMs
    Write-Host "`b`b$(clockEmoji $i 30)" -NoNewline
    Start-Sleep -Milliseconds $delayMs
  }
  Write-Host "`b`b$(clockEmoji 0 0)"
}

function rotateMoon($delayMs = 100, $rotate = 3) {
  for ($i = 0; $i -lt 8 * $rotate; $i++) {
    $code = $i + 127761
    $char = [char]::ConvertFromUtf32($code)
    Write-Host "`b`b$char" -NoNewline
    Start-Sleep -Milliseconds $delayMs
  }
  Write-Host "`b`b🌑" -NoNewline
}

function randomFace {
  $faces = "‎(ง ‎-᷄ω-᷅ ‎)ว‎:‎٩( -᷄ω-᷅ ‎)۶:(ง-᷄ω-᷅ ‎)ว:‎( -᷄ω-᷅ ‎و(و:( 'ω' و(و:ƪ( 'ω' ƪ )" -Split ":"
  Get-Random -InputObject $faces
}