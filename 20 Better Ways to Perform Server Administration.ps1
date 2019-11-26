### Basic Configuration tasks ###
#Rename a computer
Rename-Computer
#Restart a computer
Restart-Computer
#Shut down a computer
Stop-Computer
#Determine IP Address
Get-NetIPConfiguration
#Set IP Address
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 172.16.0.20 -PrefixLength 24 -DefaultGateway 172.16.0.1
#Configure DNS Server
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.0.10
#Join a domain
Add-Computer -DomainName igniteNZ.internal

### Basic Diagnostics ###
#Verify Network Adapter Functionality
Get-NetAdapterStatistics
#Verify Network Adapter Connectivity
Test-NetConnection 8.8.8.8 
Test-NetConnection 8.8.8.8 -TraceRoute
Test-NetConnection smtp.com -Port 25
#Repair Trust Relationship
Test-ComputerSecureChannel -Credential domain\admin -Repair
#Error Event Logs
Get-EventLog -LogName System -EntryType Error
#Manage Services
Stop-Service
Start-Service
Restart-Service
Set-Service
Get-Service
Get-Service | Where-Object {$_.Status -eq "Stopped"}
#Add Roles and Features
Install-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools File-Services
#View Installed Updates
Get-HotFix


### Firewall Basics ###
#Add Firewall Rules Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
#Add Firewall Rules Block
New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Block

### Virtual Machine Basics ###
#Create a new VM from a sysprepped VHD
New-VM -MemoryStartupBytes 2048MB -Name NZ-VM -Path "D:\NZ-VM" -VHDPath "D:\NZ-VM\disk.vhdx"
#Assign VM etwrk Adapter to Virtual Switch
Get-VM -name NZ* | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -Switchname 'Private Network' 


### Active Directory Management ###
#Ready a secure password
$newpwd = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
#New User
New-ADUser -Name Don.Funk -AccountPassword $newpwd
#Enable New User
Enable-ADAccount -Identity Don.Funk
#Reset Password & Force Change
Set-ADAccountPassword Don.Funk -NewPassword $newpwd -Reset -PassThru | Set-ADUser -ChangePasswordAtLogon $True 
#New Group
New-ADGroup -Name "Aucklanders" -SamAccountName Aucklanders -GroupCategory Security -GroupScope Global -Path "CN=Users,DC=IgniteNZ,DC=Internal"
#Search for accounts with non-expiring passwords
Search-ADAccount -PasswordNeverExpires
#Search for accounts that haven't signed-on for 90 days
Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00
#Search for locked out accounts
Search-ADAccount -LockedOut
#Search for disabled accounts
Search-ADAccount -SearchBase "OU=Ukrcatalog,DC=ukrcatalog,DC=com" -AccountDisabled | Select-Object -Property Name,LastLogonDate

### ISE Snippets ###
#Secure Password Snippet
New-IseSnippet -Force -Title "Password_Srting" -Description "Secure Password String" -Text "`$newpwd = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force"

### DNS Management ###
#New DNS Primary Zone
Add-DnsServerPrimaryZone -Name "westisland.ignitenz.internal" -ReplicationScope Forest -PassThru
#New Record
Add-DnsServerResourceRecordA -Name "wellington" -ZoneName "igniteNZ.internal" -AllowUpdateAny -IPv4Address "172.18.99.23" -TimeToLive 01:00:00

### DHCP Management ###
#New Scope
Add-DhcpServerv4Scope -Name "Alpha-Scope" -StartRange 172.16.0.0 -EndRange 172.16.0.254 -SubnetMask 255.255.255.0
#New Reservation
Add-DhcpServerv4Reservation -ComputerName domaincontrol.igniteNZ.internal -ScopeId 172.16.0.0 -IPAddress 172.16.0.200 -ClientId F0-DE-F1-7A-00-5E -Description "Reservation for Printer"
#New Scope Setting - DNS
Set-DhcpServerv4OptionValue -ComputerName domaincontrol.igniteNZ.internal -ScopeId 172.16.0.0 -OptionId 006 -Value "172.16.0.10"
#New Scope Setting - Gateway
Set-DhcpServerv4OptionValue -ComputerName domaincontrol.igniteNZ.internal -ScopeId 172.16.0.0 -OptionId 003 -Value "172.16.0.1"

#New File Share
New-SmbShare -Name SharedFolder -Path C:\SharedFolder -FullAccess IgniteNZ\Admin -ReadAccess IgniteNZ\User
