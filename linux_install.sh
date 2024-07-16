#!/bin/bash

# Get the absolute directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Script running from $SCRIPT_DIR"

# Function to create symlinks and backup existing files
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    echo "Checking target: $target_file"

    # Check if the target file already exists
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        local backup_file="$target_file.bak"
        # Check if a backup file already exists and remove it
        if [ -e "$backup_file" ] || [ -L "$backup_file" ]; then
            echo "Removing old backup $backup_file"
            rm -f "$backup_file"
        fi

        # Backup the existing file
        echo "Backing up existing $target_file to $target_file.bak"
        mv "$target_file" "$target_file.bak"
    else
        echo "$target_file does not exist or is not accesible."
    fi

    # Create the symlink
    echo "Creating symlink for $source_file"
    ln -s "$source_file" "$target_file"
}

# Create symlinks for dotfiles, assuming the dotfiles are in the same directory as the script
create_symlink "$SCRIPT_DIR/.gitconfig" ~/.gitconfig
create_symlink "$SCRIPT_DIR/.bash_profile" ~/.bash_profile
create_symlink "$SCRIPT_DIR/.bashrc" ~/.bashrc
create_symlink "$SCRIPT_DIR/.bash_logout" ~/.bash_logout

# Reload .bashrc to apply changes (only affects the current terminal session)
echo "Reloading .bashrc to apply changes"
source ~/.bashrc