########################################################
# ���: Backup_medoc_keys.ps1                              
# �����: ����� ��������                    
# ���� ��������: 18.05.2017                              
# ���� ��������� �����������: 10.02.2018                   
# ������: 1.1 
# PSVersion tested: 5.1
#
# ������������ ��� ������������� ����� � ������� MEDOC
# �������� ����������� �� ����������� � ������������ 
# ������� (��������� � 23:00)
########################################################

#������� ����������
$BackupDir="\\ukrcatalog.com\Shares\Backup\SRV-BUH\Medoc_keys"   #������� ��������� �������� �����
$BackupDirLocal="D:\"          #��������� ��������� �������� �����
$FileName="\medoc_keys_"+ (Get-Date -format dd-MM-yyyy_HHmmss)+".zip" #��� ����� ������
$DateTimeFile=$BackupDirLocal+$FileName #�������� ������� ����� ����� ������
$BackupDirs=(Get-Content D:\Backup_dir_medoc_keys.txt) #��������, ������� ����� ������������
$Days=5                                 #���������� ����, �� ������� ����� ������� ������
#$username = "ukrcatalog\Administrator"  #��� ������������ ��� ����������� � �������� ���������
#$password = "Monaco77"                  #������ ������������ ��� ����������� � �������� ���������

#������� ��� �������� ��������� �� �����
Function SendEmail ($Subject,$Body) {
    $EmailFrom = "it-support@ukrcatalog.com.ua"
	$EmailTo = "admin@ukrcatalog.com.ua"
	$SMTPServer = "str.ukrcatalog.com"
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body) 
}

#����������� �������� ���������
net use $BackupDir #/USER:$username $password 

#�������� ������
Compress-Archive -Path $BackupDirs -DestinationPath $DateTimeFile -CompressionLevel Optimal -ErrorAction SilentlyContinue -ErrorVariable ErrVal

#������� �������� ����� � ������� ���������
Move-Item "$BackupDirLocal\medoc_keys_*.zip" $BackupDir -ErrorAction SilentlyContinue -ErrorVariable +ErrVal

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
    SendEmail "(��� OK!!!)Backup Medoc Keys" "��� OK!!!`n$ListFile`n���������� �������� ������ - $Stat $ErrVal"
  }
  else {
	#�������� Wrong e-mail 
    SendEmail "(������!!!)Backup Medoc Keys" "����� �� ������!!!`n$ErrVal"
  }

#���������� �������� ��������� 
net use $BackupDir /delete  









  
