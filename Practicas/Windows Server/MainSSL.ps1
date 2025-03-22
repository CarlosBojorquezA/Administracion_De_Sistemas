# Importar funciones
. "$PSScriptRoot\FuncionesSSL.ps1"

while($true){
    Write-Output "¿Desde dónde deseas instalar los servicios?"
    Write-Output "1. Desde la Web"
    Write-Output "2. Desde FTP"
    Write-Output "0. Salir"
    $opc = Read-Host "Selecciona una opción"

    if($opc -eq "0"){
        Write-Output "Saliendo..."
        break
    } elseif ($opc -notmatch "^\d+$"){
        Write-Output "Debes ingresar un número."
    } else {
        switch($opc){
            "1"{
               while($true){
        Write-Output "¿Qué servicio deseas instalar desde la Web?"
        Write-Output "1. IIS"
        Write-Output "2. Caddy"
        Write-Output "3. Nginx"
        Write-Output "0. Volver al menú principal"
        $opc = Read-Host "Selecciona una opción"

        if($opc -eq "0"){
            break
        } elseif ($opc -notmatch "^\d+$"){
            Write-Output "Debes ingresar un número."
        } else {
            switch($opc){
                "1"{
                    Instalar-IIS
                    Preguntar-SSL -servicio "IIS"
                }
                "2"{
                    Instalar-Caddy
                    Preguntar-SSL -servicio "Caddy"
                }
                "3"{
                    Instalar-Nginx
                    Preguntar-SSL -servicio "Nginx"
                }
                default{
                    Write-Output "Opción no válida."
                }
            }
        }
    }
            }
            "2"{
                while($true){
        Write-Output "¿Qué servicio deseas instalar desde FTP?"
        Write-Output "1. IIS"
        Write-Output "2. Caddy"
        Write-Output "3. Nginx"
        Write-Output "0. Volver al menú principal"
        $opc = Read-Host "Selecciona una opción"

        if($opc -eq "0"){
            break
        } elseif ($opc -notmatch "^\d+$"){
            Write-Output "Debes ingresar un número."
        } else {
            switch($opc){
                "1"{
                    $localPath = Instalar-Desde-FTP -servicio "IIS"
                    if ($localPath) {
                        # Lógica para instalar IIS desde el archivo descargado
                        Write-Output "Instalando IIS desde $localPath..."
                        # Aquí iría el código para ejecutar el instalador de IIS
                    }
                    Preguntar-SSL -servicio "IIS"
                }
                "2"{
                    $localPath = Instalar-Desde-FTP -servicio "Caddy"
                    if ($localPath) {
                        # Lógica para instalar Caddy desde el archivo descargado
                        Write-Output "Instalando Caddy desde $localPath..."
                        Expand-Archive $localPath "C:\Descargas\caddy" -Force
                    }
                    Preguntar-SSL -servicio "Caddy"
                }
                "3"{
                    $localPath = Instalar-Desde-FTP -servicio "Nginx"
                    if ($localPath) {
                        # Lógica para instalar Nginx desde el archivo descargado
                        Write-Output "Instalando Nginx desde $localPath..."
                        Expand-Archive $localPath "C:\Descargas\nginx" -Force
                    }
                    Preguntar-SSL -servicio "Nginx"
                }
                default{
                    Write-Output "Opción no válida."
                }
            }
        }
    }
            }
            default{
                Write-Output "Opción no válida."
            }
        }
    }
}