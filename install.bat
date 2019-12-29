@ECHO OFF

@REM Check admin
OPENFILES > NUL 2>&1
IF NOT %ERRORLEVEL% EQU 0 GOTO ERROR_NOT_ADMIN
@REM Make symbolic link
DEL "%HOMEPATH%\.gitconfig"
SET DOTFILES_REPO=%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
) ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)
MKLINK "%HOMEPATH%\.gitconfig" "%DOTFILES_REPO%\.gitconfig"
