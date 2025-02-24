#function ejemplo {
#    Write-Host "hola mundo"
#}

#ejemplo 

# funcion con parametros
#function ejemplo2 {
#    param (
#        [string]$Nombre
#    )
#    Write-Host "hola $Nombre!"
#}

#ejemplo2 -Nombre "carlos"

#function ejemplo3 {
#    param (
#        [string]$Nombre = "amigo"
#    )
#    Write-Host "hola $Nombre!"
#}

#ejemplo3   # Usa "amigo" por defecto
#ejemplo3 -Nombre "carlos"  # Usa el valor proporcionado

#function Sumar {
#    param (
#        [int]$Num1,
#        [int]$Num2
#    )
#    $Resultado = $Num1 + $Num2
#    Write-Host "resultado: $Resultado"
#}

#Sumar -Num1 5 -Num2 10

# tipos de parametros

#function Multiplicar {
#    param (
#        [int]$Num1,
#        [int]$Num2
#    )
#    $Resultado = $Num1 * $Num2
#    Write-Host "resultado: $Resultado"
#}

#Multiplicar 5 3  

#function MostrarMensaje {
#    param (
#        [Parameter(Mandatory=$true)]
#        [string]$Mensaje
#    )
#    Write-Host "mensaje: $Mensaje"
#}

#MostrarMensaje -Mensaje "voy pasar la materia Sysadmin"


# Funciones avanzadas

#function Get-Fecha {
#    [CmdletBinding()]
#    param ()
#    Write-Host "hoy es $(Get-Date)"
#}

#Get-Fecha -Verbose

#function Prueba-Verbose {
#    [CmdletBinding()]
#    param (
#        [string]$Mensaje
#    )
#    Write-Verbose "mensaje: $Mensaje"
#}

#Prueba-Verbose -Mensaje "hola" -Verbose

#function Dividir {
#    param (
#        [int]$Num1,
#        [int]$Num2
#    )
#    try {
#        $Resultado = $Num1 / $Num2
#        Write-Host "resultado: $Resultado"
#    } catch {
#        Write-Host "error: no es posible dividir por cero"
#    }
#}

#Dividir -Num1 10 -Num2 0  # manejo de errores

