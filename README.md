# dotfiles

## Installation

### Windows

1. [*Windows Package Manager Client (aka winget.exe)*](https://github.com/microsoft/winget-cli#installing-the-client)
   をインストールします。  
   Install [*Windows Package Manager Client (aka winget.exe)*](https://github.com/microsoft/winget-cli#installing-the-client).  
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
