param (
    [string]$scriptPath = "./pyspark_script.py"
)

# Set environment variables
$env:SPARK_HOME="/opt/homebrew/Cellar/apache-spark/3.4.1/libexec"
$env:PYSPARK_PYTHON="python3"
$env:PATH += ":$env:SPARK_HOME/bin"

# Check if the script exists
if (-Not (Test-Path $scriptPath)) {
    Write-Host "Error: PySpark script not found: $scriptPath"
    exit 1
}

# Run the PySpark script
Write-Host "Running PySpark script..."
python3 $scriptPath

Write-Host "PySpark execution complete."