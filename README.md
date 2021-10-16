# dotfiles

## Installation

### Windows

1. Microsoft Store から
  [App Installer](https://www.microsoft.com/store/productId/9NBLGGH4NNS1)
  をインストールまたは更新します。  
  Install or update the
  [App Installer](https://www.microsoft.com/store/productId/9NBLGGH4NNS1)
  from the Microsoft Store.  

2. コマンドプロンプトまたは Powershell で以下のコマンドを実行します。  
   Execute the following command at the Command Prompt.  

*コマンドプロンプト (Command Prompt):*

```bat
BITSADMIN /TRANSFER DOTFILES https://raw.github.com/proudust/dotfiles/master/install.bat %TEMP%\install.bat
%TEMP%\install.bat
```

*Powershell:*

```ps1
Invoke-WebRequest https://raw.github.com/proudust/dotfiles/master/install.bat -OutFile "$env:TEMP\install.bat"
Start-Process -FilePath "$env:TEMP\install.bat" -verb runas
```

### Linux

以下のコマンドを実行します。  
Execute the following command.  

```sh
bash <(curl -sL raw.github.com/proudust/dotfiles/master/install.sh)
```
