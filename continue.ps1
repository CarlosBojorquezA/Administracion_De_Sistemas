#for ($i=1; $i -le 5; $i++) {
#    if ($i -eq 3) { continue }
#    Write-Host "numero: $i"
#}

switch (4) {
    1 { Write-Host "uno" }
    2 { Write-Host "dos" }
    3 { continue }
    4 { Write-Host "cuatro" }
}

