# Virtualization Environment Setup

This script helps you manage a Python virtual environment for your development needs. It provides options to install or uninstall the environment and ensures that required dependencies are installed.

## Prerequisites

Ensure the following are installed on your system before running the script:

- **Java**: Required for certain dependencies.
- **Python**: Ensure Python is installed and added to your system's PATH.

## Usage

1. Clone this repository and navigate to the directory containing the script.
2. Open a PowerShell terminal and run the script.

### Script Features

#### Check for Required Software

The script verifies if `java` and `python` are installed. If either is missing, it will prompt you to install them before proceeding.

#### Directory Validation

The script ensures it is executed from the directory where it is located. If not, it will prompt you to navigate to the correct directory.

#### Install Environment

The `Install-Environment` function performs the following steps:
- Creates a Python virtual environment (`venv`).
- Activates the virtual environment.
- Installs dependencies from the `requirements.txt` file.

#### Uninstall Environment

The `Uninstall-Environment` function:
- Deactivates the virtual environment if active.
- Stops any processes using the virtual environment.
- Removes the `venv` folder.

#### User Menu

The script provides a menu with the following options:
1. **Install Environment**: Sets up the virtual environment.
2. **Uninstall Environment**: Removes the virtual environment.
3. **Exit**: Exits the script.

### Example Usage

Run the script in PowerShell:

```powershell
.\YourScriptName.ps1
```

Follow the on-screen prompts to choose an action.

## Notes

- Ensure you have the necessary permissions to create and delete files in the directory.
- If you encounter issues, check the error messages for guidance.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
