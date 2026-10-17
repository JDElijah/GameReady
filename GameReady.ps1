# Param block
param(
    [switch]$SaveReport,
    [string]$Game
)


# Write Status Function
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )

    switch ($Status) {
        "PASS" { $color = "Green" }
        "WARN" { $color = "Yellow" } 
        "FAIL" { $color = "Red" }
        default { $color = "White" }
    }

    Write-Host "[$Status] $Message" -ForegroundColor $color
}

Write-Host "====================================="
Write-Host "          GAME READY"
Write-Host "====================================="
Write-Host ""

# CPU Detection
$cpu = Get-CimInstance Win32_Processor

Write-Host "CPU"
Write-Host "-------------------------------------"
Write-Host "Name: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "Threads: $($cpu.NumberOfLogicalProcessors)"

# GPU Detection
$gpu = Get-CimInstance Win32_VideoController

Write-Host ""
Write-Host "GPU"
Write-Host "-------------------------------------"
Write-Host "Name: $($gpu.Name)"
Write-Host "Driver Version: $($gpu.DriverVersion)"

# Memory Detection
$computerSystem = Get-CimInstance Win32_ComputerSystem
$operatingSystem = Get-CimInstance Win32_OperatingSystem

$totalRamGB = [System.Math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
$freeRamGB = [System.Math]::Round(($operatingSystem.FreePhysicalMemory * 1KB) / 1GB, 2)

Write-Host ""
Write-Host "MEMORY"
Write-Host "-------------------------------------"
Write-Host "Installed: $totalRamGB GB"
Write-Host "Currently Free: $freeRamGB GB"

# Storage Detection
$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

Write-Host ""
Write-Host "STORAGE"
Write-Host "-------------------------------------"

foreach ($drive in $drives) {
    $totalSpaceGB = [System.Math]::Round($drive.Size / 1GB, 2)
    $freeSpaceGB = [System.Math]::Round($drive.FreeSpace / 1GB, 2)

    Write-Host "$($drive.DeviceID)"
    Write-Host "Total: $totalSpaceGB GB"
    Write-Host "Free: $freeSpaceGB GB"
    Write-Host ""
}

# Windows / System Information
$baseBoard = Get-CimInstance Win32_BaseBoard

Write-Host ""
Write-Host "SYSTEM"
Write-Host "-------------------------------------"
Write-Host "Computer Name: $($computerSystem.Name)"
Write-Host "Motherboard Manufacturer: $($baseBoard.Manufacturer)"
Write-Host "Motherboard: $($baseBoard.Product)"
Write-Host "Windows: $($operatingSystem.Caption)"
Write-Host "Version: $($operatingSystem.Version)"
Write-Host "Build: $($operatingSystem.BuildNumber)"
Write-Host "Architecture: $($operatingSystem.OSArchitecture)"

# Readiness Rules and Warnings
$hasWarning = $false
$hasFailure = $false

Write-Host ""
Write-Host "READINESS"
Write-Host "-------------------------------------"
if ($totalRamGB -lt 8) {
    $hasFailure = $true
    Write-Status -Status "FAIL" -Message "Memory: Less than 8 GB of RAM installed."
} 
elseif ($totalRamGB -lt 16) {
    $hasWarning = $true
    Write-Status -Status "WARN" -Message "Memory: Less than 16 GB of RAM installed."
}
else {
    Write-Status -Status "PASS" -Message "Memory: $totalRAMGB GB installed."
}

foreach ($drive in $drives) {
    $freeSpacePercent = [System.Math]::Round(
        ($drive.FreeSpace / $drive.Size) * 100,
        1
    )

    if ($freeSpacePercent -lt 10) {
        $hasWarning = $true
        Write-Status -Status "WARN" -Message "Storage $($drive.DeviceID) only $freeSpacePercent% free."
    }
    else {
        Write-Status -Status "PASS" -Message "Storage $($drive.DeviceID) $freeSpacePercent% free." 
    }
}

# Overall Result 
Write-Host ""
Write-Host "-------------------------------------"

if ($hasFailure) {
    $overallStatus = "NOT READY"
    Write-Host "OVERALL STATUS: $overallStatus" -ForegroundColor Red
}
elseif ($hasWarning) {
    $overallStatus = "ATTENTION NEEDED"
    Write-Host "OVERALL STATUS: $overallStatus" -ForegroundColor Yellow
}
else {
    $overallStatus = "READY"
    Write-Host "OVERALL STATUS: $overallStatus" -ForegroundColor Green
}

if ($Game) {
    Write-Host ""
    Write-Host "GAME COMPARISON"
    Write-Host "-------------------------------------"
    Write-Host "Requested Game: $Game"
    Write-Host "Game requirement lookup is not implemented yet." -ForegroundColor Yellow
}

# Build storage data for report 
$storageReport = foreach ($drive in $drives) {
    $totalSpaceGB = [System.Math]::Round($drive.Size / 1GB, 2)
    $freeSpaceGB = [System.Math]::Round($drive.FreeSpace / 1GB, 2)
    $freeSpacePercent = [System.Math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)

    [PSCustomObject]@{
        Drive       = $drive.DeviceID
        TotalGB     = $totalSpaceGB
        FreeGB      = $freeSpaceGB 
        FreePercent = $freeSpacePercent 
    }
}

# Build the complete GameReady report 
$report = [PSCustomObject]@{
    GeneratedAt   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    System        = [PSCustomObject]@{
        ComputerName = $computerSystem.Name
        Windows      = $operatingSystem.Caption
        Version      = $operatingSystem.Version
        Architecture = $operatingSystem.OSArchitecture
    }

    CPU           = [PSCustomObject]@{
        Name    = $cpu.Name
        Cores   = $cpu.NumberOfCores
        Threads = $cpu.NumberOfLogicalProcessors
    }

    GPU           = [PSCustomObject]@{
        Name          = $gpu.Name
        DriverVersion = $gpu.DriverVersion
    }

    Memory        = [PSCustomObject]@{
        InstalledGB = $totalRamGB
        FreeGB      = $freeRamGB
    }

    Storage       = $storageReport

    OverallStatus = $overallStatus
}

if ($SaveReport) {
    $reportDirectory = Join-Path $PSScriptRoot "reports"

    if (-not (Test-path $reportDirectory)) {
        New-Item -ItemType Directory -Path $reportDirectory | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportPath = Join-Path $reportDirectory "GameReady-$timestamp.json"

    $report | 
    ConvertTo-Json -Depth 4 |
    Out-File $reportPath

    Write-Host ""
    Write-Host "Report saved to: $reportPath"
}