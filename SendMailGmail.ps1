
function SendMail ($Subject, $Body) 

# Create a file with the encrypted server password:

# In Powershell, enter the following command (replace myPassword with your actual password):
# "myPassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "D:\EmailPassword.txt"
# Create a powershell script (Ex. sendEmail.ps1):

{
    $User = "tech.service.alarm@gmail.com"
    $File = "D:\EmailPassword.txt"
    $cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
    $EmailTo = "kupryuhin.a@exmo.com"
    $EmailFrom = "tech.service.alarm@gmail.com"
    #$Subject = "Email Subject" 
    #$Body = "Email body text" 
    $SMTPServer = "smtp.gmail.com" 
    #$filenameAndPath = "D:\fileIwantToSend.csv"
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPMessage.IsBodyHtml= $true
    #$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    #$SMTPMessage.Attachments.Add($attachment)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
    $SMTPClient.Send($SMTPMessage)
}

SendMail "Tema1" "Body1"