@ECHO OFF

REM Require execution as administrator
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 (
  ECHO Reexecute it batch as administrator
  SETLOCAL
  SET "ME=%~dpnx0"
  SET "ARG=%*"
  POWERSHELL "start-process -FilePath $env:ME -ArgumentList '$env:ARG' -verb runas"
  EXIT /B
)

REM Require git
WHERE /Q git
IF NOT %ERRORLEVEL% == 0 (
  ECHO Install Git for Windows
  winget install -h -e Git.Git

  ECHO Reexecute it batch as administrator
  SETLOCAL
  SET "ME=%~dpnx0"
  SET "ARG=%*"
  POWERSHELL "start-process -FilePath $env:ME -ArgumentList '$env:ARG' -verb runas"
  EXIT /B
)

@ECHO Clone dotfiles repo
SET DOTFILES_REPO=%HOMEDRIVE%%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
) ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)
if defined CHECKOUT_REF (
  git -C %DOTFILES_REPO% checkout %CHECKOUT_REF%
)

@ECHO Make symbolic links
@REM git
DEL "%HOMEPATH%\.gitconfig"
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"
REM WindowsTerminal
MKDIR "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" > NUL 2>&1
DEL "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
MKLINK ^
  "%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" ^
  "%HOMEDRIVE%%HOMEPATH%\dotfiles\windows\terminal\settings.json"
@REM winget
MKDIR "%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState" > NUL 2>&1
DEL "%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
MKLINK ^
  "%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json" ^
  "%HOMEDRIVE%%HOMEPATH%\dotfiles\windows\winget\settings.json"

@ECHO Enable Windows feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

@ECHO Set registry
REG IMPORT %DOTFILES_REPO%\windows\registry.reg

WHERE /Q winget
IF %ERRORLEVEL% == 0 (
  ECHO Install applications using winget
  winget install -h -e 7zip.7zip
  winget install -h -e Docker.DockerDesktop
  winget install -h -e Git.Git
  winget install -h -e Microsoft.PowerToys
  winget install -e Microsoft.VisualStudioCode.System-x64 --override "/verysilent /mergetasks=""addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"""
  winget install -h -e Microsoft.WindowsTerminal
  winget install -h -e VivaldiTechnologies.Vivaldi

  ECHO Uninstall preinstall applications using winget
  winget uninstall Microsoft.549981C3F5F10_8wekyb3d8bbwe
  winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe
  winget uninstall Microsoft.Microsoft3DViewer_8wekyb3d8bbwe
  winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe
  winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe
  winget uninstall Microsoft.MSPaint_8wekyb3d8bbwe
  winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe
  winget uninstall Microsoft.People_8wekyb3d8bbwe
  winget uninstall Microsoft.SkypeApp_kzf8qxf38zg5c
  winget uninstall Microsoft.Wallet_8wekyb3d8bbwe
  winget uninstall Microsoft.WindowsCamera_8wekyb3d8bbwe
  winget uninstall microsoft.windowscommunicationsapps_8wekyb3d8bbwe
  winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe
  winget uninstall Microsoft.Xbox.TCUI_8wekyb3d8bbwe
  winget uninstall Microsoft.XboxApp_8wekyb3d8bbwe
  winget uninstall Microsoft.XboxGameOverlay_8wekyb3d8bbwe
  winget uninstall Microsoft.XboxGamingOverlay_8wekyb3d8bbwe
  winget uninstall Microsoft.XboxIdentityProvider_8wekyb3d8bbwe
  winget uninstall Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe
  winget uninstall Microsoft.YourPhone_8wekyb3d8bbwe
  winget uninstall OneDriveSetup.exe
  winget uninstall SpotifyAB.SpotifyMusic_zpdnekdrzrea0
) ELSE (
  ECHO Error: winget is not installed.
)

EXIT /B 0
