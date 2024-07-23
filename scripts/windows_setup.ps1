# [Windows]

# Manual
# 	Install winget in case it isn't already
# 	Install Git
# 	Clone dotfiles repo

# Script should do:

# 	Install Windows Terminal X
# 	Install New Powershell X
# 	Install WSL2 X
# 	Install Nerdfont X
# 	Install VSCode X
# 	Create symlink for Windows Terminal settings.json X
# 	Create symlinks for gitconfig X

# TODO: Create a function for the symlink bs
# TODO: Actually test the winget stuff
# TODO: Write a loop which installs/checks for updates for all the programs in an array of strings
# TODO: Check for winget presence and install it if it isn't there
# TODO: Check for git presence and install it if it isn't there
# TODO: Modify nerdfont installation function to take the userpath or something

# * Functions

function CheckWingetInstallation {
	param(
		[string]$programId
	)

	$installed = winget --list --id $programId
	if ($installed -match $programId) {
		Write-Host "$programId is already installed. Checking for updates..."
		winget upgrade --id $programId --source winget
	} else {
		Write-Host "Installing $programId"
		winget install --id $programId --source winget
	}
}

function InstallNerdFont {
	param(
		[string]$nerdFontName,
		[string]$nerdFontVersion
	)

	$nerdFontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$nerdFontVersion/$nerdFontName.zip"
	$fontZipPath = "$env:USERPROFILE\Downloads\$nerdFontName.zip"
	$fontExtractPath = "$env:USERPROFILE\Downloads\$nerdFontName"

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
}

function GetUser {
	$validUser = $false
	$currentUser = [Environment]::UserName
	do {
			$username = Read-Host "Enter the username for installation (press Enter for current user: $currentUser)"
			if (-not $username) {
					# If the user presses Enter, use the current user
					$username = $currentUser
					$validUser = $true
			} else {
					# Check if the user exists
					try {
							$userExists = Get-CimInstance -ClassName Win32_UserAccount | Where-Object { $_.Name -eq $username }
							if ($userExists) {
									$validUser = $true
							} else {
									Write-Host "User '$username' does not exist. Please try again."
							}
					} catch {
							Write-Host "An error occurred while checking for the user. Please try again."
					}
			}
	} while (-not $validUser)
	return $username
}

# * Main Script

# Use the function to get a valid username
$username = GetUser

# Set the local appdata directory for the selected user.
$userLocalAppData = "C:\Users\$username\AppData\Local"

# Set the user profile directory
$userProfile = "C:\Users\$username\"

# Get the full path of the currently running script
$scriptPath = $MyInvocation.MyCommand.Path

Write-Output $scriptPath

# Get the parent directory of the script
$parent = $scriptPath.replace("\scripts\windows_setup.ps1", "")

# Set the config directory
$configPath = Join-Path $parent "config"

# Continue with the rest of the script using the $username
Write-Host "Proceeding with installation for user: $username"
# The rest of your script follows here, using $username where necessary

# Write-Host "Starting Windows Setup..."

# Write-Host "Installing Windows Terminal"

# CheckWingetInstallation "Microsoft.WindowsTerminal"

# Write-Host "Installing New Microsoft PowerShell"

# CheckWingetInstallation "Microsoft.Powershell"

# Write-Host "Installing Visual Studio Code"

# CheckWingetInstallation "Microsoft.VisualStudioCode"

# Fonts

# Write-Host "Installing Nerd Fonts"

# InstallNerdFont "Hack" "v3.2.1"


# # Create symlink for Windows Terminal settings.json
Write-Host "Creating symlink for Windows Terminal settings.json..."

$wtSourcePath = Join-Path $configPath "settings.json"
$wtTargetPath = Join-Path $userLocalAppData "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Delete the existing settings.json if it exists to avoid conflict
if (Test-Path $wtTargetPath) {
	# TODO: Should probably just create a .bak file instead of deleting 
    Remove-Item $wtTargetPath
}

# Create a symbolic link to the settings.json file
New-Item -ItemType SymbolicLink -Path $wtTargetPath -Target $wtSourcePath



# Create symlink for .gitconfig
Write-Host "Creating symlink for .gitconfig..."

$gcSourcePath = Join-Path $configPath ".gitconfig"
$gcTargetPath = Join-Path $userProfile ".gitconfig"

# Delete the existing .gitconfig if it exists to avoid conflict
if (Test-Path $gcTargetPath) {
		# TODO: Should probably just create a .bak file instead of deleting 
		Remove-Item $gcTargetPath
}

# Create a symbolic link to the .gitconfig file
New-Item -ItemType SymbolicLink -Path $gcTargetPath -Target $gcSourcePath

# # Install WSL2
# # Check if WSL is already installed by listing installed distributions
# $wslDistributions = wsl --list --quiet
# if ($wslDistributions) {
#     Write-Host "WSL is already installed. Installed distributions:"
#     Write-Host $wslDistributions
# } else {
#     Write-Host "Installing WSL2..."
#     wsl --install
# }