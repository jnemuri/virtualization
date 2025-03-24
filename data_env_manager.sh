#!/bin/bash
set -e  # Exit script on error

install_data_env() {
    echo "Setting up on-demand PySpark environment..."

    # Ensure Python is installed
    if ! command -v python3 &>/dev/null; then
        echo "Python is not installed. Please install Python first."
        exit 1
    fi

    # Check and install Apache Spark via Homebrew if needed
    if ! command -v spark-shell &>/dev/null; then
        echo "Apache Spark is not installed. Installing Apache Spark via Homebrew..."
        brew install apache-spark
    else
        echo "Apache Spark is already installed."
    fi

    # Set SPARK_HOME using Homebrew's prefix
    SPARK_PREFIX=$(brew --prefix apache-spark 2>/dev/null)
    if [ -n "$SPARK_PREFIX" ] && [ -d "$SPARK_PREFIX/libexec" ]; then
        echo "Updating SPARK_HOME to ${SPARK_PREFIX}/libexec"
        echo "export SPARK_HOME=${SPARK_PREFIX}/libexec" >> ~/.zshrc
        echo "export PATH=\$SPARK_HOME/bin:\$PATH" >> ~/.zshrc
        echo "export PYSPARK_PYTHON=python3" >> ~/.zshrc
        source ~/.zshrc
    else
        echo "Error: Apache Spark is not installed via Homebrew."
        exit 1
    fi

    # Create the virtual environment if it doesn't exist
    if [ ! -d "pyspark_env" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv pyspark_env
    fi

    # Activate the virtual environment
    echo "Activating virtual environment..."
    source pyspark_env/bin/activate

    # Upgrade pip and install dependencies
    echo "Installing required Python packages..."
    pip install --upgrade pip

    if ! pip list | grep -q "pyspark"; then
        echo "Installing PySpark..."
        pip install pyspark
    else
        echo "PySpark is already installed."
    fi

    if ! pip list | grep -q "pandas"; then
        echo "Installing Pandas..."
        pip install pandas
    else
        echo "Pandas is already installed."
    fi

    if ! pip list | grep -q "notebook"; then
        echo "Installing Jupyter Notebook..."
        pip install notebook ipykernel
        python -m ipykernel install --user --name=pyspark_env --display-name "Python (pyspark_env)"
    else
        echo "Jupyter Notebook is already installed."
    fi

    if ! pip list | grep -q "azure-functions"; then
        echo "Installing Azure Functions package..."
        pip install azure-functions
    else
        echo "Azure Functions package is already installed."
    fi

    # Check and install Node.js if not installed (for JupyterLab build status)
    if ! command -v node &>/dev/null; then
        echo "Node.js not found. Installing Node.js via Homebrew..."
        brew install node
    else
        echo "Node.js is already installed."
    fi

    echo "PySpark environment setup complete."
    echo "The virtual environment 'pyspark_env' is now activated."
    echo "You can now run PySpark commands or start Jupyter Notebook."

    # Keep the virtual environment active
    exec bash --rcfile <(echo "source pyspark_env/bin/activate")
}

uninstall_data_env() {
    echo "Removing PySpark environment..."
    
    # Deactivate the virtual environment if active
    deactivate 2>/dev/null || true

    if [ -d "pyspark_env" ]; then
        echo "Removing virtual environment directory..."
        rm -rf pyspark_env
        # Wait until the directory is fully removed
        while [ -d "pyspark_env" ]; do
            echo "Waiting for virtual environment to be removed..."
            sleep 1
        done
        echo "Virtual environment removed."
    else
        echo "Virtual environment not found. Skipping removal."
    fi

    echo "Cleanup complete."
}

# Always activate the virtual environment if it exists
if [ -d "pyspark_env" ]; then
    echo "Activating PySpark environment..."
    source pyspark_env/bin/activate
else
    echo "No virtual environment found. Run this script and choose option 1 to install it."
fi

# Menu System
echo "Data Environment Manager"
echo "1) Install Environment (PySpark, Pandas, Jupyter Notebook, Azure Functions, Node.js)"
echo "2) Remove Environment"
echo "3) Exit"

read -p "Choose an option (1-3): " option

case $option in
    1) install_data_env ;;
    2) uninstall_data_env ;;
    3) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option. Exiting..." ;;
esacj