# Instalación y Configuración de Vim en Windows

Start-Process "https://www.vim.org/download.php" -Wait

choco install vim -y

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

vim --version
vim

vim archivo.txt

New-Item -Path "$HOME/_vimrc" -ItemType File

Set-Content -Path "$HOME/_vimrc" -Value @"
syntax on
set number
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
"@

vim