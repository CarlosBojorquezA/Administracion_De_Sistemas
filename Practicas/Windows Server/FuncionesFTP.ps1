# Función para crear un usuario en Windows
function Crear-Usuario {
    param (
        [string]$NombreUsuario,
        [string]$Grupo
    )
    
    # Validar si el usuario ya existe
    $usuarioExiste = Get-LocalUser -Name $NombreUsuario -ErrorAction SilentlyContinue
    if ($usuarioExiste) {
        Write-Host "El usuario '$NombreUsuario' ya existe." -ForegroundColor Yellow
        return
    }
    
    # Crear usuario sin contraseña (para acceso FTP sin autenticación fuerte)
    New-LocalUser -Name $NombreUsuario -NoPassword -UserMayChangePassword $false -PasswordNeverExpires $true
    
    # Agregar usuario al grupo correspondiente
    Add-LocalGroupMember -Group $Grupo -Member $NombreUsuario
    Write-Host "Usuario '$NombreUsuario' creado y agregado al grupo '$Grupo'." -ForegroundColor Green
}

# Función para eliminar un usuario
function Eliminar-Usuario {
    param (
        [string]$NombreUsuario
    )
    
    # Validar si el usuario existe
    $usuarioExiste = Get-LocalUser -Name $NombreUsuario -ErrorAction SilentlyContinue
    if (!$usuarioExiste) {
        Write-Host "El usuario '$NombreUsuario' no existe." -ForegroundColor Red
        return
    }
    
    # Eliminar usuario
    Remove-LocalUser -Name $NombreUsuario
    Write-Host "Usuario '$NombreUsuario' eliminado." -ForegroundColor Green
}

# Función para configurar permisos de carpetas FTP y montarlas
function Configurar-Permisos {
    param (
        [string]$NombreUsuario,
        [string]$Grupo
    )
    
    $basePath = "C:\\inetpub\\ftproot"
    $carpetaUsuario = "$basePath\\$NombreUsuario"
    $carpetaGrupo = "$basePath\\$Grupo"
    $carpetaGeneral = "$basePath\\general"
    
    # Crear carpetas si no existen
    if (!(Test-Path $carpetaUsuario)) { New-Item -ItemType Directory -Path $carpetaUsuario }
    if (!(Test-Path $carpetaGrupo)) { New-Item -ItemType Directory -Path $carpetaGrupo }
    if (!(Test-Path $carpetaGeneral)) { New-Item -ItemType Directory -Path $carpetaGeneral }
    
    # Asignar permisos
    icacls $carpetaUsuario /grant "$NombreUsuario(OI)(CI)F"
    icacls $carpetaGrupo /grant "$NombreUsuario(OI)(CI)M"
    icacls $carpetaGeneral /grant "$NombreUsuario(OI)(CI)M"
    
    # Montar las carpetas en el FTP
    New-PSDrive -Name "FTPGeneral" -PSProvider FileSystem -Root $carpetaGeneral -Persist
    New-PSDrive -Name "FTPUsuario" -PSProvider FileSystem -Root $carpetaUsuario -Persist
    New-PSDrive -Name "FTPGrupo" -PSProvider FileSystem -Root $carpetaGrupo -Persist
    
    Write-Host "Permisos configurados y carpetas montadas para el usuario '$NombreUsuario'." -ForegroundColor Green
}