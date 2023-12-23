# ./modules/ 配下のモジュールを読み込む
Get-ChildItem "$PSScriptRoot\modules" -Filter *.psm1 | % {
  Import-Module $_.FullName
}

# PowerShellだとwhereに.exeつけないと動かない。linuxと同じくwhichで動くようにしておく
Set-Alias which where.exe

function prompt() {
  # ホームディレクトリは「~」に置換
  $d = (Get-Location).Path.Replace($HOME, "~")
  "$(clockEmojiNow) $($d)> "
}