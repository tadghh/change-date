<#
.SYNOPSIS
This script updates the last write time of a specified file to a random time between 12:00 PM and the current hour (up to 5:00 PM).

.DESCRIPTION
The script takes a file path as a parameter, retrieves the specified file, and modifies its last write time. The last write time will be a randomly selected between 12:00 PM and the current hour or 5:00 PM, ensuring that the new last write time is not in the future.

.PARAMETER filePath
Specifies the path of the file for which the last write time will be updated.

.EXAMPLE
.\ChangeDate.ps1 -filePath "C:\Example\File.txt"

This example updates the last write time of the file located at "C:\Example\File.txt" and adds a random time between 12:00 PM and the current hour.

.NOTES
File paths with single quotes are supported. The script replaces single quotes with double quotes when retrieving the file.

#>
param(
    [string]$filePath
)

# Get the clicked file, replace ' with "
$file = Get-Item ($filePath -replace "'", "")
$file.LastWriteTime = Get-Date

# Add a random time between 12:00 PM and 5, also making sure its not in the future
$maxRandomHour = [math]::Min(17, (Get-Date).Hour)

$randomTime = Get-Random -Minimum 12 -Maximum $maxRandomHour

$file.LastWriteTime = $file.LastWriteTime.Date.AddHours($randomTime).AddMinutes((Get-Random -Minimum 0 -Maximum 57)).AddSeconds((Get-Random -Minimum 0 -Maximum 59))
