Function SendEmail ($Subject,$Body) {
    $EmailFrom = "it-support@ukrcatalog.com.ua"
	$EmailTo = "admin@ukrcatalog.com.ua"
	$SMTPServer = "str.ukrcatalog.com"
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body) 
}

#Get external ip
$ip = Invoke-RestMethod http://ipinfo.io/json | Select-Object -exp ip

$Echocount= 20
$Con = Test-Connection 8.8.8.8 -count $Echocount
$Average = ($Con.ResponseTime | Measure-Object -Average).Average
$Lost = (($Echocount-($Con.count))/$Echocount)*100

if ($Lost -ge 0) { 
    SendEmail "(Bad Internet Connection. Exist Lost Packets." "Date time - $(Get-Date)`nPackets count - $Echocount`nResponseTime - $Average ms`nLost Packets - $Lost%`nExternal IP - $ip" 
}