#Get-Service | Where-Object {$_.Status -eq "Running"}

#Get-Process | Where-Object {$_.WorkingSet64 -gt 100MB}

Get-ChildItem C:\Users\ -Recurse | Where-Object {$_.Extension -eq ".txt"}
