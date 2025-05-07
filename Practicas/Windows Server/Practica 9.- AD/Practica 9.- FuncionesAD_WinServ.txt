function AddOrganization{
    Param([String]$UO)
    New-ADOrganizationalUnit -Name $UO -Path "DC=LUIS,DC=COM"
}
    
function AddUser{ 
    Param([String]$Username,[String]$Password,[String]$UO)
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    New-ADUser -Name $Username -SamAccountName $Username -UserPrincipalName "$Username@luis.com" -ChangePasswordAtLogon $false -AccountPassword $SecurePassword -Path "OU=$UO,DC=LUIS,DC=COM" -Enabled $true
}