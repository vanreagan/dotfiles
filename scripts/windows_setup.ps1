
# Check if winget is installed
$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

# If winget is not installed prompt the user to install it and exit the script

if (-not $wingetInstalled) {
	Write-Host "winget is not installed. Please install winget and run the script again."
	Write-Host "You can install winget from https://apps.microsoft.com/detail/9nblggh4nns1"

	# Pause the script
	Pause

	# Exit the script
	Exit
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

$programList = @(
	"Microsoft.WindowsTerminal",
	"Microsoft.Powershell",
	"Microsoft.VisualStudioCode",
	"Git.Git",
)


InstallWingetList $programList

# Fonts

Write-Host "Installing Nerd Fonts"

InstallNerdFont "Hack" "v3.2.1"


# # Create symlinks
$wtLocalState = Join-Path $userLocalAppData "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

CreateSymlink "settings.json" $wtLocalState

CreateSymlink ".gitconfig" $userProfile



# # Install WSL2
# Check if WSL is already installed by listing installed distributions
$wslDistributions = wsl --list --quiet
if ($wslDistributions) {
    Write-Host "WSL is already installed. Installed distributions:"
    Write-Host $wslDistributions
} else {
    Write-Host "Installing WSL2..."
    wsl --install
}

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
		[string]$nerdFontVersion
	)

	$nerdFontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/$nerdFontVersion/$nerdFontName.zip"
	$fontZipPath = "$userProfile\Downloads\$nerdFontName.zip"
	$fontExtractPath = "$userProfile\Downloads\$nerdFontName"

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