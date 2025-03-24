# data_env_manager.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Install-DataEnv {
    Write-Host "Setting up on-demand PySpark environment..."

    # Check if Python is installed
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Python is not installed. Please install Python first."
        exit 1
    }

    # Check and install Apache Spark if not present
    if (-not (Test-Path "C:\spark")) {
        Write-Host "Apache Spark not found at C:\spark."
        Write-Host "Please install Apache Spark manually in C:\spark or update this script with your Spark installation path."
        exit 1
    }
    else {
        Write-Host "Apache Spark is installed at C:\spark."
    }

    # Set SPARK_HOME environment variable (for current session and persist for user)
    $sparkHome = "C:\spark"
    Write-Host "Setting SPARK_HOME to $sparkHome"
    $env:SPARK_HOME = $sparkHome
    $env:PATH = "$env:SPARK_HOME\bin;$env:PATH"
    $env:PYSPARK_PYTHON = "python"
    [System.Environment]::SetEnvironmentVariable("SPARK_HOME", $sparkHome, "User")
    [System.Environment]::SetEnvironmentVariable("PATH", "$env:SPARK_HOME\bin;$env:PATH", "User")
    [System.Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", "python", "User")

    # Check and install Node.js via winget if needed
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Host "Node.js not found. Installing Node.js via winget..."
        try {
            winget install --id OpenJS.NodeJS -e --silent
        } catch {
            Write-Host "Automatic installation of Node.js failed. Please install Node.js manually."
        }
    } else {
        Write-Host "Node.js is already installed."
    }

    # Create the virtual environment if it doesn't exist
    if (-not (Test-Path "pyspark_env")) {
        Write-Host "Creating Python virtual environment 'pyspark_env'..."
        python -m venv pyspark_env
    } else {
        Write-Host "Virtual environment 'pyspark_env' already exists."
    }

    # Activate the virtual environment
    Write-Host "Activating virtual environment..."
    .\pyspark_env\Scripts\Activate.ps1

    Write-Host "Upgrading pip and installing required packages..."
    pip install --upgrade pip

    if (-not (pip list | Select-String "pyspark")) {
        Write-Host "Installing PySpark..."
        pip install pyspark
    } else {
        Write-Host "PySpark is already installed."
    }

    if (-not (pip list | Select-String "pandas")) {
        Write-Host "Installing Pandas..."
        pip install pandas
    } else {
        Write-Host "Pandas is already installed."
    }

    if (-not (pip list | Select-String "notebook")) {
        Write-Host "Installing Jupyter Notebook and ipykernel..."
        pip install notebook ipykernel
        python -m ipykernel install --user --name pyspark_env --display-name "Python (pyspark_env)"
    } else {
        Write-Host "Jupyter Notebook is already installed."
    }

    if (-not (pip list | Select-String "azure-functions")) {
        Write-Host "Installing Azure Functions package..."
        pip install azure-functions
    } else {
        Write-Host "Azure Functions package is already installed."
    }

    Write-Host "PySpark environment setup complete."
    Write-Host "The virtual environment 'pyspark_env' is now activated."
    Write-Host "You can now run PySpark commands or start Jupyter Notebook."
}

function Uninstall-DataEnv {
    Write-Host "Removing PySpark environment..."

    # Deactivate virtual environment if active
    if ($env:VIRTUAL_ENV) {
        Write-Host "Deactivating virtual environment..."
        deactivate
    }

    # Remove the virtual environment directory and wait until removal is complete
    if (Test-Path "pyspark_env") {
        Write-Host "Removing virtual environment directory 'pyspark_env'..."
        Remove-Item -Recurse -Force "pyspark_env"
        while (Test-Path "pyspark_env") {
            Write-Host "Waiting for virtual environment to be removed..."
            Start-Sleep -Seconds 1
        }
        Write-Host "Virtual environment removed."
    }
    else {
        Write-Host "Virtual environment not found. Skipping removal."
    }

    Write-Host "Cleanup complete."
}

# If virtual environment exists, activate it
if (Test-Path "pyspark_env") {
    Write-Host "Activating PySpark environment..."
    .\pyspark_env\Scripts\Activate.ps1
} else {
    Write-Host "No virtual environment found. Run this script and choose option 1 to install it."
}

# Menu System
Write-Host "Data Environment Manager"
Write-Host "1) Install Environment (PySpark, Pandas, Jupyter Notebook, Azure Functions, Node.js)"
Write-Host "2) Remove Environment"
Write-Host "3) Exit"

$option = Read-Host "Choose an option (1-3):"

switch ($option) {
    "1" { Install-DataEnv }
    "2" { Uninstall-DataEnv }
    "3" { Write-Host "Exiting..."; exit 0 }
    default { Write-Host "Invalid option. Exiting..." }
}