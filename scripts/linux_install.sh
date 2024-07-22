#!/bin/bash

# [Linux]

# Manual
# 	Clone dotfiles repo

# Script should do:

# 	Install zsh
# 	Set zsh as default shell for profile
# 	Install config dependencies (fzf, neofetch, zoxide)
# 	Install Oh My Posh (or any other terminal prompts if changed in the future)
# 	Create symlinks for the config files (gitconfig, zshrc)
# 	Create ssh key with ed25519 algorithm ssh-keygen -t ed25519 -C "your_email@example.com"
# 	Add that ssh key to ssh-agent
# 	Let user know they need to add the key to their github account

# Manual
# 	Add public key to github both on auth and sign

# Environment setup Script:

# 	Update apt and apt-get repositories
# 	Install nvm
# 		Install node current LTS
# 	Install docker ce




# Get the absolute directory of the script
SCRIPT_DIR=$(dirname "$(dirname "$(readlink -f "$0")")")/config

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
create_symlink "$SCRIPT_DIR/.zshrc" ~/.zshrc

echo "Symlinks created successfully"