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
Write-Host ""
Write-Host "READINESS"
Write-Host "-------------------------------------"
if ($totalRamGB -lt 8) {
    Write-Host "[FAIL] Memory: Less than 8 GB of RAM installed."
} 
elseif ($totalRamGB -lt 16) {
    Write-Hose "[WARN] Memory: Less than 16 GB of RAM installed."
}
else {
    Write-Host "[PASS] Memory: $totalRAMGB GB installed."
}

foreach ($drive in $drives) {
    $freeSpacePercent = [System.Math]::Round(
        ($drive.FreeSpace / $drive.Size) * 100,
        1
    )

    if ($freeSpacePercent -lt 10) {
        Write-Host "[WARN] Storage $($drive.DeviceID) Only $freeSpacePercent% free."
    }
    else {
        Write-Host "[PASS] Storage $($drive.DeviceID) $freeSpacePercent% free." 
    }
}
