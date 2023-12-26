$global:ChatGptMessages = @(
  @{
    role    = "system"
    content = "You are a helpful assistant."
  }
)

function chat($message) {
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
  $global:ChatGptMessages += @{
    role    = "user"
    content = $message
  }

  $body = @{
    model    = "gpt-3.5-turbo"
    messages = $global:ChatGptMessages
  } | ConvertTo-Json

  

  $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

  $responsedMessage = $response.choices[0].message.content
  $global:ChatGptMessages += @{
    role    = "system"
    content = $responsedMessage
  }
  Write-Output $responsedMessage ""
}
