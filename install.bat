@ECHO OFF

@ECHO Check admin
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 GOTO ERROR_NOT_ADMIN

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
DEL "%HOMEPATH%\.gitconfig"
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"

@ECHO Enable Windows feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

@ECHO Set registry
REG IMPORT %DOTFILES_REPO%\registry.reg

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
