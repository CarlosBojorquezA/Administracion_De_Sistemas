# Importar funciones 
. "$PSScriptRoot\funcionesHTTP.ps1"

while($true){
    Write-Output "¿Qué servicio deseas instalar?"
    Write-Output "1. IIS"
    Write-Output "2. Caddy"
    Write-Output "3. Nginx"
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
                Instalar-IIS
            }
            "2"{
                Instalar-Caddy
            }
            "3"{
                Instalar-Nginx
            }
            default{
                Write-Output "Opción no válida."
            }
        }
    }
}
