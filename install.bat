@ECHO OFF

@REM Check admin
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 GOTO ERROR_NOT_ADMIN

@REM Setup chocolatey and git
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
cinst git

@REM Make symbolic link
DEL "%HOMEPATH%\.gitconfig"
SET DOTFILES_REPO=%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
) ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"

GOTO END

:ERROR_NOT_ADMIN
echo ERROR: Not admin user.
GOTO END

:END
