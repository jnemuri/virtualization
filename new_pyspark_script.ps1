# PowerShell Script: PySpark Local Setup Cheat Sheet Runner
# Description: Installs Python, PySpark, Jupyter, and optional tools — then opens a notebook-ready shell.
# Author: Joseph Nemuri Style 😎

function Command-Exists {
    param([string]$command)
    $ErrorActionPreference = "SilentlyContinue"
    return [bool](Get-Command $command -ErrorAction SilentlyContinue)
}

function Ensure-PythonInstalled {
    if (Command-Exists "python") {
        Write-Host "✔ Python is already installed: $(python --version)"
    } else {
        Write-Host "Installing Python 3.11 via winget..."
        winget install --silent --accept-package-agreements --accept-source-agreements Python.Python.3.11
        $env:PATH += ";C:\Python311;C:\Python311\Scripts"
        Write-Host "✅ Python installed."
    }
}

function Ensure-JavaInstalled {
    if (Command-Exists "java") {
        Write-Host "✔ Java is already installed: $(java -version 2>&1 | Select-Object -First 1)"
    } else {
        Write-Host "Installing OpenJDK 11 via Chocolatey..."
        choco install openjdk --version=11 -y
        Write-Host "✅ Java installed."
    }
}

function Setup-PySparkLocalDev {
    Write-Host "`n==> Setting up Local PySpark Dev Environment..." -ForegroundColor Cyan

    Ensure-PythonInstalled
    Ensure-JavaInstalled

    # Create venv
    $venvPath = "pyspark_dev_env"
    if (-not (Test-Path $venvPath)) {
        Write-Host "Creating virtual environment..."
        python -m venv $venvPath
    }

    Write-Host "Activating virtual environment and installing packages..."
    .\$venvPath\Scripts\Activate.ps1
    pip install --upgrade pip
    pip install pyspark jupyter pandas findspark

    Write-Host "✅ PySpark environment is ready!"
    Write-Host "`nTo run Jupyter Notebook, enter:`n    jupyter notebook"
    Write-Host "To run PySpark interactively, enter:`n    pyspark"
}

# === Menu ===
Write-Host "`n=============================="
Write-Host " PySpark Local Dev Environment"
Write-Host "=============================="
Write-Host "1) Install PySpark + Tools"
Write-Host "2) Exit"

$choice = Read-Host "Select an option (1-2)"
switch ($choice) {
    "1" { Setup-PySparkLocalDev }
    "2" { Write-Host "Exiting..."; exit }
    default { Write-Host "❌ Invalid choice." }
}
