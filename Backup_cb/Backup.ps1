########################################################
# ���: Backup.ps1                              
# �����: ����� ��������                    
# ���� ��������: 14.04.2017                              
# ���� ��������� �����������: 10.02.2018                               
# ������: 1.4   
# PSVersion tested: 5.1
#
# ������������ ��� ������������� ����� � �������������� 
# ����������� ������-���� �� CREDIT AGRICOLE � �������� 
# �� � ������� ���������, �������� �� ��������� ������
# ������������ �� �����, ���������� �������� ������� 
# �������������
# �������� ����������� �� ����������� � ������������ 
# ������� (��������� � 0:00)
########################################################

#������� ����������
$BackupDir="\\str\Backup$\Client-bank"   #������� ��������� �������� �����
$BackupDirLocal="C:\Backup_cb"          #��������� ��������� �������� �����
$FileName="\cb_"+ (Get-Date -format dd-MM-yyyy_HHmmss)+".zip" #��� ����� ������
$DateTimeFile=$BackupDirLocal+$FileName #�������� ������� ����� ����� ������
$BackupDirs=(Get-Content C:\Backup_cb\BackupDirs.txt) #��������, ������� ����� ������������
$Days=7                                 #���������� ����, �� ������� ����� ������� ������
$username = "ukrcatalog\Administrator"  #��� ������������ ��� ����������� � �������� ���������
$password = "Monaco77"                  #������ ������������ ��� ����������� � �������� ���������

#������� ��� �������� ��������� �� �����
Function SendEmail ($Subject,$Body) {
    $EmailFrom = "it-support@ukrcatalog.com.ua"
	$EmailTo = "admin@ukrcatalog.com.ua"
	$SMTPServer = "str.ukrcatalog.com"
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body) 
}

#����������� �������� ���������
net use $BackupDir /USER:$username $password 

#�������� ������
Compress-Archive -Path $BackupDirs -DestinationPath $DateTimeFile -CompressionLevel Optimal -ErrorAction SilentlyContinue -ErrorVariable ErrVal

#������� �������� ����� � ������� ���������
Move-Item "$BackupDirLocal\cb_*.zip" $BackupDir -ErrorAction SilentlyContinue -ErrorVariable +ErrVal

#������� zip-����� ������, ��� ���������� ���� �������� � $Days
Get-ChildItem -Path $BackupDir -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$Days)} | Remove-Item 

#��������� ���������� zip-������ � ������� ���������
$Stat=(Get-ChildItem -Path $BackupDir).count

#�������� zip-������ � ������� ���������
$ListFile=(Get-ChildItem -Path $BackupDir -File | ForEach-Object {"`n"+$_.Name})

#���������, ��������� �� ��������� ����� � ������� ���������
#� ���������� ��������������� ��������� �� �����
if (Test-Path -Path $BackupDir$FileName -ErrorAction SilentlyContinue -ErrorVariable +ErrVal) {
    
    #������� zip-����� ������, ��� ���������� ���� �������� � $Days
    Get-ChildItem -Path $BackupDir -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$Days)} | Remove-Item 

    #��������� ���������� zip-������ � ������� ���������
    $Stat=(Get-ChildItem -Path $BackupDir).count

    #�������� zip-������ � ������� ���������
    $ListFile=(Get-ChildItem -Path $BackupDir -File | ForEach-Object {"`n"+$_.Name})
    
    #�������� OKey e-mail
    SendEmail "(��� OK!!!)Backup client bank's CREDIT AGRICOLE" "��� OK!!!`n$ListFile`n���������� �������� ������ - $Stat $ErrVal"
  }
  else {
	#�������� Wrong e-mail 
    SendEmail "(������!!!)Backup client bank's CREDIT AGRICOLE" "����� �� ������!!!`n$ErrVal"
  }

#���������� �������� ��������� 
net use $BackupDir /delete  









  
