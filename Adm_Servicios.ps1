Get-Service
Stop-Service -Name "wuauserv"  # Servicio de Windows Update
Start-Service -Name "wuauserv"
Restart-Service -Name "wuauserv"
Set-Service -Name "wuauserv" -StartupType Automatic