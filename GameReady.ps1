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
