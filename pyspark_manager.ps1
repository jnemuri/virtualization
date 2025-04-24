#Check if java and python are installed
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Write-Host "Java is not installed. Please install Java to run this script."
    exit
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python is not installed. Please install Python to run this script."
    exit
}
#Check if the script is run from the correct directory
if ($PSScriptRoot -ne (Get-Location).Path) {
    Write-Host "Please run this script from the directory where it is located."
    exit
}

function Install-Environment {
    #Check if the script is run from the correct directory
    if ($PSScriptRoot -ne (Get-Location).Path) {
        Write-Host "Please run this script from the directory where it is located."
        exit
    }
    #Create venv for development
    python -m venv venv
    #Activate venv
    & "$PSScriptRoot\venv\Scripts\Activate.ps1"
    #Install requirements
    pip install -r requirements.txt
}
function Uninstall-Environment {
    # Check if the virtual environment is active and deactivate it
    if ($env:VIRTUAL_ENV) {
        try {
            Deactivate
        } catch {
            Write-Host "Failed to deactivate the virtual environment. Continuing..."
        }
    }

    # Stop any processes that might be using the virtual environment
    Get-Process | Where-Object { $_.Path -like "*$PSScriptRoot\venv*" } | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force
        } catch {
            
            Write-Host "Failed to stop process $($_.Name). Continuing..."
        }
    }

    # Remove the virtual environment folder
    try {
        Remove-Item -Recurse -Force venv
        Write-Host "Virtual environment removed successfully."
    } catch {
        Write-Host "Failed to remove the virtual environment. Error: $($_.Exception.Message)"
    }
}

#Menu for the user to choose the script to run
Write-Output "Please choose the script to run:"
Write-Output "1. Install Environment"
Write-Output "2. Uninstall Environment"
Write-Output "3. Exit"
$choice = Read-Host "Enter your choice (1-3)"
switch ($choice) {
    1 {
        Install-Environment
        Write-Output "Environment installed successfully."
    }
    2 {
        Uninstall-Environment
        Write-Output "Environment uninstalled successfully."
    }
    3 {
        Write-Output "Exiting..."
        exit
    }
    default {
        Write-Output "Invalid choice. Please enter a number between 1 and 3."
    }
}
