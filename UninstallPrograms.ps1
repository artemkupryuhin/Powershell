# Using PowerShell to get a list of applications installed
Get-WmiObject -Class Win32_Product | Select-Object Name,Version

# Individually uninstalling programs 
$app = Get-WmiObject -Class Win32_Product | Where-Object {
$_.Name -match “HP ProLiant Health Monitor Service (X64)”
}

$app.Uninstall()

# Removing many programs at once with the foreach loop
$programs = @(“program1”, “program2”, “program3”)
foreach ($program in $programs) {
$app = Get-WmiObject -Class Win32_Product | Where-Object {
$_.Name -match “$program”
}
$app.Uninstall()
}