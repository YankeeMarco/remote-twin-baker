#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [--python-version VERSION]"
    echo "  --python-version: Override Python version (must satisfy requires-python)"
    exit 1
}

# Parse command-line arguments
PYTHON_VERSION=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --python-version) PYTHON_VERSION="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Check if pyproject.toml exists
if [[ ! -f "pyproject.toml" ]]; then
    echo "Error: pyproject.toml not found in current directory."
    exit 1
fi

# Extract requires-python from pyproject.toml
REQUIRED_PYTHON=$(grep "requires-python" pyproject.toml | sed -E 's/.*>=([0-9.]+).*/\1/')
if [[ -z "$REQUIRED_PYTHON" ]]; then
    echo "Error: Could not find requires-python in pyproject.toml."
    exit 1
fi
echo "Found requires-python: >=$REQUIRED_PYTHON"

# If no Python version specified, default to latest compatible version
if [[ -z "$PYTHON_VERSION" ]]; then
    # Default to latest 3.11.x for >=3.11 (adjust based on requires-python)
    if [[ "$(printf '%s\n' "3.11" "$REQUIRED_PYTHON" | sort -V | head -n1)" == "$REQUIRED_PYTHON" ]]; then
        PYTHON_VERSION="3.11.9"  # Latest 3.11.x as of 2025
    else
        echo "Error: No default Python version defined for requires-python >=$REQUIRED_PYTHON."
        echo "Please specify a compatible version with --python-version."
        exit 1
    fi
fi

# Validate Python version against requires-python
if [[ "$(printf '%s\n' "$PYTHON_VERSION" "$REQUIRED_PYTHON" | sort -V | head -n1)" != "$REQUIRED_PYTHON" ]]; then
    echo "Error: Python $PYTHON_VERSION does not satisfy requires-python >=$REQUIRED_PYTHON."
    exit 1
fi

# Extract optional dependency groups from pyproject.toml
OPTIONAL_GROUPS=$(grep '\[tool.poetry.group\.' pyproject.toml | sed -E 's/.*\[tool\.poetry\.group\.([a-zA-Z0-9_-]+)\.dependencies\].*/\1/' | sort -u)
if [[ -z "$OPTIONAL_GROUPS" ]]; then
    echo "No optional dependency groups found in pyproject.toml. Installing core dependencies only."
fi

# Prompt user for each optional dependency group
SELECTED_GROUPS=()
for group in $OPTIONAL_GROUPS; do
    read -p "Include optional dependency group '$group'? (y/n, default: n): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        SELECTED_GROUPS+=("$group")
    fi
done

# Build poetry install command
INSTALL_CMD="poetry install"
if [[ ${#SELECTED_GROUPS[@]} -gt 0 ]]; then
    INSTALL_CMD="$INSTALL_CMD --with $(IFS=,; echo "${SELECTED_GROUPS[*]}")"
fi

# Check if pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Install Python version if not already installed
if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
    echo "Installing Python $PYTHON_VERSION..."
    pyenv install "$PYTHON_VERSION"
fi

# Set local Python version
pyenv local "$PYTHON_VERSION"

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo "Installing poetry..."
    pip install poetry
fi

# Configure poetry to use pyenv's Python
poetry config virtualenvs.prefer-active-python true

# Configure poetry to store virtualenv in project directory
poetry config virtualenvs.in-project true

# Create virtual environment and install dependencies
echo "Setting up virtual environment with Python $PYTHON_VERSION..."
poetry env use "$PYTHON_VERSION"

echo "Installing dependencies: $INSTALL_CMD"
bash -c "$INSTALL_CMD"

# Check if ipython is installed (for dev group)
if [[ " ${SELECTED_GROUPS[@]} " =~ " dev " && -z $(poetry run pip list | grep ipython) ]]; then
    echo "Installing ipython for development environment..."
    poetry add --group dev ipython
    bash -c "$INSTALL_CMD"  # Re-run to ensure ipython is included
fi

echo "Environment setup complete!"
if [[ " ${SELECTED_GROUPS[@]} " =~ " dev " ]]; then
    echo "To start ipython, run: 'poetry run ipython'"
    echo "Or activate the virtual environment: 'poetry shell' and then 'ipython'"
fi
echo "To run your script, use: 'poetry run python your_script.py'"
echo "Virtual environment is located in: $(poetry env info --path)"