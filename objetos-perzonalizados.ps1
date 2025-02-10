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
