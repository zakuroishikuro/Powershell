function show_path {
  [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User).Split(";")
}

function add_path([string]$new_path) {
  $new_path = $new_path -replace '/', '\'

  # フォルダが存在しないなら終了
  if (-not (Test-Path -Path $new_path -PathType Container)) {
    Write-Output  "指定されたパスのフォルダは存在しません: $new_path"
    return
  }

  # 環境変数Pathを取得 (ユーザー)
  $user_path = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

  # すでに追加済みであれば終了
  if ($user_path -like "*$new_path*") {
    Write-Output  "パスはすでに環境変数に存在します: $new_path"
    return
  }

  # パスを追加
  if (-not $user_path.EndsWith(";")) {
    $user_path += ";"
  }
  $user_path += $new_path
  [Environment]::SetEnvironmentVariable("Path", $user_path, [EnvironmentVariableTarget]::User)

  Write-Output "新しいパスをユーザー環境変数に追加しました: $new_path"
}

# PowerShellだとwhereに.exeつけないと動かない。linuxと同じくwhichで動くようにしておく
Set-Alias which where.exe

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

function prompt() {
  # ホームディレクトリは「~」に置換
  $d = (Get-Location).Path.Replace($HOME, "~")
  "$(clockEmojiNow) $($d)> "
}

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

function Get-SystemInfo {
  # システム情報を取得
  $computerSystem = Get-CimInstance CIM_ComputerSystem
  $os = Get-CimInstance CIM_OperatingSystem
  $cpu = Get-CimInstance CIM_Processor
  $rams = Get-CimInstance CIM_PhysicalMemory
  $disks = Get-CimInstance Win32_DiskDrive
  $gpus = Get-CimInstance Win32_VideoController

  # 出力用の文字列を初期化
  $output = "メーカー名: $($computerSystem.Manufacturer)`n"
  $output += "型番: $($computerSystem.Model)`n"
  $output += "OS: $($os.Caption)`n"
  $output += "CPU: $($cpu.Name), コア数: $($cpu.NumberOfCores)`n"

  # RAM情報
  $totalRam = 0
  $ramDetails = ""
  foreach ($ram in $rams) {
    $totalRam += $ram.Capacity
    $ramDetails += "RAM: [容量: $([math]::Round($ram.Capacity / 1GB, 2)) GB, 型番: $($ram.PartNumber)]`n"
  }
  $totalRamGB = [math]::Round($totalRam / 1GB, 2)
  $output += "合計RAM: ${totalRamGB}GB`n"
  $output += $ramDetails

  # ストレージ情報
  foreach ($disk in $disks) {
    $diskSizeGB = "{0:N2}" -f ($disk.Size / 1GB)
    $output += "ストレージ: [モデル: $($disk.Model), 容量: ${diskSizeGB} GB]`n"
  }

  # GPU情報
  foreach ($gpu in $gpus) {
    $output += "GPU: [名前: $($gpu.Name), ドライバーバージョン: $($gpu.DriverVersion)]`n"
  }

  # 結果の表示
  Write-Host $output
}
