# Funcion para integrar SSL a los servicios HTTP
function Configurar-SSL {
    param (
        [string]$servicio
    )
    Write-Output "Configurando SSL para $servicio..."
    # Generar certificado auto firmado
    $cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My"
    $thumbprint = $cert.Thumbprint

    # Configurar SSL según el servicio
    switch ($servicio) {
        "IIS" {
            # Configurar SSL en IIS
            Import-Module WebAdministration
            New-WebBinding -Name "Default Web Site" -Protocol "https" -Port 443 -IPAddress "*" -SslFlags 1
            $binding = Get-WebBinding -Name "Default Web Site" -Protocol "https"
            $binding.AddSslCertificate($thumbprint, "My")
            Write-Output "SSL configurado en IIS."
        }
        "Caddy" {
            # Configurar SSL en Caddy
            Add-Content -Path "C:\Descargas\Caddyfile" -Value "tls self_signed"
            Write-Output "SSL configurado en Caddy."
        }
        "Nginx" {
            # Configurar SSL en Nginx
            $nginxConf = "C:\Descargas\nginx-$version\conf\nginx.conf"
            (Get-Content $nginxConf) -replace "listen       \d+", "listen       443 ssl" | Set-Content $nginxConf
            Add-Content -Path $nginxConf -Value "ssl_certificate cert.pem;`nssl_certificate_key cert.key;"
            Write-Output "SSL configurado en Nginx."
        }
    }
}

# Funcion nueva para la pregunta de la integracion de SSL
function Preguntar-SSL {
    param (
        [string]$servicio
    )
    $sslOption = Read-Host "¿Deseas activar SSL para $servicio? (s/n)"
    if ($sslOption -eq "s") {
        Configurar-SSL -servicio $servicio
    }
}


# Funcion para la instalacion y configuracion de servicios HTTP desde el servidor FTP
function Instalar-Desde-FTP {
    param (
        [string]$servicio
    )
    $ftpServer = Read-Host "Ingresa la dirección del servidor FTP"
    $ftpUser = Read-Host "Ingresa el usuario FTP"
    $ftpPassword = Read-Host "Ingresa la contraseña FTP" -AsSecureString
    $ftpPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ftpPassword))

    # Conectar al servidor FTP
    $ftpRequest = [System.Net.FtpWebRequest]::Create("ftp://$ftpServer/http/Windows/")
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPassword)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftpRequest.GetResponse()
    $stream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $carpetas = $reader.ReadToEnd() -split "`r`n"
    $reader.Close()
    $response.Close()

    # Mostrar carpetas disponibles
    Write-Output "Carpetas disponibles:"
    for ($i = 0; $i -lt $carpetas.Length; $i++) {
        Write-Output "$i. $($carpetas[$i])"
    }
    $carpetaIndex = Read-Host "Selecciona el número de la carpeta del servicio"
    $carpeta = $carpetas[$carpetaIndex]

    # Listar archivos en la carpeta seleccionada
    $ftpRequest = [System.Net.FtpWebRequest]::Create("ftp://$ftpServer/http/Windows/$carpeta")
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPassword)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftpRequest.GetResponse()
    $stream = $response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $archivos = $reader.ReadToEnd() -split "`r`n"
    $reader.Close()
    $response.Close()

    # Mostrar archivos disponibles
    Write-Output "Archivos disponibles:"
    for ($i = 0; $i -lt $archivos.Length; $i++) {
        Write-Output "$i. $($archivos[$i])"
    }
    $archivoIndex = Read-Host "Selecciona el número del archivo a descargar"
    $archivo = $archivos[$archivoIndex]

    # Descargar el archivo
    $localPath = "C:\Descargas\$archivo"
    $ftpRequest = [System.Net.FtpWebRequest]::Create("ftp://$ftpServer/http/Windows/$carpeta/$archivo")
    $ftpRequest.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPassword)
    $ftpRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $response = $ftpRequest.GetResponse()
    $stream = $response.GetResponseStream()
    $fileStream = [System.IO.File]::Create($localPath)
    $stream.CopyTo($fileStream)
    $fileStream.Close()
    $stream.Close()
    $response.Close()

    Write-Output "Archivo descargado: $localPath"
    return $localPath
}

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
    $installOption = Read-Host "¿Deseas instalar desde Web o FTP? (web/ftp)"
    if ($installOption -eq "ftp") {
        $localPath = Instalar-Desde-FTP -servicio "Caddy"
        if ($localPath) {
            Expand-Archive $localPath "C:\Descargas\caddy" -Force
            Write-Output "Caddy instalado desde FTP."
        }
    } else {
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
}

# Función para instalar Nginx
function Instalar-Nginx {
    $installOption = Read-Host "¿Deseas instalar desde Web o FTP? (web/ftp)"
    if ($installOption -eq "ftp") {
        $localPath = Instalar-Desde-FTP -servicio "Nginx"
        if ($localPath) {
            Expand-Archive $localPath "C:\Descargas\nginx" -Force
            Write-Output "Nginx instalado desde FTP."
        }
    } else {
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