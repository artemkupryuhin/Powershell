# Get last logon date for Ad user
Get-ADUser "OU=EXMO,DC=exmo,DC=lan" -Filter * -Properties "Name","LastLogonDate" | Select-Object Name, LastLogonDate | Sort-Object Name