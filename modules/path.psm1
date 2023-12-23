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