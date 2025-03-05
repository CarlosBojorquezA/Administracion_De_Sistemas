# Grupos permitidos
$GruposPermitidos = @("reprobados", "recursadores")

# Función para crear un usuario
function Crear-Usuario {
    param (
        [string]$NombreUsuario,
        [string]$Grupo
    )

    # Validar grupo permitido
    if ($GruposPermitidos -notcontains $Grupo) {
        Write-Host "Error: El grupo '$Grupo' no está permitido." -ForegroundColor Red
        return
    }

    # Solicitar contraseña (máximo 8 caracteres)
    do {
        $Password = Read-Host "Ingresa la contraseña para $NombreUsuario (máximo 8 caracteres)" -AsSecureString
        $PasswordTexto = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        
        # Validar longitud de la contraseña
        if ($PasswordTexto.Length -gt 8) {
            Write-Host "Error: La contraseña no debe exceder 8 caracteres." -ForegroundColor Red
            continue
        }

        break
    } while ($true)

    # Validar si el usuario ya existe
    $usuarioExiste = Get-LocalUser -Name $NombreUsuario -ErrorAction SilentlyContinue
    if ($usuarioExiste) {
        Write-Host "El usuario '$NombreUsuario' ya existe." -ForegroundColor Yellow
        return
    }

    # Crear usuario en Windows
    try {
        New-LocalUser -Name $NombreUsuario -Password (ConvertTo-SecureString -AsPlainText $PasswordTexto -Force) -PasswordNeverExpires:$true -ErrorAction Stop
        Write-Host "Usuario '$NombreUsuario' creado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "Error al crear el usuario '$NombreUsuario': $_" -ForegroundColor Red
        return
    }

    # Crear grupo si no existe
    if (-not (Get-LocalGroup -Name $Grupo -ErrorAction SilentlyContinue)) {
        New-LocalGroup -Name $Grupo
    }

    # Agregar usuario al grupo correspondiente
    try {
        Add-LocalGroupMember -Group $Grupo -Member $NombreUsuario -ErrorAction Stop
        Write-Host "Usuario '$NombreUsuario' agregado al grupo '$Grupo'." -ForegroundColor Green
    } catch {
        Write-Host "Error al agregar el usuario '$NombreUsuario' al grupo '$Grupo': $_" -ForegroundColor Red
        return
    }

    # Configurar carpetas en FTP
    Configurar-Permisos -NombreUsuario $NombreUsuario -Grupo $Grupo
}

# Función para eliminar un usuario
function Eliminar-Usuario {
    param (
        [string]$NombreUsuario
    )

    # Validar si el usuario existe
    $usuarioExiste = Get-LocalUser -Name $NombreUsuario -ErrorAction SilentlyContinue
    if (-not $usuarioExiste) {
        Write-Host "El usuario '$NombreUsuario' no existe." -ForegroundColor Red
        return
    }

    # Eliminar usuario
    try {
        Remove-LocalUser -Name $NombreUsuario -ErrorAction Stop
        Write-Host "Usuario '$NombreUsuario' eliminado de Windows." -ForegroundColor Green
    } catch {
        Write-Host "Error al eliminar el usuario '$NombreUsuario': $_" -ForegroundColor Red
        return
    }

    # Eliminar carpeta del usuario
    $rutaUsuario = "C:\inetpub\ftproot\$NombreUsuario"
    if (Test-Path $rutaUsuario) {
        Remove-Item -Path $rutaUsuario -Recurse -Force
        Write-Host "Carpeta de usuario eliminada: $rutaUsuario" -ForegroundColor Yellow
    }
}

# Función para configurar permisos de carpetas FTP
function Configurar-Permisos {
    param (
        [string]$NombreUsuario,
        [string]$Grupo
    )

    $basePath = "C:\inetpub\ftproot\$NombreUsuario"
    $carpetaUsuario = "$basePath\$NombreUsuario"
    $carpetaGrupo = "$basePath\$Grupo"
    $carpetaGeneral = "$basePath\general"

    # Crear carpeta base si no existe
    if (-not (Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath
    }

    # Crear subcarpetas si no existen
    if (-not (Test-Path $carpetaUsuario)) { New-Item -ItemType Directory -Path $carpetaUsuario }
    if (-not (Test-Path $carpetaGrupo)) { New-Item -ItemType Directory -Path $carpetaGrupo }
    if (-not (Test-Path $carpetaGeneral)) { New-Item -ItemType Directory -Path $carpetaGeneral }

    # Asignar permisos usando icacls
    try {
        icacls $carpetaUsuario /grant "${NombreUsuario}:(OI)(CI)F" /T
        icacls $carpetaGrupo /grant "${NombreUsuario}:(OI)(CI)M" /T
        icacls $carpetaGeneral /grant "${NombreUsuario}:(OI)(CI)M" /T
        Write-Host "Permisos configurados para '$NombreUsuario' en FTP." -ForegroundColor Green
    } catch {
        Write-Host "Error al configurar permisos para '$NombreUsuario': $_" -ForegroundColor Red
    }
}

# Función para cambiar un usuario de grupo
function Cambiar-Grupo {
    param (
        [string]$NombreUsuario,
        [string]$NuevoGrupo
    )

    # Validar grupo permitido
    if ($GruposPermitidos -notcontains $NuevoGrupo) {
        Write-Host "Error: Grupo no permitido." -ForegroundColor Red
        return
    }

    # Obtener el grupo actual del usuario
    $grupoActual = Get-LocalGroup | Where-Object { (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $NombreUsuario } | Select-Object -ExpandProperty Name

    if (-not $grupoActual) {
        Write-Host "El usuario '$NombreUsuario' no pertenece a ningún grupo." -ForegroundColor Yellow
        return
    }

    if ($grupoActual -eq $NuevoGrupo) {
        Write-Host "El usuario '$NombreUsuario' ya pertenece a '$NuevoGrupo'." -ForegroundColor Yellow
        return
    }

    # Quitar usuario del grupo actual
    try {
        Remove-LocalGroupMember -Group $grupoActual -Member $NombreUsuario -ErrorAction Stop
        Write-Host "Usuario eliminado del grupo '$grupoActual'." -ForegroundColor Green
    } catch {
        Write-Host "Error al eliminar el usuario '$NombreUsuario' del grupo '$grupoActual': $_" -ForegroundColor Red
        return
    }

    # Agregar usuario al nuevo grupo
    try {
        Add-LocalGroupMember -Group $NuevoGrupo -Member $NombreUsuario -ErrorAction Stop
        Write-Host "Usuario agregado al grupo '$NuevoGrupo'." -ForegroundColor Green
    } catch {
        Write-Host "Error al agregar el usuario '$NombreUsuario' al grupo '$NuevoGrupo': $_" -ForegroundColor Red
        return
    }

    # Cambiar el nombre de la carpeta del grupo
    $oldPath = "C:\inetpub\ftproot\$NombreUsuario\$grupoActual"
    $newPath = "C:\inetpub\ftproot\$NombreUsuario\$NuevoGrupo"
    
    if (Test-Path $oldPath) {
        Rename-Item -Path $oldPath -NewName $newPath
        Write-Host "Carpeta de grupo cambiada a '$NuevoGrupo'." -ForegroundColor Yellow
    }

    # Reconfigurar permisos
    Configurar-Permisos -NombreUsuario $NombreUsuario -Grupo $NuevoGrupo
}