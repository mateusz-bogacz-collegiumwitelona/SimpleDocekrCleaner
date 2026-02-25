$logFolder = "$env:USERPROFILE\Desktop\SimpleDockerCleanerLogs"

if (!(Test-Path $logFolder)) { 
    New-Item -ItemType Directory -Path $logFolder 
}

$logDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFileName = "docker-cleaner-$logDate.log"
$logFilePath = Join-Path $logFolder $logFileName

function LogToFile {
    param ([string]$message, [string]$type = "INFO" )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$type] $message"
    Add-Content -Path $logFilePath -Value $logEntry
}

$asciiLogo = @"
 ____  _  _      ____  _     _____   ____  ____  ____ _  __ _____ ____    ____  _     _____ ____  _      _____ ____ 
/ ___\/ \/ \__/|/  __\/ \   /  __/  /  _ \/  _ \/   _Y |/ //  __//  __\  /   _\/ \   /  __//  _ \/ \  /|/  __//  __\
|    \| || |\/|||  \/|| |   |  \    | | \|| / \||  / |   / |  \  |  \/|  |  /  | |   |  \  | / \|| |\ |||  \  |  \/|
\___ || || |  |||  __/| |_/\|  /_   | |_/|| \_/||  \_|   \ |  /_ |    /  |  \__| |_/\|  /_ | |-||| | \|||  /_ |    /
\____/\_/\_/  \|\_/   \____/\____\  \____/\____/\____|_|\_\\____\\_/\_\  \____/\____/\____\\_/ \|\_/  \|\____\\_/\_\
                                                                                                                    
"@



Write-Host $asciiLogo -ForegroundColor Cyan

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    LogToFile "Run as Administrator!" -type "ERROR"
    Write-Host "Error: Run as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Write-Host "Stopping WSL and Docker services..." -ForegroundColor Green

try {
    LogToFile "Stopping Docker services and pruning system..." -type "INFO"
    Write-Host "Stopping Docker services and pruning system..." -ForegroundColor Green

    if (Get-Service -Name com.docker.service -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Running'}) {
        docker system prune -a --volumes -f | ForEach-Object { LogToFile $_ -type "INFO" }
    } else {
        LogToFile "Docker service not running, skipping prune." -type "WARNING"
        Write-Host "Docker service not running, skipping prune." -ForegroundColor Yellow
    }

    Stop-Service com.docker.service -Force -ErrorAction SilentlyContinue
    
    LogToFile "Docker services stopped." -type "INFO"
    Write-Host "Docker services stopped." -ForegroundColor Green

    LogToFile "Terminating WSL instances..." -type "INFO" 
    Write-Host "Terminating WSL instances..." -ForegroundColor Yellow
    
        
    $wslDistros = wsl -l -q
    if ($wslDistros -contains "docker-desktop") { 
        wsl --terminate docker-desktop 
    }
    
    if ($wslDistros -contains "docker-desktop-data") { 
        wsl --terminate docker-desktop-data
    }

    wsl --shutdown
    Start-Sleep -Seconds 2
}
catch {
    LogToFile "Error stopping services: $_" -type "ERROR"
    Write-Host "Error stopping services: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
}

Start-Sleep 2

$vhdx = "C:\Users\$env:USERNAME\AppData\Local\Docker\wsl\disk\docker_data.vhdx"

if (!(Test-Path $vhdx)) {
    LogToFile "VHDX file not found at $vhdx" -type "ERROR"
    Write-Host "VHDX file not found at $vhdx" -ForegroundColor Red
    exit
}

LogToFile "Optimizing VHDX file at $vhdx" -type "INFO"
Write-Host "Optimizing VHDX file..." -ForegroundColor Green

try {
    Optimize-VHD -Path $vhdx -Mode Full
}
catch {
    try {
        LogToFile "Full optimization failed: $_. Attempting DiskPart fallback..." -type "WARNING"
        Write-Host "Full optimization failed. Trying  DiskPart fallback..." -ForegroundColor Yellow
        
$diskpart = @"
select vdisk file="$vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@
    $diskpart | diskpart | ForEach-Object { LogToFile $_ -type "INFO" }
    }
    catch {
        LogToFile "Error optimizing VHDX file: $_" -type "ERROR"
        Write-Host "Error optimizing VHDX file: $_" -ForegroundColor Red
        Read-Host "Press Enter to exit..."
    }
}

LogToFile "===== Docker Cleaner finished at $(Get-Date) =====" -type "INFO"
Write-Host "===== Docker Cleaner finished at $(Get-Date) =====" -ForegroundColor Green
Write-Host "Log file saved to: $logFilePath" -ForegroundColor Cyan
Read-Host "Press Enter to exit..."