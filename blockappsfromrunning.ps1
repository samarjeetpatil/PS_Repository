$processNames = @("chrome.exe")  # Replace with the actual process name

Foreach ($processName in $processNames)

{

# Check if the process is already running

$runningProcess = Get-Process | Where-Object { $_.Name -eq $processName }

 

if ($runningProcess) {

    Write-Host "Process '$processName' is currently running. Please terminate it before blocking."

} else {

    # Create a registry entry to prevent the process from starting

    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$processName"


    if (-not (Test-Path $keyPath)) {

        New-Item -Path $keyPath -Force

    }


    Set-ItemProperty -Path $keyPath -Name "Debugger" -Value "C:\Windows\System32\systray.exe"  # Replace with a harmless executable

    Write-Host "Blocked process '$processName' from starting."

}

}



##################################################################################################################################################


$processNames = @("firefox.exe")  # Replace with actual process names you want to block

Foreach ($processName in $processNames) {
    
    # Get the process by name and fetch full file path
    $processInfo = Get-WmiObject Win32_Process -Filter "Name='$processName'"
    
    if ($processInfo) {
        # Process is running, terminate it
        foreach ($process in $processInfo) {
            $processPath = $process.ExecutablePath
            Write-Host "Process '$processName' is currently running from path: $processPath. Terminating the process."

            try {
                Stop-Process -Id $process.ProcessId -Force
                Write-Host "Successfully terminated '$processName'."
            } catch {
                Write-Host "Failed to terminate '$processName': $_"
            }
        }
    }

    # Block the process from starting again using IFEO
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$processName"
    
    if (-not (Test-Path $keyPath)) {
        New-Item -Path $keyPath -Force
    }

    # Block by setting a "Debugger" key to systray.exe or another harmless executable
    Set-ItemProperty -Path $keyPath -Name "Debugger" -Value "C:\Windows\System32\systray.exe"  # Replace with harmless executable

    Write-Host "Blocked process '$processName' from starting."
}
