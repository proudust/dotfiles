SET DOTFILES_REPO=%HOMEPATH%\dotfiles
IF NOT EXIST %DOTFILES_REPO%\.git (
  git clone https://github.com/proudust/dotfiles.git %DOTFILES_REPO%
)
ELSE (
  git -C %DOTFILES_REPO% fetch origin & git -C %DOTFILES_REPO% pull origin
)

DEL %HOMEPATH%"\dotfiles\.gitconfig"
MKLINK %HOMEPATH%"\.gitconfig" %DOTFILES_REPO%"\.gitconfig"
