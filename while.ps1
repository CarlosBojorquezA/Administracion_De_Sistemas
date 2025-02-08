#$contador = 1
#while ($contador -le 7) {
#    Write-Host "Contador: $contador"
#    $contador++
#}

$contador = 1
while ($true) {
    Write-Host "hola mundo"
    if ($contador -eq 2025) { break }
    $contador++
}
