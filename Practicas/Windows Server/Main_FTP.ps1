Import-Module "./FuncionesFTP.ps1"

# Función para verificar e instalar el servidor FTP si no está instalado
function Verificar-Instalar-FTP {
    $ftpFeature = Get-WindowsFeature -Name Web-Ftp-Server
    if ($ftpFeature.Installed -eq $false) {
        Write-Host "Instalando el servidor FTP..." -ForegroundColor Yellow
        Install-WindowsFeature -Name Web-Ftp-Server -IncludeManagementTools
    } else {
        Write-Host "El servidor FTP ya está instalado." -ForegroundColor Green
    }
    
    # Verificar si el servicio FTP está corriendo
    $ftpService = Get-Service -Name FTPSVC -ErrorAction SilentlyContinue
    if ($ftpService -eq $null -or $ftpService.Status -ne 'Running') {
        Write-Host "Iniciando el servicio FTP..." -ForegroundColor Yellow
        Start-Service -Name FTPSVC
        Set-Service -Name FTPSVC -StartupType Automatic
    } else {
        Write-Host "El servicio FTP ya está activo." -ForegroundColor Green
    }
}

Verificar-Instalar-FTP

function Mostrar-Menu {
    Write-Host "\n--- Administrador FTP ---" -ForegroundColor Cyan
    Write-Host "1. Agregar usuario"
    Write-Host "2. Eliminar usuario"
    Write-Host "3. Configurar permisos de usuario"
    Write-Host "4. Salir"
    
    $opcion = Read-Host "Seleccione una opción"
    return $opcion
}

while ($true) {
    $opcion = Mostrar-Menu
    switch ($opcion) {
        "1" {
            $nombreUsuario = Read-Host "Ingrese el nombre del usuario"
            $grupo = Read-Host "Ingrese el grupo (reprobados/recursadores)"
            Crear-Usuario -NombreUsuario $nombreUsuario -Grupo $grupo
        }
        "2" {
            $nombreUsuario = Read-Host "Ingrese el nombre del usuario a eliminar"
            Eliminar-Usuario -NombreUsuario $nombreUsuario
        }
        "3" {
            $nombreUsuario = Read-Host "Ingrese el nombre del usuario"
            $grupo = Read-Host "Ingrese el grupo (reprobados/recursadores)"
            Configurar-Permisos -NombreUsuario $nombreUsuario -Grupo $grupo
        }
        "4" {
            Write-Host "Saliendo..." -ForegroundColor Magenta
            break
        }
        default {
            Write-Host "Opción inválida, intente de nuevo." -ForegroundColor Red
        }
    }
}