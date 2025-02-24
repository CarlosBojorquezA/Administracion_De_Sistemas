$num1 = 51

if ($num1 -ge 50)
{
    Write-Host "num1 es mayor que 50"
}
else 

    {
        Write-Host "num1 es menor que 50"
    }

$num1 = 51

    if ($num1 -gt 50) {
        Write-Host "el número $num1 es mayor que 50"
    }
    elseif ($num1 -eq 50) {
        Write-Host "el número $num1 es igual a 50"
    }
    else {
        Write-Host "el número $num1 es menor que 50"
    }
    # switch 1
    switch (4)
    {
        1 {"[$_] es uno"}
        2 {"[$_] es dos"}
        3 {"[$_] es tres"}
        4 {"[$_] es cuatro"}
    }
    # switch 2
    switch (4)
{
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"}
    4 {"[$_] otra vez cuatro"}
}
    # switch 3
switch (4)
{
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"; break}
    4 {"[$_] otra vez cuatro"}
    4 {"[$_] cuatro de nuevo"}
    5 {"[$_] es cinco"}
}

    # switch 4
    switch (1, 4)
{
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"; break}
    4 {"[$_] otra vez cuatro"}
    4 {"[$_] cuatro de nuevo"}
    5 {"[$_] es cinco"}
}

    # switch 5
    switch ("seis")
    {
        1 {"[$_] es uno";break}
        2 {"[$_] es dos";break}
        3 {"[$_] es tres";break}
        4 {"[$_] es cuatro"; break}
        4 {"[$_] otra vez cuatro";break}
        4 {"[$_] cuatro de nuevo";break}
        5 {"[$_] es cinco";break}
        "se* " {"[$_] coincide con se*"}
        default {"[$_] no coincide"}
    }

    # switch 6
    switch -Wildcard ("seis")
{
    1 {"[$_] es uno";break}
    2 {"[$_] es dos";break}
    3 {"[$_] es tres";break}
    4 {"[$_] es cuatro"; break}
    4 {"[$_] otra vez cuatro";break}
    4 {"[$_] cuatro de nuevo";break}
    5 {"[$_] es cinco";break}
    "se*" {"[$_] coincide con [se*]"}
    default {"[$_] no coincide"}
}

    # switch 7
    $email = "carlos@hotmail.com"

switch -Regex ($email) {
    "^[\w\.-]+@gmail\.com$" { Write-Host "el correo pertenece a Gmail" }
    "^[\w\.-]+@outlook\.com$" { Write-Host "el correo pertenece a Outlook" }
    "^[\w\.-]+@yahoo\.com$" { Write-Host "el correo pertenece a Yahoo" }
    "^[\w\.-]+@(hotmail)\.com$" { Write-Host "el correo pertenece a Hotmail" }
    default { Write-Host "el correo no es válido o no pertenece a un dominio" }
}