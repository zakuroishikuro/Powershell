function chat($message) {
  $apiKey = $env:CHAT_GPT_API_KEY
  if ($apiKey -eq $null) {
    Write-Output "CHAT_GPT_API_KEY is not set."
    return
  }

  $uri = "https://api.openai.com/v1/chat/completions"

  $headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type"  = "application/json"
  }

  $body = @{
    model    = "gpt-3.5-turbo"
    messages = @(
      @{
        role    = "system"
        content = "You are a helpful assistant."
      },
      @{
        role    = "user"
        content = $message
      }
    )
  } | ConvertTo-Json

  $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body

  Write-Output $response.choices[0].message.content ""
}
