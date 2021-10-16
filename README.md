# dotfiles

## Installation

### Windows

1. Microsoft Store から
  [App Installer](https://www.microsoft.com/store/productId/9NBLGGH4NNS1)
  をインストールまたは更新します。  
  Install or update the
  [App Installer](https://www.microsoft.com/store/productId/9NBLGGH4NNS1)
  from the Microsoft Store.  

2. コマンドプロンプトで以下のコマンドを実行します。  
   Execute the following command at command prompt.  

```bat
bitsadmin /TRANSFER DOTFILES https://raw.github.com/proudust/dotfiles/master/install.bat %TEMP%\install.bat
%TEMP%\install.bat
```

### Linux

以下のコマンドを実行します。  
Execute the following command.  

```sh
bash <(curl -sL raw.github.com/proudust/dotfiles/master/install.sh)
```
