#!/bin/bash

# Set variables
INSTALL_DIR="$HOME/miniconda3"
INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
TMP_DIR="$HOME/tmp"
BASHRC="$HOME/.bashrc"
BASH_PROFILE="$HOME/.bash_profile"

# Create temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1

# Download Miniconda installer
if wget -q "$INSTALLER_URL" -O Miniconda3-latest-Linux-x86_64.sh; then
    echo "Miniconda installer downloaded successfully."
else
    echo "Failed to download Miniconda installer. Exiting."
    exit 1
fi

# Check if Miniconda is already installed
if [ -d "$INSTALL_DIR" ]; then
    echo "Miniconda is already installed at $INSTALL_DIR."
    while true; do
        read -p "Do you want to update the existing installation? (y/n/skip): " CHOICE
        case "$CHOICE" in
            [Yy]* )
                echo "Updating Miniconda..."
                if bash Miniconda3-latest-Linux-x86_64.sh -u -b -p "$INSTALL_DIR"; then
                    echo "Miniconda updated successfully."
                else
                    echo "Failed to update Miniconda. Exiting."
                    exit 1
                fi
                break
                ;;
            [Nn]* )
                echo "Update canceled. Exiting script."
                exit 1
                ;;
            [Ss]* | skip )
                echo "Skipping Miniconda update."
                break
                ;;
            * )
                echo "Invalid choice. Please enter 'y', 'n', or 'skip'."
                ;;
        esac
    done
else
    # Run Miniconda installer in batch mode
    if bash Miniconda3-latest-Linux-x86_64.sh -b -p "$INSTALL_DIR"; then
        echo "Miniconda installed successfully."
    else
        echo "Miniconda installation failed. Exiting."
        exit 1
    fi
fi

# Update PATH in .bashrc
if ! grep -q "miniconda3/bin" "$BASHRC"; then
    echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> "$BASHRC"
    echo "Updated PATH in $BASHRC."
fi

# Ensure .bashrc is sourced in .bash_profile
if [ ! -f "$BASH_PROFILE" ] || ! grep -q ".bashrc" "$BASH_PROFILE"; then
    echo -e 'if [ -f ~/.bashrc ]; then\n    . ~/.bashrc\nfi' > "$BASH_PROFILE"
    echo "Created $BASH_PROFILE and added sourcing for .bashrc."
fi

# Source .bashrc to load conda into the current shell session
source "$BASHRC"

# Prompt user for installing htop
read -p "Do you want to install htop from conda-forge? (y/n): " INSTALL_HTOP
if [[ "$INSTALL_HTOP" =~ ^[Yy]$ ]]; then
    if "$HOME/miniconda3/bin/conda" install -y -c conda-forge htop; then
        echo "htop installed successfully via conda-forge."
    else
        echo "Failed to install htop via conda-forge."
    fi
else
    echo "Skipping htop installation."
fi

# Cleanup
rm -f Miniconda3-latest-Linux-x86_64.sh
echo "Temporary installer removed."

echo "Script completed successfully."
