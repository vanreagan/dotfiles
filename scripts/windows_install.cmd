@echo off

@REM * Config

setlocal enableextensions enabledelayedexpansion
set me=%~n0
set parent=%~dp0

@REM Check if a username is provided as a command-line argument because this script needs to be run as admin, and the user directory is not the same as the admin directory in all cases.
if "%~1"=="" (
    @REM Prompt the user for a username
    set /p "USERNAME=Enter the username for installation (press Enter for admin user): "
    if "!USERNAME!"=="" (
        set "USER_LOCALAPPDATA=%LOCALAPPDATA%"
    ) else (
        @REM Assuming C:\Users as the user directory. 
        set "USER_LOCALAPPDATA=C:\Users\!USERNAME!\AppData\Local"
    )
) else (
    @REM Use the provided command-line argument as the username
    set "USER_LOCALAPPDATA=C:\Users\%~1\AppData\Local"
)

set "SOURCE_PATH=%parent%settings.json"
set "TARGET_PATH=%USER_LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

@REM * Main
:start
    @REM Delete the existing settings.json if it exists to avoid conflict
    if exist "%TARGET_PATH%" del "%TARGET_PATH%"

    @REM Create a symbolic link to the settings.json file
    mklink "%TARGET_PATH%" "%SOURCE_PATH%"

:end
    pause
    endlocal