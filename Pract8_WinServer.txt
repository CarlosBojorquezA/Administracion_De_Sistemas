function Configure-ini($lines, $section, $key, $value){

    # Esto configura el archivo de configuración
    $sectionIndex = $lines.IndexOf("[$section]")
    if($sectionIndex -lt 0) {
        $lines += "[$section]", "$key=$value"
    } else {
        $i = $sectionIndex + 1
        $found = $false
        while ($i -lt $lines.Length -and $lines[$i] -notmatch "^\[.*\]"){
            if ($lines[$i] -match "^$key="){
                $lines[$i] = "$key=$value"
                $found = $true
                break
            }
            $i++
        }
        if(-not $found){
            $lines = @(
                $lines[0..$sectionIndex]
                "$key=$value"
                $lines[($sectionIndex + 1)..($lines.Length - 1)]
            )
        }
    }
    return $lines
}

function install-mercury{
    $mercuryURL = "https://download-us.pmail.com/m32-491.exe"
    $mercryFolder = "C:\Mercury"
    $installerPath = "$mercryFolder\MercuryInstall.exe"

    $inipath = "$mercryFolder\mercury.ini"
    $nssmUrls = "https://nssm.cc/release/nssm-2.24.zip"
    $nssmFolder = "$mercryFolder\nssm"

    # Crear la carpeta de instalación
    New-Item -ItemType Directory -Path $mercryFolder -Force | Out-Null

    # Descargar Mercury
    Invoke-WebRequest -Uri $mercuryURL -OutFile $installerPath

    Start-Process -FilePath $installerPath -Wait

    if (-not (Test-Path $inipath)){
        Write-Error "No se encontró el archivo de configuracion, vuelva a ejecutar el script para reinstalar el servicio"
        exit 1 
    }

    # Se edita el archivo de configuracion de Mercury
    $content = Get-Content $inipath

    $content = Configure-ini $content "MercuryS" "TCP/IP_port" "25"
    $content = Configure-ini $content "MercuryP" "TCP/IP_port" "110"
    $content = Configure-ini $content "MercuryP" "POP3Enabled" "1"
    $content = Configure-ini $content "MercuryS" "SMTPEnabled" "1"

    $content | Set-Content $inipath

    Start-Process "C:\Mercury\mercury.exe" # Ejecutar el .exe directamente (Dejar la pestaña abierta).
}

function install-squirrel{
    Install-WindowsFeature -name Web-Server, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Http-Logging, Web-Request-Monitor, Web-Http-Redirect, Web-Filtering, Web-Performance, Web-Stat-Compression, Web-Security, Web-Mgmt-Console -IncludeManagementTools
    
    # Descargar Xammp
    curl.exe -L "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/5.6.14/xampp-portable-win32-5.6.14-4-VC11-installer.exe/download" -o "C:\Users\Administrador\Downloads\xampp-portable-win32-5.6.14-4-VC11-installer.exe"
    Start-Process "C:\Users\Administrador\Downloads\xampp-portable-win32-5.6.14-4-VC11-installer.exe" -Wait
    
    # Descargar squirrelmail
    curl.exe -L "https://sourceforge.net/projects/squirrelmail/files/stable/1.4.22/squirrelmail-webmail-1.4.22.zip/download?use_mirror=psychz" -o "C:\Users\Administrador\Downloads\squirrelmail.zip"

    Expand-Archive -Path "C:\Users\Administrador\Downloads\squirrelmail.zip" -DestinationPath "C:\xampp\htdocs\"
    # Se renombra la carpeta descomprimida a squirrelmail
    Rename-Item -Path C:\xampp\htdocs\squirrelmail-webmail-1.4.22 -NewName "squirrelmail"

    # Renombrar y editar el archivo de configuración
    Rename-Item -Path C:\xampp\htdocs\squirrelmail\config\config_default.php -NewName "config.php"            # Aqui el dominio que se configuro en la instalacion
    (Get-Content "C:\xampp\htdocs\squirrelmail\config\config.php") -replace '\$domain\s*=\s*''[^'']+'';', '$domain = ''ejemplo.com'';' | Set-Content "C:\xampp\htdocs\squirrelmail\config\config.php"
    (Get-Content "C:\xampp\htdocs\squirrelmail\config\config.php") -replace '\$data_dir\s*=\s*''[^'']+'';', '$data_dir = ''C:/xampp/htdocs/squirrelmail/data/'';' | Set-Content "C:\xampp\htdocs\squirrelmail\config\config.php"

    
    Write-Host "Squirrelmail instalado y configurado correctamente."
    # Para probar squirrelmail, se debe abrir xampp e iniciar apache
    # Luego ir al navegador y escribir localhost (o la IP del servidor), squirrelmail
    # Y tener el puerto 80 o 443 libre
}


# Main
while($true){
    Write-Host "Configuracion de servidor de correo, Selecciona una opcion [1-5]"
    Write-Host "1. Instalar Mercury"
    Write-Host "2. Crear usuarios"
    Write-Host "3. Instalar Squirrelmail"
    Write-Host "0. Salir"
    $opc = Read-Host "Ingrese una opción:"

    if($opc -eq "0"){
        Write-Output "Saliendo..."
        break
    } elseif ($opc -notmatch "^\d+$"){
        Write-Output "Debes ingresar un número."
    } else {
        switch($opc){
            '1'{
                install-mercury
            }
            '2'{
                Write-Host "Abre la ventana de Mercury Ve a Configuration -> Magae Local Users -> Add y ahi creas el usuario"
            }
            '3'{
                install-squirrel
            }
            default{
                Write-Host "Opción no válida."
            }
        }
    }
}