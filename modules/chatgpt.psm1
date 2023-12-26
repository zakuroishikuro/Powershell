$DEFAULT_MESSAGE = @(
  @{
    role    = "system"
    content = "You are a helpful assistant."
  }
)

$script:chat_model = "gpt-3.5-turbo"

function chatgpt($message) {
  $apiKey = $env:CHAT_GPT_API_KEY
  if ($null -eq $apiKey) {
    Write-Output "CHAT_GPT_API_KEY is not set."
    return
  }

  $uri = "https://api.openai.com/v1/chat/completions"

  $headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type"  = "application/json"
  }

  # 返答をpushする
  $script:ChatGptMessages += @{
    role    = "user"
    content = $message
  }

  $body = @{
    model    = $script:chat_model
    messages = $script:ChatGptMessages
  } | ConvertTo-Json

  $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

  $responsedMessage = $response.choices[0].message.content
  $script:ChatGptMessages += @{
    role    = "system"
    content = $responsedMessage
  }
  Write-Output $responsedMessage ""

  # ログをmarkdownで出力
  $script:chat_model + "`n`n" | Out-File $script:chat_log_file
  $script:ChatGptMessages | ForEach-Object {
    $role = $_.role
    $content = $_.Content
    "# $role :`n$content`n"
  } | Out-File $script:chat_log_file -Append
}

function chat($messageArg) {
  # messageがあればそれをchatgptに渡す
  if ($messageArg) {
    chatgpt $messageArg
    return
  }

  #messageが空ならwhile-loopで何度もchatgptに質問可能にする
  while ($true) {
    $message = Read-Host " * chat> "
    # 文字列が空なら終了
    if ($message) {
      chatgpt $message
    }
    else {
      break
    }
  }
}

function chat_model ($model) {
  # $modelに4を含んでいれば"gpt-4 turbo", それ以外なら"gpt-3.5-turbo"
  $script:chat_model = $model -like "*4*" ? "gpt-4" : "gpt-3.5-turbo"
  Write-Output " * model: $script:chat_model"
}

function chat_new ($message) {
  chat_init
  chat $message
}

function chat_init {
  $script:ChatGptMessages = $DEFAULT_MESSAGE.Clone()

  $timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
  $guid = (new-guid).guid
  $dir = (Get-Item $profile).DirectoryName
  $script:chat_log_file = "$dir\chat-log\chat-$timestamp-$guid.md"
}

function chat_history {
  $script:ChatGptMessages | ForEach-Object {
    Write-Output " * $($_.role): $($_.content)"
  }
}

chat_init