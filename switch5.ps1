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
