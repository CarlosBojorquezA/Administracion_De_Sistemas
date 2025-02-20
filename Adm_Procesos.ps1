Get-Process
Stop-Process -Name "bloc de notas"
Start-Process "bloc de notas.exe"
Wait-Process -Name "bloc de notas"