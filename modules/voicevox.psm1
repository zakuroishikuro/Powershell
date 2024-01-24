function voiceVox {
  param (
    [Parameter(ValueFromPipeline = $true)]
    [string]$text,
    [int]$speaker = 1
  )

  process {
      $enc = [System.Web.HttpUtility]::UrlEncode($text)

      $uri = "http://localhost:50021/audio_query?speaker=$speaker&text=$enc"
      $res = Invoke-WebRequest $uri -Method Post
      $json = $res.Content

      $uri = "http://localhost:50021/synthesis?speaker=1"
      $res = Invoke-WebRequest $uri -Method Post -ContentType "application/json" -Body $json
      $audio = $res.Content

      playAudioBin $audio
    
  }
}

function playAudioFile([string]$filePath) {
  $fileData = [System.IO.File]::ReadAllBytes($FilePath)
  Play-AudioFromBinary $fileData
}

function playAudioBin([byte[]]$bytes) {
  $stream = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
  $player = New-Object System.Media.SoundPlayer $stream
  $player.Play()
}