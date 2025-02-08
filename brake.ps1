#for ($i=1; $i -le 10; $i++) {
#    if ($i -eq 5) { break }
#    Write-Host "numero: $i"
#}

switch (4) {
    1 { Write-Host "uno" }
    2 { Write-Host "dos" }
    3 { Write-Host "tres"; break }
    4 { Write-Host "cuatro" }
}

