function gpt($message) {
  $apiKey = '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'
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
