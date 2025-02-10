$archivo = Get-Item "C:\ejemplo.txt"
$archivo.CopyTo("C:\copia.txt")  # copia el archivo

$archivo.Delete()  # Elimina el archivo


