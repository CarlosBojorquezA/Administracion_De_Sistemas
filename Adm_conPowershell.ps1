#Get-Process | Where-Object { $PSItem.CPU -gt 10 }

#Get-Service | ForEach-Object { Write-Host "Servicio: $PSItem.Name - Estado: $PSItem.Status" }

param (
    [string]$Nombre,
    [string]$Accion
)

if ($Accion -eq "Crear") {
    New-LocalUser -Name $Nombre -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force) -FullName "$Nombre" -Description "Usuario creado desde PowerShell"
    Write-Host "Usuario $Nombre creado."
} elseif ($Accion -eq "Eliminar") {
    Remove-LocalUser -Name $Nombre
    Write-Host "Usuario $Nombre eliminado."
} else {
    Write-Host "Acción no válida. Usa 'Crear' o 'Eliminar'."
}

.\usuarios.ps1 -Nombre "Juan" -Accion "Crear" #ejecucion para crear usuario
.\usuarios.ps1 -Nombre "Juan" -Accion "Eliminar" #ejecucion para eliminar usuario

# administracion de servicios

Get-Service
Stop-Service -Name "wuauserv"  # Servicio de Windows Update
Start-Service -Name "wuauserv"
Restart-Service -Name "wuauserv"
Set-Service -Name "wuauserv" -StartupType Automatic

# administrador de procesos

Get-Process
Stop-Process -Name "bloc de notas"
Start-Process "bloc de notas.exe"
Wait-Process -Name "bloc de notas"

# adminitracion de usuarios y grupos

Get-LocalUser
Get-LocalGroup
New-LocalUser -Name "pito perez" -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force) -FullName "pito perez" -Description "Usuario de prueba"
Remove-LocalUser -Name "pito perez"
Add-LocalGroupMember -Group "Administrators" -Member "pito perez"
Remove-LocalGroupMember -Group "Administrators" -Member "pito perez"





