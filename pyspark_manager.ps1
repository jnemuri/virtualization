# PowerShell Script: PySpark Pool Manager (Install/Uninstall)
# Author: Joseph Nemuri Style 😎
# Note: To activate the virtual environment in your current session persistently, dot-source this script:
#   . .\pyspark_pool.ps1

function Command-Exists {
    param([string]$command)
    $ErrorActionPreference = "SilentlyContinue"
    return [bool](Get-Command $command -ErrorAction SilentlyContinue)
}

function Install-PySpark {
    Write-Host "`n==> Installing PySpark Environment..." -ForegroundColor Cyan

    # === Install Python system-wide ===
    if (-not (Command-Exists "python")) {
        $pythonInstaller = "python-3.11.8-amd64.exe"
        $pythonUrl = "https://www.python.org/ftp/python/3.11.8/$pythonInstaller"

        Write-Host "Downloading Python 3.11 installer..."
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

        Write-Host "Installing Python to C:\Python311..."
        Start-Process -Wait -FilePath ".\$pythonInstaller" -ArgumentList `
            "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=\"C:\Python311\""

        Remove-Item $pythonInstaller

        # Refresh Python path in current session
        Write-Host "Refreshing Python environment in current session..."
        $env:PYTHON_HOME = "C:\Python311"
        $env:PATH += ";C:\Python311;C:\Python311\Scripts"
    } else {
        Write-Host "✔ Python is already installed."
    }

    # === Install Apache Spark ===
    $sparkPath = "C:\spark"
    $sparkVersion = "3.4.1"
    $sparkArchive = "spark-$sparkVersion-bin-hadoop3"
    $downloadUrl = "https://dlcdn.apache.org/spark/spark-$sparkVersion/$sparkArchive.tgz"

    if (-not (Test-Path $sparkPath)) {
        Write-Host "Downloading Apache Spark $sparkVersion..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile "spark.tgz"

        Write-Host "Extracting Spark..."
        tar -xvf "spark.tgz" -C "C:\"
        Rename-Item -Path "C:\$sparkArchive" -NewName "spark"
        Remove-Item "spark.tgz"
    } else {
        Write-Host "✔ Apache Spark is already installed."
    }

    # === Set system-wide environment variables ===
    Write-Host "Setting environment variables..."
    [System.Environment]::SetEnvironmentVariable("SPARK_HOME", "C:\spark", "Machine")
    [System.Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", "C:\Python311\python.exe", "Machine")
    [System.Environment]::SetEnvironmentVariable("PYTHON_HOME", "C:\Python311", "Machine")

    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $requiredPaths = @("C:\spark\bin", "C:\Python311", "C:\Python311\Scripts")
    foreach ($path in $requiredPaths) {
        if ($currentPath -notlike "*$path*") { $currentPath += ";$path" }
    }
    [System.Environment]::SetEnvironmentVariable("Path", $currentPath, "Machine")
    Write-Host "✔ Machine-level environment variables set."

    # === Refresh session environment variables ===
    Write-Host "Refreshing session environment variables..."
    $env:SPARK_HOME = "C:\spark"
    $env:PYSPARK_PYTHON = "C:\Python311\python.exe"
    $env:PYTHON_HOME = "C:\Python311"
    $env:PATH = $env:PATH + ";C:\spark\bin;C:\Python311;C:\Python311\Scripts"

    # === Create virtual environment ===
    if (-not (Test-Path "pyspark_env")) {
        Write-Host "Creating virtual environment..."
        C:\Python311\python.exe -m venv pyspark_env
    }

    # === Activate virtual environment in-script ===
    Write-Host "Activating virtual environment in this session..."
    .\pyspark_env\Scripts\Activate.ps1

    # === Install dependencies within virtual environment ===
    Write-Host "Installing dependencies in virtual environment..."
    pip install --upgrade pip
    pip install pyspark pandas jupyter

    Write-Host "`n✅ PySpark pool setup complete and activated in current session." -ForegroundColor Green
    Write-Host "You can now run 'pyspark' or 'spark-submit your_job.py' directly."
}

function Uninstall-PySpark {
    Write-Host "`n==> Uninstalling PySpark Environment..." -ForegroundColor Yellow
    if (Test-Path "pyspark_env") {
        Remove-Item -Recurse -Force "pyspark_env"
        Write-Host "✔ Virtual environment removed."
    }
    $sparkPath = "C:\spark"
    if (Test-Path $sparkPath) {
        Remove-Item -Recurse -Force $sparkPath
        Write-Host "✔ Apache Spark directory removed."
    }
    Write-Host "ℹ️ Machine-level environment variables remain. You can manually remove SPARK_HOME and PYTHON_HOME if desired."
    Write-Host "🧹 Uninstallation complete." -ForegroundColor Green
}

# === Menu ===
Write-Host "`n=============================="
Write-Host "     PySpark Pool Manager"
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
