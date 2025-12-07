# ====================================
# init.ps1
# Initialization VM Script
# ====================================

Write-Output "Initializing IIS installation..."

Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Write-Output "IIS installation completed."

# Create deployment logs folder
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

#Create log file
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"Deployment started at $timestamp" | Out-File "$logPath\deployment.log"

Write-Output "init.ps1 successfully completed."