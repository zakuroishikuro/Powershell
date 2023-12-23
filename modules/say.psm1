function say {
  param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$InputString
  )

  process {
    if (!$synth) {
      Add-Type -AssemblyName System.Speech
      $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
      $synth.Rate = 2
    }
    if ($InputString) {
      $synth.Speak($InputString)
    }
    else {
      Write-Host "文字列を渡してください"
    }
  }
}