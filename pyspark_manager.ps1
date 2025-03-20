# Detect Operating System
$OS = $env:OS
$IsWin = $OS -like "Windows*"
$IsMac = $env:OSTYPE -like "*darwin*"

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
    Write-Host "🔹 Detecting OS and Installing PySpark..." -ForegroundColor Cyan

    if ($IsWin) {
        Write-Host "🖥️ Detected Windows OS" -ForegroundColor Yellow

        # Install Python
        if (-Not (Command-Exists python)) {
            Write-Host "🔹 Installing Python..."
            winget install --silent --accept-package-agreements --accept-source-agreements Python.Python.3
        } else {
            Write-Host "✅ Python is already installed."
        }

        # Install Apache Spark on Windows
        $sparkInstallPath = "C:\spark"
        if (-Not (Test-Path $sparkInstallPath)) {
            Write-Host "🔹 Downloading and Installing Apache Spark..."
            Invoke-WebRequest -Uri "https://dlcdn.apache.org/spark/spark-3.4.1/spark-3.4.1-bin-hadoop3.tgz" -OutFile "spark.tgz"
            tar -xvf "spark.tgz" -C "C:\"
            Rename-Item "C:\spark-3.4.1-bin-hadoop3" $sparkInstallPath
            Remove-Item "spark.tgz"
        } else {
            Write-Host "✅ Apache Spark is already installed."
        }

        # Set Environment Variables
        [System.Environment]::SetEnvironmentVariable("SPARK_HOME", $sparkInstallPath, "Machine")
        [System.Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$sparkInstallPath\bin", "Machine")
        [System.Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", "python", "Machine")
    }

    elseif ($IsMac) {
        Write-Host "🍏 Detected macOS" -ForegroundColor Yellow

        # Install Homebrew
        if (-Not (Command-Exists brew)) {
            Write-Host "🔹 Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        } else {
            Write-Host "✅ Homebrew is already installed."
        }

        # Install Python
        if (-Not (Command-Exists python3)) {
            Write-Host "🔹 Installing Python..."
            brew install python
        } else {
            Write-Host "✅ Python is already installed."
        }

        # Install Apache Spark
        if (-Not (Command-Exists spark-shell)) {
            Write-Host "🔹 Installing Apache Spark..."
            brew install apache-spark
        } else {
            Write-Host "✅ Apache Spark is already installed."
        }

        # Set Environment Variables
        echo 'export SPARK_HOME=/opt/homebrew/Cellar/apache-spark/3.4.1/libexec' >> ~/.zshrc
        echo 'export PATH=$SPARK_HOME/bin:$PATH' >> ~/.zshrc
        echo 'export PYSPARK_PYTHON=python3' >> ~/.zshrc
        source ~/.zshrc
    }

    # Install PySpark in a virtual environment
    Write-Host "🔹 Setting up virtual environment..."
    python3 -m venv pyspark_env
    Write-Host "✅ Virtual environment 'pyspark_env' created."
    Write-Host "✅ Installation complete!" -ForegroundColor Green
}

function Uninstall-PySpark {
    Write-Host "🔹 Uninstalling PySpark and dependencies..." -ForegroundColor Cyan

    # Remove the virtual environment
    if (Test-Path "pyspark_env") {
        Remove-Item -Recurse -Force "pyspark_env"
        Write-Host "✅ Virtual environment removed."
    }

    # Remove Spark
    $sparkInstallPath = "C:\spark"
    if ($IsWin -and (Test-Path $sparkInstallPath)) {
        Remove-Item -Recurse -Force $sparkInstallPath
        Write-Host "✅ Apache Spark removed."
    }

    if ($IsMac) {
        brew uninstall apache-spark
        Write-Host "✅ Apache Spark removed."
    }

    Write-Host "✅ Uninstallation complete!" -ForegroundColor Green
}

# Menu System
Write-Host "🔹 PySpark Environment Manager 🔹" -ForegroundColor Cyan
Write-Host "1️⃣ Install PySpark Environment"
Write-Host "2️⃣ Uninstall PySpark Environment"
Write-Host "3️⃣ Exit"

$option = Read-Host "Choose an option (1-3)"

switch ($option) {
    "1" { Install-PySpark }
    "2" { Uninstall-PySpark }
    "3" { Write-Host "🚀 Exiting..." -ForegroundColor Yellow; exit }
    default { Write-Host "❌ Invalid option. Exiting..." -ForegroundColor Red }
}