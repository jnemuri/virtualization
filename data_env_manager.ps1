Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check for Python command; assume Python must be installed globally.
if ((Get-Command python -ErrorAction SilentlyContinue) -eq $null -and (Get-Command python3 -ErrorAction SilentlyContinue) -eq $null) {
    Write-Host "Python is not installed. Please install Python globally first."
    exit 1
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} else {
    $pythonCmd = "python3"
}
Write-Host "Using Python command: $pythonCmd"

function Install-DataEnv {
    Write-Host "Setting up virtual environment and installing packages..."

    # Create the virtual environment if it doesn't exist
    if (-not (Test-Path "pyspark_env")) {
        Write-Host "Creating virtual environment 'pyspark_env'..."
        & $pythonCmd -m venv pyspark_env
    } else {
        Write-Host "Virtual environment 'pyspark_env' already exists."
    }

    # Activate the virtual environment
    Write-Host "Activating virtual environment..."
    .\pyspark_env\Scripts\Activate.ps1

    Write-Host "Upgrading pip..."
    pip install --upgrade pip

    Write-Host "Installing PySpark..."
    pip install pyspark

    Write-Host "Installing Pandas..."
    pip install pandas

    Write-Host "Installing Jupyter Notebook and ipykernel..."
    pip install notebook ipykernel
    & $pythonCmd -m ipykernel install --user --name pyspark_env --display-name "Python (pyspark_env)"

    Write-Host "Installing Azure Functions package..."
    pip install azure-functions

    Write-Host "Virtual environment setup complete."
    Write-Host "The virtual environment 'pyspark_env' is now activated."
    Write-Host "You can run 'pyspark' or 'jupyter notebook' from this environment."
}

function Uninstall-DataEnv {
    Write-Host "Removing virtual environment 'pyspark_env'..."

    # Deactivate the virtual environment if active
    try {
        deactivate
    } catch {
        Write-Host "Virtual environment not active."
    }

    # Remove the virtual environment directory and wait until it is fully removed
    if (Test-Path "pyspark_env") {
        Write-Host "Removing virtual environment directory..."
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

# If the virtual environment exists, optionally activate it
if (Test-Path "pyspark_env") {
    Write-Host "Activating virtual environment 'pyspark_env'..."
    .\pyspark_env\Scripts\Activate.ps1
} else {
    Write-Host "No virtual environment found. Choose option 1 to install it."
}

Write-Host "Data Environment Manager"
Write-Host "1) Install Environment (PySpark, Pandas, Jupyter Notebook, Azure Functions)"
Write-Host "2) Remove Environment"
Write-Host "3) Exit"

$option = Read-Host "Choose an option (1-3):"

switch ($option) {
    "1" { Install-DataEnv }
    "2" { Uninstall-DataEnv }
    "3" { Write-Host "Exiting..."; exit 0 }
    default { Write-Host "Invalid option. Exiting..." }
}
