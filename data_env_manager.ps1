# Requires -Version 5.1
# Data Environment Manager for PySpark, Pandas, Jupyter Notebook, and Node.js

function Install-DataEnv {
    Write-Host "Setting up on-demand PySpark environment..."

    # Ensure Chocolatey is installed and upgraded
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        } catch {
            Write-Host "Chocolatey installation failed. Please follow manual steps to reinstall."
            return
        }
    } else {
        Write-Host "Chocolatey is already installed. Upgrading Chocolatey..."
        choco upgrade chocolatey -y
    }

    # Ensure Python is installed
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Python is not installed. Installing Python..."
        choco install python -y
    } else {
        Write-Host "Python is already installed."
    }

    # Create and activate the virtual environment
    if (-not (Test-Path "pyspark_env")) {
        Write-Host "Creating Python virtual environment..."
        python -m venv pyspark_env
    }
    Write-Host "Activating virtual environment..."
    & .\pyspark_env\Scripts\Activate.ps1

    # Install Python dependencies using pip
    Write-Host "Upgrading pip..."
    & python -m pip install --upgrade pip

    foreach ($package in @("pyspark", "pandas", "numpy")) {
        Write-Host "Installing $package..."
        & python -m pip install $package
    }

    Write-Host "PySpark environment setup complete."
    Write-Host "The virtual environment 'pyspark_env' is now activated."
    Write-Host "You can now run PySpark commands or start Jupyter Notebook."
}

function Uninstall-DataEnv {
    Write-Host "Removing PySpark environment..."
    try {
        deactivate
    } catch {
        # Ignore errors if deactivate is not available
    }

    if (Test-Path "pyspark_env") {
        Write-Host "Removing virtual environment directory..."
        Remove-Item -Recurse -Force "pyspark_env"
        Write-Host "Virtual environment removed."
    } else {
        Write-Host "Virtual environment not found. Skipping removal."
    }

    Write-Host "Cleanup complete."
}

# Menu System
Write-Host "Data Environment Manager"
Write-Host "1) Install Environment (PySpark, Pandas, Jupyter Notebook)"
Write-Host "2) Remove Environment"
Write-Host "3) Exit"

$option = Read-Host "Choose an option (1-3)"
switch ($option) {
    1 { Install-DataEnv }
    2 { Uninstall-DataEnv }
    3 { Write-Host "Exiting..."; exit }
    default { Write-Host "Invalid option. Exiting..." }
}
