Write-Host "====================================="
Write-Host "          GAME READY"
Write-Host "====================================="
Write-Host ""

$cpu = Get-CimInstance Win32_Processor

Write-Host "CPU"
Write-Host "-------------------------------------"
Write-Host "Name: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "Threads: $($cpu.NumberOfLogicalProcessors)"

$gpu = Get-CimInstance Win32_VideoController

Write-Host ""
Write-Host "GPU"
Write-Host "-------------------------------------"
Write-Host "Name: $($gpu.Name)"
Write-Host "Driver Version: $($gpu.DriverVersion)"

$computerSystem = Get-CimInstance Win32_ComputerSystem
$operatingSystem = Get-CimInstance Win32_OperatingSystem

$totalRamGB = [System.Math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
$freeRamGB = [System.Math]::Round(($operatingSystem.FreePhysicalMemory * 1KB) / 1GB, 2)

Write-Host ""
Write-Host "MEMORY"
Write-Host "-------------------------------------"
Write-Host "Installed: $totalRamGB GB"
Write-Host "Currently Free: $freeRamGB GB"

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