Function SendEmail ($Subject,$Body) {
# smtp server
$emailSmtpServer = "str.ukrcatalog.com"
$emailSmtpServerPort = "587"
# recipient 
$emailFrom = "it-support@ukrcatalog.com.ua"
$emailTo = "admin@ukrcatalog.com.ua"
# message
$emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
$emailMessage.Subject = $Subject
$emailMessage.IsBodyHtml = $true
$emailMessage.Body = $Body
# client 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.Send( $emailMessage )     
}

$ExcludeListAccount = @(
    
    "SystemMailbox{1f05a927-50f3-4e10-a204-cae6a05d3fb4}",
    "SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9}",
    "SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9}",
    "DiscoverySearchMailbox {D919BA05-46A6-415f-80AD-7E09334BB852}",
    "FederatedEmail.4c1f4d8b-8179-4148-93bf-00a95fa1e042",
    "Guest",
    "krbtgt",
    "mailer",
    "EXCHANGE$",
    "SM_42a3872682a84ca5a",
    "SM_42a3872682a84ca5a",
    "SM_8f186941ed9244dc9",
    "SM_34771bbff8464169b",
    "SM_c351df776da54e00b"
)


$linenumber1 = 1

#Search for accounts that haven't signed-on for 30 days
$data1 = Search-ADAccount -AccountInactive -TimeSpan 30.00:00:00 | Where-Object { $_.Samaccountname -notin $ExcludeListAccount } |
         ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber1;'Samaccountname'= $_.Samaccountname; 'ObjectClass' = $_.ObjectClass; 'Lastlogondate' = $_.Lastlogondate };$linenumber1 ++} |
		 Select-Object	@{Name='RowNum';Expression={$_.LineNumber}},
						@{Name='Samaccountname';Expression={$_.Samaccountname}},
						@{Name='ObjectClass';Expression={$_.ObjectClass}},
                        @{Name='Lastlogondate';Expression={$_.Lastlogondate}}
  						
$linenumber2 = 1
#Search for disabled accounts
$data2 = Search-ADAccount -SearchBase "DC=ukrcatalog,DC=com" -AccountDisabled | Where-Object { $_.Samaccountname -notin $ExcludeListAccount } |
         ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber2;'Name'= $_.Name; 'Lastlogondate' = $_.Lastlogondate };$linenumber2 ++} |
		 Select-Object	@{Name='RowNum';Expression={$_.LineNumber}},
						@{Name='Name';Expression={$_.Name}},
                        @{Name='Lastlogondate';Expression={$_.Lastlogondate}}

$linenumber3 = 1
#Search users created last 7 days
$When = ((Get-Date).AddDays(-7)).Date 
$data3 = Get-ADUser -Filter {whenCreated -ge $When} -Properties Name, whenCreated | 
         ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber3;'Name'= $_.Name; 'whenCreated' = $_.whenCreated };$linenumber3 ++} |
         Select-Object	@{Name='RowNum';Expression={$_.LineNumber}},
						@{Name='Name';Expression={$_.Name}},
                        @{Name='whenCreated';Expression={$_.whenCreated}} |
         Sort-Object whenCreated

$linenumber4 = 1
#Search users are member of the Domain Admins group
$sid=(Get-ADDomain).DomainSid.Value + '-512'
$data4 = Get-ADGroupMember -identity $sid | 
         ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber4;'Name'= $_.Name; 'SamAccountName' = $_.SamAccountName; 'objectClass'=$_.objectClass};$linenumber4 ++} |
         Select-Object	@{Name='RowNum';Expression={$_.LineNumber}},
						@{Name='Name';Expression={$_.Name}},
                        @{Name='SamAccountName';Expression={$_.SamAccountName}},
                        @{Name='objectClass';Expression={$_.objectClass}}|
         Sort-Object Name
  
$fragments = @()

#Insert logo
$ImagePath = "D:\IT\Install\logo_ukrcatalog.png"
$ImageBits =  [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
$ImageFile = Get-Item $ImagePath
$ImageType = $ImageFile.Extension.Substring(1)
$ImageTag = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='250' height='120' hspace=10>"
$fragments+= $ImageTag
$fragments+= "<br><br>"

$fragments+= "<h1>Accounts that haven't signed-on for 30 days</h1>"
[xml]$html = $data1 | convertto-html -Fragment

$fragments+= $html.InnerXml
$fragments+= "<h1>Disabled accounts</h1>"
[xml]$html = $data2 | convertto-html -Fragment
	
$fragments+= $html.InnerXml
$fragments+= "<h1>Users created last 7 days</h1>"
[xml]$html = $data3 | convertto-html -Fragment

$fragments+= $html.InnerXml
$fragments+= "<h1>List Domain Admins</h1>"
[xml]$html = $data4 | convertto-html -Fragment

$fragments+= $html.InnerXml
$fragments+= "<p class='footer'>$(Get-Date -Format g)</p>"

$convertParams = @{
head = @"
<style>
body { background-color:#E5E4E2; font-family:Monospace; font-size:10pt; }
td, th { border:0px  black; border-collapse:collapse; white-space:pre; text-align: center; }
th { color:white; background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px ;white-space:pre; }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px;}
h1 { text-align: center; font-family:Tahoma; color:#6D7B8D; }
.alert { color: red; }
.footer { color:green; margin-left:25px; font-family:Tahoma; font-size:8pt; }
</style>
"@
body = $fragments
}

$BodyText = convertto-html @convertParams

#sendmessage_telegram  576450868 $BodyText

SendEmail "(Укркаталог) PS Report -  Analyze AD" $BodyText