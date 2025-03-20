#!/bin/bash

# This script is a PySpark environment manager that allows users to install and uninstall PySpark and its dependencies.
# It provides a menu system with options to install PySpark, uninstall PySpark, or exit the script.
# The script detects the operating system and performs the necessary installation steps based on the detected OS.
# For macOS, it installs Homebrew, Python, and Apache Spark using Homebrew, and sets up environment variables.
# It also creates a Python virtual environment and installs PySpark inside the virtual environment.
# The script can be executed by running the shell script file and selecting the desired option from the menu.
# The script uses the `source` command to activate and deactivate the virtual environment when necessary.
# It also provides feedback messages during the installation and uninstallation processes.

set -e  # Exit script on error

# Detect OS
OS=$(uname)
IsMac=false
IsWindows=false

if [[ "$OS" == "Darwin" ]]; then
    IsMac=true
elif [[ "$OS" == "CYGWIN" || "$OS" == "MINGW" || "$OS" == "MSYS" ]]; then
    IsWindows=true
fi

# Function to install PySpark
install_pyspark() {
    echo "Installing PySpark..."

    if [[ "$IsMac" == true ]]; then
        echo "Detected macOS"

        # Install Homebrew if missing
        if ! command -v brew &>/dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "Homebrew is already installed."
        fi

        # Install Python
        if ! command -v python3 &>/dev/null; then
            echo "Installing Python..."
            brew install python
        else
            echo "Python is already installed."
        fi

        # Install Apache Spark
        if ! command -v spark-shell &>/dev/null; then
            echo "Installing Apache Spark..."
            brew install apache-spark
        else
            echo "Apache Spark is already installed."
        fi

        # Set Environment Variables
        echo 'export SPARK_HOME=/opt/homebrew/Cellar/apache-spark/3.4.1/libexec' >> ~/.zshrc
        echo 'export PATH=$SPARK_HOME/bin:$PATH' >> ~/.zshrc
        echo 'export PYSPARK_PYTHON=python3' >> ~/.zshrc
        source ~/.zshrc
    fi

    # Set up virtual environment
    if [ ! -d "pyspark_env" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv pyspark_env
    fi

    # Activate the virtual environment
    source pyspark_env/bin/activate

    # Ensure PySpark is installed inside the virtual environment
    if ! pip list | grep -q pyspark; then
        echo "Installing PySpark..."
        pip install pyspark
    else
        echo "PySpark is already installed."
    fi

    deactivate
    echo "Installation complete!"
}

# Function to uninstall PySpark
uninstall_pyspark() {
    echo "Uninstalling PySpark and dependencies..."

    # Remove the virtual environment
    if [ -d "pyspark_env" ]; then
        rm -rf pyspark_env
        echo "Virtual environment removed."
    fi

    if [[ "$IsMac" == true ]]; then
        brew uninstall apache-spark
        echo "Apache Spark removed."
    fi

    echo "Uninstallation complete!"
}

# Menu System
echo "PySpark Environment Manager"
echo "1) Install PySpark Environment"
echo "2) Uninstall PySpark Environment"
echo "3) Exit"

read -p "Choose an option (1-4): " option

case $option in
    1) install_pyspark ;;
    2) uninstall_pyspark ;;
    3) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option. Exiting..." ;;
esac