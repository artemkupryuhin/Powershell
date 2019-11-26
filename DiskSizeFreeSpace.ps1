#Get disk size and free space
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

$SrvList = "STR","WDS", "DC1","DC2","TS","BDS","SRV-BUH","SPARK",
           "HYPERV01", "HYPERV02", "HYPERV03", "HYPERV04", "DHCP01", "DHCP02"
$linenumber = 1
$data = foreach ($Srv in $SrvList)  { Get-WmiObject win32_logicaldisk -ComputerName $Srv | Where-Object { $_.MediaType -eq 12 } |
		ForEach-Object { New-Object psObject -Property @{'LineNumber'=$linenumber;'PSComputerName'= $_.PSComputerName; 'DeviceId' = $_.DeviceId; 'Size' = $_.Size; 'FreeSpace' = $_.FreeSpace };$linenumber ++} |
		Select-Object	@{Name='RowNum';Expression={$_.LineNumber}},
						@{Name='Computer Name';Expression={$_.PSComputerName}},
						@{Name='Disk';Expression={$_.DeviceId}},
  						@{Name='Disk Size, GB'; Exp={[math]::Round($_.Size /1GB,2)}},
  						@{Name='Free Space, GB'; Exp={[math]::Round($_.FreeSpace /1GB,2)}},
  						@{Name='Used Space, GB'; Exp={[math]::Round(($_.Size - $_.FreeSpace) /1GB,2)}},
						@{Name='Used Space, %'; Exp={[math]::Round((($_.Size - $_.FreeSpace) /$_.Size)*100,2)}}
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

$fragments+= "<h1>Disk's size</h1>"

[xml]$html = $data | convertto-html -Fragment
	for ($i=1;$i -le $html.table.tr.count-1;$i++) {
	if ($html.table.tr[$i].td[6] -ge 85) {
		$class = $html.CreateAttribute("class")
		$class.value = 'alert'
		#To highlight the table cell in red:
		#$html.table.tr[$i].childnodes[6].attributes.append($class) | out-null
        #To highlight the entire row in red:
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

#sendmessage_telegram  576450868 $BodyText

SendEmail "(Укркаталог) PS Report -  Disk's Size" $BodyText