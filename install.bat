@ECHO OFF

@REM Check admin
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 GOTO ERROR_NOT_ADMIN

@REM Setup chocolatey and git
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cinst git

@REM Make symbolic link
DEL "%HOMEPATH%\.gitconfig"
DEL "%APPDATA%\Code\User\settings.json"
SET DOTFILES_REPO=%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
) ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"
MKLINK "%APPDATA%\Code\User\settings.json" "%DOTFILES_REPO%\.vscode\settings.json"

@REM Enable Windows feature
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux"

@REM Set registry
REG IMPORT %DOTFILES_REPO%\registry.reg

@REM Install chocolatey packages
cinst -y %DOTFILES_REPO%\Packages.config
choco pin add -n=googlechrome
choco pin add -n=vivaldi
choco pin add -n=vscode
choco pin add -n=discord
choco pin add -n=minecraft
choco pin add -n=steam
choco pin add -n=origin

@REM Uninstall OneDrive
TASKKILL /f /im OneDrive.exe
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
RD "%UserProfile%\OneDrive" /Q /S
RD "%LocalAppData%\Microsoft\OneDrive" /Q /S
RD "%ProgramData%\Microsoft OneDrive" /Q /S

GOTO END

:ERROR_NOT_ADMIN
echo ERROR: Not admin user.
GOTO END

:END
