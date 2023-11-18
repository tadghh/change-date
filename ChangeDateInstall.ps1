#Install locations
#Registry: Computer\HKEY_CLASSES_ROOT\*\shell\SetLastWriteTime
#Files: C:\Users\%USERNAME%\Documents\Powershell Scripts\ChangeDate
$script:rootFolder = Join-Path $env:USERPROFILE 'Documents\Powershell Scripts'

#The folder for this script to install into
$script:changeDateInstallFolder = Join-Path $rootFolder 'ChangeDate'

#The locations for the script files to be installed
$script:changeDateWrapper = Join-Path $changeDateInstallFolder 'ChangeDateWrapper.vbs'
$script:changeDateScriptInstallLocation = Join-Path $changeDateInstallFolder 'ChangeDate.ps1'

#Files local to the installer
$script:changeDateScriptResourceLocation = ".\ChangeDate.ps1"

#Other
$script:scriptRegistryKeyName = "FixLastWriteTime"
$script:changeWriteTimeRegKey = "HKCU:\Software\Classes\*\shell\${scriptRegistryKeyName}"
$script:changeWriteCommandKey = "HKCU:\Software\Classes\*\shell\${scriptRegistryKeyName}\command"
$script:powershellChangeDateLocation = $changeDateScriptInstallLocation

#Wrapper content, used to prevent a PowerShell window from appearing
$wrapperScriptContent = @"
Set objShell = WScript.CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""${powershellChangeDateLocation}"" -FilePath """ & WScript.Arguments(0) & """", 0, True
"@


if (Test-Path -Path $changeDateScriptResourceLocation -PathType Leaf) {

    function Copy-ScriptResources {
        $statement = "Copied file: "
        try {
            if (Test-Path -Path $changeDateInstallFolder -PathType Container) {
                #Write content to vbs file, in the install folder
                $wrapperScriptContent | Out-File -FilePath $changeDateWrapper -Force
                Write-Host "Made wrapper file: $changeDateWrapper"

                if (-not (Test-Path -Path $changeDateScriptInstallLocation -PathType Leaf)) {
                    Copy-Item -Path $changeDateScriptResourceLocation -Destination $changeDateScriptInstallLocation -Force

                    Write-Host -Object "$statement $changeDateScriptResourceLocation" -ForegroundColor Green
                }
            }
        }
        catch {
            Write-Host "Error copying scripts: $_"
        }

    }

    function Initialize-ScriptEnviroment {
        $statement = "Created folder: "

        try {
            if (-not (Test-Path -Path $rootFolder -PathType Container)) {
                New-Item -ItemType Directory -Path $rootFolder -Force | Out-Null
                Write-Host -Object "$statement $rootFolder"
            }

            if (-not (Test-Path -Path $changeDateInstallFolder -PathType Container)) {
                New-Item -ItemType Directory -Path $changeDateInstallFolder -Force | Out-Null
                Write-Host -Object  "$statement $changeDateInstallFolder"
            }
        }
        catch {
            Write-Host "Error creating script enviroment: $_"
        }
    }

    function Initialize-RegistryKeys {
        $statement = "Created registry key: "

        try {
            if (-not (Test-Path -Path $changeWriteTimeRegKey -PathType Container)) {

                New-Item -Path $changeWriteTimeRegKey -Force | Out-Null
                Write-Host "$statement$changeWriteTimeRegKey"
            }
            if (-not (Test-Path -Path $changeWriteCommandKey -PathType Container)) {

                New-Item -Path $changeWriteCommandKey -Force | Out-Null
                Write-Host "$statement$changeWriteCommandKey"
            }
        }
        catch {
            Write-Host "Error creating script enviroment: $_"
        }
    }

    try {
        #Setup folders and copy/create resources
        Initialize-ScriptEnviroment
        Copy-ScriptResources

        #Setup the registry entries
        Initialize-RegistryKeys

        #Set the title for the context menu entry
        New-ItemProperty -Path $changeWriteTimeRegKey -Name '(default)' -Value "Fix date" -PropertyType String

        #Set the command for the context menu entry
        $registryValue = 'wscript.exe "{0}" "%1"' -f $changeDateWrapper
        New-ItemProperty -Path $changeWriteCommandKey -Name '(default)' -Value $registryValue -PropertyType String

        Write-Host "Registry entry created successfully."
    }
    catch {
        Write-Host "Error creating registry entry: $_"
    }
}
else {
    Write-Host "Installer files were missing."
}




