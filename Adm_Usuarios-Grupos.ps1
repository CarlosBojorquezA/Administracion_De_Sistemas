Get-LocalUser
Get-LocalGroup
New-LocalUser -Name "pito perez" -Password (ConvertTo-SecureString "Password123" -AsPlainText -Force) -FullName "pito perez" -Description "Usuario de prueba"
Remove-LocalUser -Name "pito perez"
Add-LocalGroupMember -Group "Administrators" -Member "pito perez"
Remove-LocalGroupMember -Group "Administrators" -Member "pito perez"