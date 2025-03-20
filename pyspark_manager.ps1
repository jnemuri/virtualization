# PowerShell Script for Windows to Install and Uninstall PySpark Environment

# Function to check if a command exists
function Command-Exists {
    param([string]$command)
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = "SilentlyContinue"
    $exists = [bool](Get-Command $command -ErrorAction SilentlyContinue)
    $ErrorActionPreference = $oldPref
    return $exists
}

function Install-PySpark {
    Write-Host "Installing PySpark Environment..."

    # Install Python if not found
    if (-Not (Command-Exists python)) {
        Write-Host "Installing Python..."
        winget install --silent --accept-package-agreements --accept-source-agreements Python.Python.3
    } else {
        Write-Host "Python is already installed."
    }

    # Install Apache Spark
    $sparkInstallPath = "C:\spark"
    if (-Not (Test-Path $sparkInstallPath)) {
        Write-Host "Downloading and Installing Apache Spark..."
        Invoke-WebRequest -Uri "https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz" -OutFile "spark.tgz"
        tar -xvf "spark.tgz" -C "C:\"
        Rename-Item "C:\spark-3.4.1-bin-hadoop3" $sparkInstallPath
        Remove-Item "spark.tgz"
    } else {
        Write-Host "Apache Spark is already installed."
    }

    # Set Environment Variables
    [System.Environment]::SetEnvironmentVariable("SPARK_HOME", $sparkInstallPath, "Machine")
    [System.Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$sparkInstallPath\bin", "Machine")
    [System.Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", "python", "Machine")

    # Set up virtual environment
    if (-Not (Test-Path "pyspark_env")) {
        Write-Host "Creating Python virtual environment..."
        python -m venv pyspark_env
    }

    # Activate virtual environment
    Write-Host "Activating virtual environment..."
    .\pyspark_env\Scripts\Activate

    # Ensure PySpark is installed inside the virtual environment
    $pyspark_installed = pip list | Select-String "pyspark"
    if (-not $pyspark_installed) {
        Write-Host "Installing PySpark..."
        pip install pyspark
    } else {
        Write-Host "PySpark is already installed."
    }

    deactivate
    Write-Host "Installation complete!"
}

function Uninstall-PySpark {
    Write-Host "Uninstalling PySpark and dependencies..."

    # Remove the virtual environment
    if (Test-Path "pyspark_env") {
        Remove-Item -Recurse -Force "pyspark_env"
        Write-Host "Virtual environment removed."
    }

    # Remove Spark
    $sparkInstallPath = "C:\spark"
    if (Test-Path $sparkInstallPath) {
        Remove-Item -Recurse -Force $sparkInstallPath
        Write-Host "Apache Spark removed."
    }

    Write-Host "Uninstallation complete!"
}

# Menu System
Write-Host "PySpark Environment Manager"
Write-Host "1) Install PySpark Environment"
Write-Host "2) Uninstall PySpark Environment"
Write-Host "3) Exit"

$option = Read-Host "Choose an option (1-3)"

switch ($option) {
    "1" { Install-PySpark }
    "2" { Uninstall-PySpark }
    "3" { Write-Host "Exiting..."; exit }
    default { Write-Host "Invalid option. Exiting..." }
}