    # objetos
    s#get-member
#Get-Service | Get-Member

#Get-Service | Get-Member -MemberType Property

#Get-Service | Get-Member -MemberType Method

#$proceso = Get-Process -Name "notepad"
#$proceso.Id  # muestra el ID del proceso

#$archivo = Get-Item "C:\ejemplo.txt"
#$archivo.Delete()  # borra el archivo



    #select-object
#Get-Process | Select-Object Name, Id

#Get-Process | Select-Object -First 5

#Get-Process | Select-Object -Last 5

#Get-Process | Select-Object -Skip 3



    # where-object
#Get-Service | Where-Object {$_.Status -eq "Running"}

#Get-Process | Where-Object {$_.WorkingSet64 -gt 100MB}

#Get-ChildItem C:\Users\ -Recurse | Where-Object {$_.Extension -eq ".txt"}



    # objetos personalizados
#$miObjeto = New-Object PSObject
#$miObjeto | Add-Member -MemberType NoteProperty -Name "nombre" -Value "carlos"
#$miObjeto | Add-Member -MemberType NoteProperty -Name "edad" -Value 20
#$miObjeto

#$miObjeto = New-Object PSObject -Property @{
#    Nombre = "carlos"
#    Edad = 20
#}
#$miObjeto

$miObjeto = [PSCustomObject]@{
    Nombre = "carlos"
    Edad = 20
}
$miObjeto


    # metodos
$archivo = Get-Item "C:\ejemplo.txt"
$archivo.CopyTo("C:\copia.txt")  # copia el archivo

$archivo.Delete()  # Elimina el archivo



    # pipeline
#Get-Process -Name "Spotify" | Stop-Process

#Get-Process | Where-Object {$_.WS -gt 50MB} | Stop-Process

#Get-Process | Out-File "C:\procesos.txt"

#Get-Service | Stop-Service

#Get-Service | Select-Object -Property Name | Stop-Service