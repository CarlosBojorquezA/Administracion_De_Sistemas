$email = "carlos@hotmail.com"

switch -Regex ($email) {
    "^[\w\.-]+@gmail\.com$" { Write-Host "el correo pertenece a Gmail" }
    "^[\w\.-]+@outlook\.com$" { Write-Host "el correo pertenece a Outlook" }
    "^[\w\.-]+@yahoo\.com$" { Write-Host "el correo pertenece a Yahoo" }
    "^[\w\.-]+@(hotmail)\.com$" { Write-Host "el correo pertenece a Hotmail" }
    default { Write-Host "el correo no es válido o no pertenece a un dominio" }
}
