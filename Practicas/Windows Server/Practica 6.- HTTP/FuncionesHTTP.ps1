# Función para instalar IIS
function Instalar-IIS {
    if(-not(Get-WindowsFeature -Name Web-Server).Installed){
        Write-Output "Instalando el servicio IIS..."
        Install-WindowsFeature -Name Web-Server
    }
    else{
        Write-Output "IIS ya se encuentra instalado."
    }
}

# Función para instalar Caddy
function Instalar-Caddy {
    $page_Caddy = Invoke-RestMethod "https://api.github.com/repos/caddyserver/caddy/releases"
    $versionsCaddy = $page_Caddy
    $ltsVersion = $versionsCaddy[6].tag_name
    $devVersion = $versionsCaddy[0].tag_name
    Write-Output "¿Qué versión de Caddy deseas instalar?"
    Write-Output "1. Última versión LTS $ltsVersion"
    Write-Output "2. Versión de desarrollo $devVersion"
    Write-Output "0. Salir"
    $OPCION_CADDY = Read-Host "Elige una opción"

    if ($OPCION_CADDY -eq "1" -or $OPCION_CADDY -eq "2") {
        $PORT = Obtener-Puerto
        if ($PORT -ne $null) {
            Instalar-Caddy-Versión -version $ltsVersion -port $PORT
        }
    }
}

# Función para instalar Nginx
function Instalar-Nginx {
    Write-Output "Instalando Nginx..."
    $downloadsNginx = "https://nginx.org/en/download.html"
    $page_Nginx = (Get-HTML -url $downloadsNginx)
    $versionsNginx = (get-version-format -page $page_Nginx)
    $ltsVersion = $versionsNginx[1]
    $devVersion = $versionsNginx[0]

    Write-Output "¿Qué versión de Nginx deseas instalar?"
    Write-Output "1. Última versión LTS $ltsVersion"
    Write-Output "2. Versión de desarrollo $devVersion"
    Write-Output "0. Salir"
    $OPCION_NGINX = Read-Host "Elige una opción"

    if ($OPCION_NGINX -eq "1" -or $OPCION_NGINX -eq "2") {
        $PORT = Obtener-Puerto
        if ($PORT -ne $null) {
            Instalar-Nginx-Versión -version $ltsVersion -port $PORT
        }
    }
}

# Función para obtener el puerto
function Obtener-Puerto {
    $PORT = Read-Host "Ingresa el puerto donde se realizará la instalación"
    if ($PORT -notmatch "^\d+$") {
        Write-Output "Debes ingresar un número."
        return $null
    } elseif ($PORT -lt 1023 -or $PORT -gt 65536) {
        Write-Output "Puerto no válido, debe estar entre 1024 y 65535."
        return $null
    } elseif (VerifyPortsReserved -port $PORT) {
        Write-Host "El puerto $PORT está reservado para otro servicio."
        return $null
    }
    return $PORT
}

# Función para instalar la versión LTS de Caddy
function Instalar-Caddy-Versión {
    param (
        [string]$version,
        [int]$port
    )
    Stop-Process -Name caddy -ErrorAction SilentlyContinue
    $versionClean = (quit-V -version "$version")
    Invoke-WebRequest -UseBasicParsing "https://github.com/caddyserver/caddy/releases/download/$version/caddy_${versionClean}_windows_amd64.zip" -Outfile "C:\Descargas\caddy-$version.zip"
    Expand-Archive C:\Descargas\caddy-$version.zip C:\Descargas -Force
    cd C:\Descargas
    New-Item c:\Descargas\Caddyfile -type file -Force
    Add-Content -Path "C:\Descargas\Caddyfile" -Value ":$port"
    Start-Process -NoNewWindow -FilePath "C:\descargas\caddy.exe" -ArgumentList "run --config C:\descargas\Caddyfile"
    netsh advfirewall firewall add rule name="Caddy" dir=in action=allow protocol=TCP localport=$port
}

# Función para instalar la versión de Nginx
function Instalar-Nginx-Versión {
    param (
        [string]$version,
        [int]$port
    )
    Stop-Process -Name nginx -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing "https://nginx.org/download/nginx-$version.zip" -Outfile "C:\Descargas\nginx-$version.zip"
    Expand-Archive C:\Descargas\nginx-$version.zip C:\Descargas -Force
    cd C:\Descargas\nginx-$version
    Start-Process nginx.exe
    (Get-Content C:\Descargas\nginx-$version\conf\nginx.conf) -replace "listen       [0-9]{1,5}", "listen       $port" | Set-Content C:\Descargas\nginx-$version\conf\nginx.conf
    Select-String -Path "C:\descargas\nginx-$version\conf\nginx.conf" -Pattern "listen       [0-9]{1,5}"
}

# Función para obtener el HTML de la página
function Get-HTML {
    param (
        [string]$url
    )
    return Invoke-WebRequest -UseBasicParsing -Uri $url
}

# Función para obtener las versiones en formato adecuado
function get-version-format {
    param (
        [string]$page
    )
    $format = "\d+\.\d+\.\d+"
    $versiones = [regex]::Matches($page, $format) | ForEach-Object {$_.Value}
    return $versiones | Sort-Object { [System.Version]$_ } -Descending | Get-Unique
}

# Función para limpiar versiones de Caddy y Nginx
function quit-V([string]$version) {
    return $version -replace "^v", ""
}

# Verificar puertos reservados
$puertosReservados = @(
    @{ Servicio = "FTP"; Puerto = 21 },
    @{ Servicio = "SSH"; Puerto = 22 },
    @{ Servicio = "Telnet"; Puerto = 23 },
    @{ Servicio = "HTTP"; Puerto = 80 },
    @{ Servicio = "HTTPS"; Puerto = 443 },
    @{ Servicio = "SMTP"; Puerto = 25 },
    @{ Servicio = "MySQL"; Puerto = 3306 },
    @{ Servicio = "SQL Server"; Puerto = 1433 }
)

function VerifyPortsReserved {
    param (
        [int]$port
    )

    $puertoEncontrado = $puertosReservados | Where-Object { $_.Puerto -eq $port}

    if ($puertoEncontrado) {
        return $true
    } else {
        return $false
    }
}
