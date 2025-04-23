# PowerShell Script: Install/Uninstall PySpark Environment on Windows

function Command-Exists {
    param([string]$command)
    $ErrorActionPreference = "SilentlyContinue"
    return [bool](Get-Command $command -ErrorAction SilentlyContinue)
}

function Install-PySpark {
    Write-Host "`n==> Installing PySpark Environment..." -ForegroundColor Cyan

    # Install Python if missing
    if (-not (Command-Exists "python")) {
        Write-Host "Installing Python via winget..."
        winget install --silent --accept-package-agreements --accept-source-agreements Python.Python.3
        Start-Sleep -Seconds 10
    } else {
        Write-Host "✔ Python is already installed."
    }

    # Install Apache Spark manually if missing
    $sparkPath = "C:\spark"
    $sparkVersion = "3.4.1"
    $sparkArchive = "spark-$sparkVersion-bin-hadoop3"
    $downloadUrl = "https://dlcdn.apache.org/spark/spark-$sparkVersion/$sparkArchive.tgz"

    if (-not (Test-Path $sparkPath)) {
        Write-Host "Downloading Apache Spark $sparkVersion..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile "spark.tgz"

        Write-Host "Extracting Spark archive..."
        tar -xvf "spark.tgz" -C "C:\"
        Rename-Item -Path "C:\$sparkArchive" -NewName "spark"
        Remove-Item "spark.tgz"
    } else {
        Write-Host "✔ Apache Spark is already installed."
    }

    # Set environment variables
    [Environment]::SetEnvironmentVariable("SPARK_HOME", $sparkPath, "Machine")
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$sparkPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$sparkPath\bin", "Machine")
    }
    [Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", "python", "Machine")

    # Create virtual environment if needed
    if (-not (Test-Path "pyspark_env")) {
        Write-Host "Creating Python virtual environment..."
        python -m venv pyspark_env
    }

    # Manual reminder for activation
    Write-Host "`n📌 Manual Activation Required:"
    Write-Host "`t.\pyspark_env\Scripts\Activate.ps1"
    Write-Host "`nAfter activation, run:"
    Write-Host "`tpip install --upgrade pip"
    Write-Host "`tpip install pyspark jupyter pandas numpy"

    Write-Host "`n✅ Installation setup complete. Restart PowerShell and activate your environment to begin." -ForegroundColor Green
}

function Uninstall-PySpark {
    Write-Host "`n==> Uninstalling PySpark Environment..." -ForegroundColor Yellow

    # Remove virtual env
    if (Test-Path "pyspark_env") {
        Remove-Item -Recurse -Force "pyspark_env"
        Write-Host "✔ Virtual environment removed."
    }

    # Remove Spark folder
    $sparkPath = "C:\spark"
    if (Test-Path $sparkPath) {
        Remove-Item -Recurse -Force $sparkPath
        Write-Host "✔ Apache Spark directory removed."
    }

    Write-Host "ℹ️ Environment variables remain (you may want to remove SPARK_HOME manually if needed)."
    Write-Host "🧹 Uninstallation complete." -ForegroundColor Green
}

# Menu System
Write-Host "`n=============================="
Write-Host " PySpark Environment Manager"
Write-Host "=============================="
Write-Host "1) Install PySpark Environment"
Write-Host "2) Uninstall PySpark Environment"
Write-Host "3) Exit"

$choice = Read-Host "Select an option (1-3)"

switch ($choice) {
    "1" { Install-PySpark }
    "2" { Uninstall-PySpark }
    "3" { Write-Host "Exiting..."; exit }
    default { Write-Host "❌ Invalid choice." }
}
