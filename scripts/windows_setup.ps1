# * Config

$programList = @(
	"Microsoft.WindowsTerminal",
	"Microsoft.Powershell",
	"Microsoft.VisualStudioCode",
	"Git.Git"
)

$driveLetter = "C"

# * Functions

function InstallWithWinget {
	param(
		[string]$programId
	)

	Write-Host "Attempting to install $programId"
	winget install --id=$programId --source winget -e

}

function InstallNerdFont {
	param(
		[string]$nerdFontName,
		[string]$nerdFontVersion,
		[string]$userProfile
	)

	$nerdFontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$nerdFontVersion/$nerdFontName.zip"
	$fontZipPath = "$userProfile\Downloads\$nerdFontName.zip"
	$fontExtractPath = "$userProfile\Downloads\$nerdFontName"

	# Per-user font directory (no admin required, Windows 10 1809+)
	$userFontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
	$fontRegKey = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

	# Define the expected font file name (assuming TTF format)
	$fontFileName = "$nerdFontName Nerd Font.ttf"

	# Ensure the user fonts directory exists
	if (-not (Test-Path $userFontsPath)) {
		New-Item -ItemType Directory -Path $userFontsPath | Out-Null
	}

	# Check if the font is already installed in the user fonts directory
	if (Test-Path (Join-Path $userFontsPath $fontFileName)) {
			Write-Host "$nerdFontName is already installed."
	} else {
		Write-Host "Downloading Nerd Font..."
		Invoke-WebRequest -Uri $nerdFontUrl -OutFile $fontZipPath

		# Extract Nerd Font
		Write-Host "Extracting Nerd Font..."
		Expand-Archive -Path $fontZipPath -DestinationPath $fontExtractPath

		# Install Nerd Font to user-level fonts directory
		Write-Host "Installing Nerd Font..."
		$fontFiles = Get-ChildItem -Path $fontExtractPath -Filter *.ttf
		foreach ($fontFile in $fontFiles) {
			Copy-Item -Path $fontFile.FullName -Destination $userFontsPath
			$fontRegValueName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile.Name)
			$fontRegValue = Join-Path $userFontsPath $fontFile.Name
			Set-ItemProperty -Path $fontRegKey -Name $fontRegValueName -Value $fontRegValue
		}

		Write-Host "Nerd Font installation complete."

		# Clean up
		Write-Host "Cleaning up..."
		Remove-Item -Path $fontZipPath
		Remove-Item -Path $fontExtractPath -Recurse
	}

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

function CreateSymlink {
	param(
		[string]$fileName,
		[string]$targetDirectory
	)

	$sourcePath = Join-Path $configPath $fileName
	$targetPath = Join-Path $targetDirectory $fileName

	# If the file already exists, rename it as a backup.
	if (Test-Path $targetPath) {
		$backupPath = Join-Path $targetDirectory "$fileName.bak"
		Move-Item -Path $targetPath -Destination $backupPath
	}

	# Create a symbolic link to the file
	New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath

	Write-Host "Created symlink for $fileName"
}

function InstallWingetList {
	param(
		[string[]]$programs
	)

	foreach ($program in $programs) {
		InstallWithWinget $program
	}
}

# * Setup Steps

function Step-InstallPrograms {
	Write-Host "`nInstalling programs via winget..."
	InstallWingetList $programList
	Write-Host "Program installation complete."
}

function Step-InstallFonts {
	Write-Host "`nInstalling Nerd Fonts..."
	InstallNerdFont "Hack" "v3.4.0" $userProfile
	Write-Host "Font installation complete."
}

function Step-CreateSymlinks {
	Write-Host "`nCreating symlinks..."
	$wtLocalState = Join-Path $userLocalAppData "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
	CreateSymlink "settings.json" $wtLocalState
	CreateSymlink ".gitconfig" $userProfile
	Write-Host "Symlink creation complete."
}

function Step-InstallWSL {
	Write-Host "`nChecking WSL2..."
	$wslDistributions = wsl --list --quiet
	if ($wslDistributions) {
		Write-Host "WSL is already installed. Installed distributions:"
		Write-Host $wslDistributions
	} else {
		Write-Host "Installing WSL2..."
		wsl --install
	}
}

function Step-FullSetup {
	Write-Host "`nRunning full setup..."
	Step-InstallPrograms
	Step-InstallFonts
	Step-CreateSymlinks
	Step-InstallWSL
	Write-Host "`nFull setup complete. Please restart your computer to apply changes."
}

# * Initial Setup

# Check if winget is installed
$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

if (-not $wingetInstalled) {
	Write-Host "winget is not installed. Please install winget and run the script again."
	Write-Host "You can install winget from https://apps.microsoft.com/detail/9nblggh4nns1"
	Pause
	Exit
}

# Use the function to get a valid username
$username = GetUser

# Set the local appdata directory for the selected user.
$userLocalAppData = "${driveLetter}:\Users\$username\AppData\Local"

# Set the user profile directory
$userProfile = "${driveLetter}:\Users\$username\"

# Get the full path of the currently running script
$scriptPath = $MyInvocation.MyCommand.Path

# Get the parent directory of the script
$parent = $scriptPath.replace("\scripts\windows_setup.ps1", "")

# Set the config directory
$configPath = Join-Path $parent "config"

# * Menu

Write-Host "`nProceeding with installation for user: $username"

do {
	Write-Host "`n===== Setup Menu ====="
	Write-Host "1. Install programs (winget)"
	Write-Host "2. Install Nerd Fonts"
	Write-Host "3. Create symlinks"
	Write-Host "4. Install WSL2"
	Write-Host "5. Full setup (all of the above)"
	Write-Host "0. Exit"
	Write-Host "======================"

	$choice = Read-Host "Enter your choice"

	switch ($choice) {
		"1" { Step-InstallPrograms }
		"2" { Step-InstallFonts }
		"3" { Step-CreateSymlinks }
		"4" { Step-InstallWSL }
		"5" { Step-FullSetup }
		"0" { Write-Host "Exiting."; break }
		default { Write-Host "Invalid choice. Please enter a number from the menu." }
	}
} while ($choice -ne "0")

Pause
