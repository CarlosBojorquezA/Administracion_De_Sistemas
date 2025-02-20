# 1 -eq "1.0"

# "1.0" -eq 1

for (($i = 0), ($j = 0 ); $i -lt 5; $i++ )
{
    "'$i :$i"
    "'$j :$j"
}

$numeros = 1,2,3,4,5
foreach ($num in $numeros) {
   Write-Host "Número: $num"
}

$contador = 1
while ($contador -le 7) {
    Write-Host "Contador: $contador"
    $contador++
}

$contador = 1
while ($true) {
    Write-Host "hola mundo"
    if ($contador -eq 2025) { break }
    $contador++
}

$contador = 1
do {
   Write-Host "valor: $contador"
    $contador++
} while ($contador -le 7)

$contador = 1
do {
    Write-Host "Valor: $contador"
    $contador++
} until ($contador -gt 5)


 # declaraciones break 
for ($i=1; $i -le 10; $i++) {
    if ($i -eq 5) { break }
    Write-Host "numero: $i"
}

switch (4) {
    1 { Write-Host "uno" }
    2 { Write-Host "dos" }
    3 { Write-Host "tres"; break }
    4 { Write-Host "cuatro" }
}


    # declaraciones continue
for ($i=1; $i -le 5; $i++) {
    if ($i -eq 3) { continue }
    Write-Host "numero: $i"
}

switch (4) {
    1 { Write-Host "uno" }
    2 { Write-Host "dos" }
    3 { continue }
    4 { Write-Host "cuatro" }
}