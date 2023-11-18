param(
    [string]$filePath
)

# Get the clicked file, replace ' with "
$file = Get-Item ($filePath -replace "'", "")
$file.LastWriteTime = Get-Date

# Add a random time between 12:00 PM and 5, also making sure its not in the future
$maxRandomHour = [math]::Min(17, $currentDate.Hour)
$randomTime = Get-Random -Minimum 12 -Maximum $maxRandomHour

$file.LastWriteTime = $file.LastWriteTime.Date.AddHours($randomTime).AddMinutes((Get-Random -Minimum 0 -Maximum 57)).AddSeconds((Get-Random -Minimum 0 -Maximum 59))