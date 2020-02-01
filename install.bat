@ECHO OFF

@ECHO Check admin
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 GOTO ERROR_NOT_ADMIN

@ECHO Install chocolatey and git
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cinst -ry --no-progress git

@ECHO Clone dotfiles repo
SET DOTFILES_REPO=%HOMEDRIVE%%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
) ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)

@ECHO Make symbolic links
DEL "%HOMEPATH%\.gitconfig"
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"
MKDIR "%APPDATA%\Code\User" > NUL 2>&1
DEL "%APPDATA%\Code\User\settings.json"
MKLINK "%APPDATA%\Code\User\settings.json" "%DOTFILES_REPO%\.vscode\settings.json"

@ECHO Enable Windows feature
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux"

@ECHO Set registry
REG IMPORT %DOTFILES_REPO%\registry.reg

@ECHO Install packages
cinst -ry --no-progress %DOTFILES_REPO%\Packages.config
choco pin add -n=googlechrome
choco pin add -n=vivaldi
choco pin add -n=vscode
choco pin add -n=discord
choco pin add -n=minecraft
choco pin add -n=steam
choco pin add -n=origin

@ECHO Install VSCode extensions
FOR /f "usebackq delims=" %%a in (`jq -r ".recommendations[]" %DOTFILES_REPO%\.vscode\extensions.json`) DO (
  code --install-extension %%a
)

@ECHO Uninstall unnecessary apps
powershell "Get-AppxPackage king.com.CandyCrushSodaSaga | Remove-AppxPackage"
powershell "Get-AppxPackage A278AB0D.MarchofEmpires | Remove-AppxPackage"
powershell "Get-AppxPackage 828B5831.HiddenCityMysteryofShadows | Remove-AppxPackage"
powershell "Get-AppxPackage DolbyLaboratories.DolbyAccess | Remove-AppxPackage"
powershell "Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage"
powershell "Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage"

IF EXIST %SystemRoot%\SysWOW64\OneDriveSetup.exe (
  @ECHO Uninstall OneDrive
  TASKKILL /f /im OneDrive.exe
  %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
  RD "%UserProfile%\OneDrive" /Q /S
  RD "%LocalAppData%\Microsoft\OneDrive" /Q /S
  RD "%ProgramData%\Microsoft OneDrive" /Q /S
)

GOTO END

:ERROR_NOT_ADMIN
echo ERROR: Not admin user.
GOTO END

:END
