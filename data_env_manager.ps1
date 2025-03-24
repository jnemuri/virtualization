Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check for Python command; if not found, install via winget.
if ((Get-Command python -ErrorAction SilentlyContinue) -eq $null -and (Get-Command python3 -ErrorAction SilentlyContinue) -eq $null) {
    Write-Host "Python is not installed. Installing Python via winget..."
    try {
        winget install --id Python.Python.3 --silent --accept-package-agreements --accept-source-agreements
    } catch {
        Write-Host "Automatic installation of Python failed. Please install Python manually."
        exit 1
    }
    # Wait for installation to complete
    Start-Sleep -Seconds 10
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    $pythonCmd = "python3"
} else {
    Write-Host "Python installation failed. Please install Python manually."
    exit 1
}
Write-Host "Using Python command: $pythonCmd"

function Install-DataEnv {
    Write-Host "Setting up on-demand PySpark environment..."

    # Check for Apache Spark installation at C:\spark
    if (-not (Test-Path "C:\spark")) {
        Write-Host "Apache Spark not found at C:\spark."
        Write-Host "Please install Apache Spark manually in C:\spark or update this script with your Spark installation path."
        exit 1
    } else {
        Write-Host "Apache Spark is installed at C:\spark."
    }

    # Set SPARK_HOME and update PATH for the current session and persist for the user
    $sparkHome = "C:\spark"
    Write-Host "Setting SPARK_HOME to $sparkHome"
    $env:SPARK_HOME = $sparkHome
    $env:PATH = "$env:SPARK_HOME\bin;$env:PATH"
    $env:PYSPARK_PYTHON = $pythonCmd
    [System.Environment]::SetEnvironmentVariable("SPARK_HOME", $sparkHome, "User")
    [System.Environment]::SetEnvironmentVariable("PATH", "$env:SPARK_HOME\bin;$env:PATH", "User")
    [System.Environment]::SetEnvironmentVariable("PYSPARK_PYTHON", $pythonCmd, "User")

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
        & $pythonCmd -m venv pyspark_env
    } else {
        Write-Host "Virtual environment 'pyspark_env' already exists."
    }

    # Activate the virtual environment
    Write-Host "Activating virtual environment..."
    .\pyspark_env\Scripts\Activate.ps1

    Write-Host "Upgrading pip..."
    pip install --upgrade pip

    # Install PySpark
    if (-not (pip list | Select-String "pyspark")) {
        Write-Host "Installing PySpark..."
        pip install pyspark
    } else {
        Write-Host "PySpark is already installed."
    }

    # Install Pandas
    if (-not (pip list | Select-String "pandas")) {
        Write-Host "Installing Pandas..."
        pip install pandas
    } else {
        Write-Host "Pandas is already installed."
    }

    # Install Jupyter Notebook and ipykernel
    if (-not (pip list | Select-String "notebook")) {
        Write-Host "Installing Jupyter Notebook and ipykernel..."
        pip install notebook ipykernel
        & $pythonCmd -m ipykernel install --user --name pyspark_env --display-name "Python (pyspark_env)"
    } else {
        Write-Host "Jupyter Notebook is already installed."
    }

    # Install Azure Functions package
    if (-not (pip list | Select-String "azure-functions")) {
        Write-Host "Installing Azure Functions package..."
        pip install azure-functions
    } else {
        Write-Host "Azure Functions package is already installed."
    }

    Write-Host "PySpark environment setup complete."
    Write-Host "The virtual environment 'pyspark_env' is now activated."
    Write-Host "You can now run PySpark commands or start Jupyter Notebook."

    # Keep the virtual environment active after installation.
    # Note: On Windows, we can simply return control to the user.
}

function Uninstall-DataEnv {
    Write-Host "Removing PySpark environment..."

    # Deactivate the virtual environment if active
    try {
        deactivate
    } catch {
        Write-Host "Virtual environment not active."
    }

    # Remove the virtual environment directory and wait until it is fully removed
    if (Test-Path "pyspark_env") {
        Write-Host "Removing virtual environment directory 'pyspark_env'..."
        Remove-Item -Recurse -Force "pyspark_env"
        while (Test-Path "pyspark_env") {
            Write-Host "Waiting for virtual environment to be removed..."
            Start-Sleep -Seconds 1
        }
        Write-Host "Virtual environment removed."
    } else {
        Write-Host "Virtual environment not found. Skipping removal."
    }

    Write-Host "Cleanup complete."
}

# If the virtual environment exists, activate it
if (Test-Path "pyspark_env") {
    Write-Host "Activating PySpark environment..."
    .\pyspark_env\Scripts\Activate.ps1
} else {
    Write-Host "No virtual environment found. Run this script and choose option 1 to install it."
}

# Menu System
Write-Host "Data Environment Manager"
Write-Host "1) Install Environment (PySpark, Pandas, Jupyter Notebook, Azure Functions, Node.js, Python)"
Write-Host "2) Remove Environment"
Write-Host "3) Exit"

$option = Read-Host "Choose an option (1-3):"

switch ($option) {
    "1" { Install-DataEnv }
    "2" { Uninstall-DataEnv }
    "3" { Write-Host "Exiting..."; exit 0 }
    default { Write-Host "Invalid option. Exiting..." }
}