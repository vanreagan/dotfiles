Write-Host "Starting Windows Setup..."

Write-Host "Installing New Microsoft PowerShell"


# # Install PowerShell
# winget install --id Microsoft.Powershell --source winget

# Check if PowerShell is already installed and update if necessary
$psInstalled = winget list --id Microsoft.Powershell
if ($psInstalled -match "Microsoft.Powershell") {
    Write-Host "PowerShell is already installed. Checking for updates..."
    winget upgrade --id Microsoft.Powershell --source winget
} else {
    Write-Host "Installing New Microsoft PowerShell"
    winget install --id Microsoft.Powershell --source winget
}

# Download Nerd Font
$nerdFontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip"
$fontZipPath = "$env:USERPROFILE\Downloads\Hack.zip"
$fontExtractPath = "$env:USERPROFILE\Downloads\Hack"

Write-Host "Downloading Nerd Font..."
Invoke-WebRequest -Uri $nerdFontUrl -OutFile $fontZipPath

# Extract Nerd Font
Write-Host "Extracting Nerd Font..."
Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath

# Install Nerd Font
Write-Host "Installing Nerd Font..."
$fontFiles = Get-ChildItem -Path $fontExtractPath -Filter *.ttf
foreach ($fontFile in $fontFiles) {
    Copy-Item -Path $fontFile.FullName -Destination "$env:SystemRoot\Fonts"
    $fontRegKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontRegValueName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile.Name)
    $fontRegValue = $fontFile.Name
    Set-ItemProperty -Path $fontRegKey -Name $fontRegValueName -Value $fontRegValue
}

Write-Host "Nerd Font installation complete."

# Clean up
Write-Host "Cleaning up..."
Remove-Item -Path $fontZipPath
Remove-Item -Path $fontExtractPath -Recurse


# Create symlink for Windows Terminal settings.json
Write-Host "Creating symlink for Windows Terminal settings.json..."

# Get the parent directory of the script
$parent = Split-Path $script:MyInvocation.MyCommand.Path

# Check if a username is provided as a command-line argument
if ($args.Count -eq 0) {
    # Prompt the user for a username
    $USERNAME = Read-Host "Enter the username for installation (press Enter for current user)"
    if (-not $USERNAME) {
        $USER_LOCALAPPDATA = $env:LOCALAPPDATA
    } else {
        # Assuming C:\Users as the user directory
        $USER_LOCALAPPDATA = "C:\Users\$USERNAME\AppData\Local"
    }
} else {
    # Use the provided command-line argument as the username
    $USER_LOCALAPPDATA = "C:\Users\$($args[0])\AppData\Local"
}

$SOURCE_PATH = Join-Path $parent "config\settings.json"
$TARGET_PATH = Join-Path $USER_LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Main
# Delete the existing settings.json if it exists to avoid conflict
if (Test-Path $TARGET_PATH) {
    Remove-Item $TARGET_PATH
}

# Create a symbolic link to the settings.json file
New-Item -ItemType SymbolicLink -Path $TARGET_PATH -Target $SOURCE_PATH


# Check if VS Code is already installed and update if necessary
$vscInstalled = winget list --id Microsoft.Powershell
if ($vscInstalled -match "Microsoft.Powershell") {
    Write-Host "VS Code is already installed. Checking for updates..."
    winget upgrade --id Microsoft.VisualStudioCode --source winget
} else {
    Write-Host "Installing Visual Studio Code"
    winget install -e --id Microsoft.VisualStudioCode --source winget
}

# Install WSL2
# Check if WSL is already installed by listing installed distributions
$wslDistributions = wsl --list --quiet
if ($wslDistributions) {
    Write-Host "WSL is already installed. Installed distributions:"
    Write-Host $wslDistributions
} else {
    Write-Host "Installing WSL2..."
    wsl --install
}