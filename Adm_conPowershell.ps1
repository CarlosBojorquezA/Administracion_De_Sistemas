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







