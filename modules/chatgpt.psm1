$SYSTEM_CONTENT = "You are a helpful assistant."

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
    model    = "gpt-3.5-turbo"
    messages = $script:ChatGptMessages
  } | ConvertTo-Json

  $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

  $responsedMessage = $response.choices[0].message.content
  $script:ChatGptMessages += @{
    role    = "system"
    content = $responsedMessage
  }
  Write-Output $responsedMessage ""
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

function chat_init {
  $script:ChatGptMessages = @(
    @{
      role    = "system"
      content = $SYSTEM_CONTENT
    }
  )
}

function chat_history {
  $script:ChatGptMessages | ForEach-Object {
    Write-Output " * $($_.role): $($_.content)"
  }
}

chat_init