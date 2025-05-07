. C:\Users\Administrador\Documents\Funciones_AD.ps1

Write-Host "Configuracion de organizaciones active directory"

$ciclo = $true

while($ciclo){
    Write-Host "=== MENU DE OPCIONES ==="
    Write-Host "1. Crear una organizacion de AD"
    Write-Host "2. Crear usuario dentro de una organizacion AD"
    Write-Host "3. Salir"

    $opc = Read-Host "Elija una opcion"

    switch ($opc){
        1{
            $UO = Read-Host "ingrese el nombre de su unidad organizativa"
            while($UO -eq "" -or $UO -like "* *" -or $User.Length -gt 15){
                Write-Host "Nombre de unidad organizativa invalido"
                $UO = Read-Host "Ingrese el nombre de su unidad organizativa"
            }
        }
        2{
            $User = Read-Host "ingrese el nombre de su usuario, por ejemplo "
            while($User -eq "" -or $User -like "* *" -or $User.Length -gt 15 ){
                Write-Host "Nombre de usuario invalido este no debe tener espacios en blanco y al menos un caracter"
                $User = Read-Host "ingrese de nuevo el nombre de usuario"
            }
            $Password = Read-Host "ingrese la contraseña de su usuario"
            while($Password -eq "" -or $Password -like "* *"){
                Write-Host "Contraseña invalida asegurese de que la contraseña no contenga espacios en blanco"
                $Password = Read-Host "ingrese la contraseña de su usuario"
            }
            $UO = Get-ADOrganizationalUnit -Filter 'Name -notlike "Domain Controllers"'| Select-Object Name
            $OU = @()
            $i = 1
            foreach($GetUO in $UO){
                Write-Host "$i) $($GetUO.Name)"
                $OU += $($GetUO.Name)
                $i++
            }
            $opc = Read-Host "Seleccione una unidad organizativa para el usuario"
            $OrgUnit = $OU[$opc -1]
            Write-Host $OrgUnit
        }
        3{
            Write-Host "Saliendo......"
            $ciclo = $false
        }
        default{
            Write-Host "Opción no válida"
        }
    }
}