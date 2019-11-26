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


# Exclude this computers
$ExcludePC = 'WIN7-32BIT','WIN8-32BIT','WIN8-64BIT','WIN10-32BIT','WIN10-64BIT','Profile-CC',
             'WIN2012-TEST','PC-CrProfiles','WIN7-TEST','WIN10-TEST64','WIN8-TEST64','WIN7-TEST64',
             'WIN10-TEST','WIN8-TEST', 'ANDREWPC'

#Get computers from AD
$FileServers = Get-ADComputer -Filter * -SearchBase "DC=ukrcatalog,DC=com" | 
               Where-Object { $_.Name -notin $ExcludePC } |
               Select-Object -ExpandProperty Name

$linenumber = 1
$data = ForEach ($Computer in $FileServers)
{
   Try
      {
        if (Test-Connection $Computer -Quiet) 
            { Get-CimInstance -ClassName SoftwareLicensingProduct -computerName $Computer | Where-Object PartialProductKey | 
              ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber;'PSComputerName'= $_.PSComputerName; 'OS' = $_.Name; 'LicenseStatus' = $_.LicenseStatus };$linenumber ++} |
              Select-Object @{Name='RowNum';Expression={$_.LineNumber}},
                            @{Name='PC';Exp={$_.PSComputerName}},
                            @{Name='OS';Exp={$_.OS}},
                            @{Name='LicenseStatus';
                            Exp={ switch ($_.LicenseStatus)
                                        {
                                          0 {'Unlicensed'}
                                          1 {'Licensed'}
                                          2 {'OOBGrace'}
                                          3 {'OOTGrace'}
                                          4 {'NonGenuineGrace'}
                                          5 {'Notification'}
                                          6 {'ExtendedGrace'}
                                          Default {'Undetected'}
                                         }
                                      }
            }     
       }
}      
    Catch
         {
             #Add-Content $UnavailableComputersLog $Computer
         }
}

$fragments = @()

#Insert logo
$ImagePath = "D:\IT\Install\logo_ukrcatalog.png"
$ImageBits =  [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
$ImageFile = Get-Item $ImagePath
$ImageType = $ImageFile.Extension.Substring(1)
$ImageTag = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='250' height='120' hspace=10>"
$fragments+= $ImageTag
$fragments+= "<br><br>"

$fragments+= "<h1>Check Windows Activation Status</h1>"

[xml]$html = $data | convertto-html -Fragment
	for ($i=1;$i -le $html.table.tr.count-1;$i++) {
	if ($html.table.tr[$i].td[3] -notin ('Licensed') ) {
		$class = $html.CreateAttribute("class")
		$class.value = 'alert'
		#To highlight the table cell in red:
		#$html.table.tr[$i].childnodes[6].attributes.append($class) | out-null
        #To highlight the entire row in red:
		$html.table.tr[$i].attributes.append($class) | out-null
	}
	}
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

SendEmail "PS Report -  Check Windows Activation Status" $BodyText