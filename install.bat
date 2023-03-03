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

REM Require winget
WHERE /Q winget
IF NOT %ERRORLEVEL% == 0 IF DEFINED %SKIP_WINGET_CHECK% (
  ECHO Error: Please install or update the App Installer from the Microsoft Store
  START https://www.microsoft.com/store/productId/9NBLGGH4NNS1
  EXIT /B
)

REM Require git
WHERE /Q git
IF NOT %ERRORLEVEL% == 0 (
  ECHO Install Git for Windows
  winget install -h -e Git.Git --source winget

  ECHO Re-execute it batch as administrator
  SETLOCAL
  SET "ME=%~dpnx0"
  SET "ARG=%*"
  POWERSHELL "start-process -FilePath $env:ME -ArgumentList '$env:ARG' -verb runas"
  EXIT /B
)

ECHO Clone dotfiles repo
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
DEL "%HOMEDRIVE%%HOMEPATH%\.gitconfig"
MKLINK "%HOMEDRIVE%%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"
MKLINK "%HOMEDRIVE%%HOMEPATH%\.gitconfig_shared" "%DOTFILES_REPO%\.gitconfig_win"
MKDIR "%HOMEDRIVE%%HOMEPATH%\.config\git" > NUL 2>&1
DEL "%HOMEDRIVE%%HOMEPATH%\.config\git\ignore"
MKLINK "%HOMEDRIVE%%HOMEPATH%\.config\git\ignore" "%DOTFILES_REPO%\.gitignore"
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
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

@ECHO Set registry
REG IMPORT %DOTFILES_REPO%\windows\registry.reg

WHERE /Q winget
IF %ERRORLEVEL% == 0 (
  ECHO Install applications using winget
  winget install -h -e 7zip.7zip --source winget
  winget install -h -e Docker.DockerDesktop --source winget
  winget install -h -e Git.Git --source winget
  winget install -e Microsoft.VisualStudioCode.System-x64 --source winget --override "/verysilent /mergetasks=""addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"""
  winget install -h -e VivaldiTechnologies.Vivaldi --source winget
  winget install "Microsoft PowerToys" --source msstore --accept-source-agreements --accept-package-agreements
  winget install "Windows Terminal" --source msstore --accept-source-agreements --accept-package-agreements
  winget install "Windows Subsystem for Linux" --source msstore --accept-source-agreements --accept-package-agreements

  ECHO Uninstall pre-install applications using winget
  @REM Cortana
  winget uninstall Microsoft.549981C3F5F10_8wekyb3d8bbwe
  winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe
  winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe
  winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe
  winget uninstall Microsoft.People_8wekyb3d8bbwe
  winget uninstall Microsoft.SkypeApp_kzf8qxf38zg5c
  winget uninstall Microsoft.Wallet_8wekyb3d8bbwe
  winget uninstall Microsoft.WindowsCamera_8wekyb3d8bbwe
  winget uninstall microsoft.windowscommunicationsapps_8wekyb3d8bbwe
  winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe
  winget uninstall Microsoft.YourPhone_8wekyb3d8bbwe
  winget uninstall OneDriveSetup.exe
  winget uninstall SpotifyAB.SpotifyMusic_zpdnekdrzrea0
) ELSE (
  ECHO Error: winget is not installed.
)

EXIT /B 0
