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