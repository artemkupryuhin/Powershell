########################################################
# Имя: Backup_medoc_keys.ps1                              
# Автор: Артем Купрюхин                    
# Дата создания: 18.05.2017                              
# Дата последней модификации: 10.02.2018                   
# Версия: 1.1 
# PSVersion tested: 5.1
#
# Предназначен для архивирования папки с ключами MEDOC
# Сценарий запускается по рассписанию в планировщике 
# заданий (ежедневно в 23:00)
########################################################

#Зададим переменные
$BackupDir="\\ukrcatalog.com\Shares\Backup\SRV-BUH\Medoc_keys"   #Сетевое хранилище архивных копий
$BackupDirLocal="D:\"          #Локальное хранилище архивных копий
$FileName="\medoc_keys_"+ (Get-Date -format dd-MM-yyyy_HHmmss)+".zip" #Имя файла архива
$DateTimeFile=$BackupDirLocal+$FileName #Генерция полного имени файла архива
$BackupDirs=(Get-Content D:\Backup_dir_medoc_keys.txt) #Каталоги, которые нужно архивировать
$Days=5                                 #Количество дней, за которые нужно хранить архивы
#$username = "ukrcatalog\Administrator"  #Имя пользователя для подключения к сетевому хранилищу
#$password = "Monaco77"                  #Пароль пользователя для подключения к сетевому хранилищу

#Функция для отправки сообщения на почту
Function SendEmail ($Subject,$Body) {
    $EmailFrom = "it-support@ukrcatalog.com.ua"
	$EmailTo = "admin@ukrcatalog.com.ua"
	$SMTPServer = "str.ukrcatalog.com"
	$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
	$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body) 
}

#Подключение сетевого хранилища
net use $BackupDir #/USER:$username $password 

#Создание архива
Compress-Archive -Path $BackupDirs -DestinationPath $DateTimeFile -CompressionLevel Optimal -ErrorAction SilentlyContinue -ErrorVariable ErrVal

#Перенос архивной копии в сетевое хранилище
Move-Item "$BackupDirLocal\medoc_keys_*.zip" $BackupDir -ErrorAction SilentlyContinue -ErrorVariable +ErrVal

#Проверяем, находится ли последний архив в сетевом хранилище
#и отправляем соответствующее сообщение на почту
if (Test-Path -Path $BackupDir$FileName -ErrorAction SilentlyContinue -ErrorVariable +ErrVal) {
    
    #Удалить zip-файлы старше, чем количество дней заданное в $Days
    Get-ChildItem -Path $BackupDir -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-$Days)} | Remove-Item 

    #Вычисляем количество zip-файлов в сетевом хранилище
    $Stat=(Get-ChildItem -Path $BackupDir).count

    #Перечень zip-файлов в сетевом хранилище
    $ListFile=(Get-ChildItem -Path $BackupDir -File | ForEach-Object {"`n"+$_.Name})
    
    #Посылаем OKey e-mail
    SendEmail "(Все OK!!!)Backup Medoc Keys" "Все OK!!!`n$ListFile`nКоличество архивных файлов - $Stat $ErrVal"
  }
  else {
	#Посылаем Wrong e-mail 
    SendEmail "(Ошибка!!!)Backup Medoc Keys" "Архив не создан!!!`n$ErrVal"
  }

#Отключение сетевого хранилища 
net use $BackupDir /delete  









  
