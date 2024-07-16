#!/bin/bash

# Get the directory of the script
SCRIPT_DIR=$(dirname "$0")

# Create symlinks for dotfiles, assuming the dotfiles are in the same directory as the script
ln -s "$SCRIPT_DIR/.bash_profile" ~/.bash_profile
ln -s "$SCRIPT_DIR/.gitconfig" ~/.gitconfig
ln -s "$SCRIPT_DIR/.bashrc" ~/.bashrc
