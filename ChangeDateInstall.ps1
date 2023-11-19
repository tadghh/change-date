#Install locations
#Registry: Computer\HKEY_CLASSES_ROOT\*\shell\SetLastWriteTime
#Files: C:\Users\%USERNAME%\Documents\Powershell Scripts\ChangeDate
$rootFolder = Join-Path $env:USERPROFILE 'Documents\Powershell Scripts'

#The folder for this script to install into
$changeDateInstallFolder = Join-Path $rootFolder 'ChangeDate'

#The locations for the script files to be installed
$changeDateWrapper = Join-Path $changeDateInstallFolder 'ChangeDateWrapper.vbs'
$changeDateScriptInstallLocation = Join-Path $changeDateInstallFolder 'ChangeDate.ps1'

#Files local to the installer
$changeDateScriptResourceLocation = Join-Path (Get-Location) 'ChangeDate.ps1'

#The value for the context menu entry
$registryValue = 'wscript.exe "{0}" "%1"' -f $changeDateWrapper

$scriptRegistryKeyName = 'FixLastWriteDate'
$registryPath = 'Registry::HKCR\*\shell\'
$changeWriteTimeRegKey = Join-Path $registryPath $scriptRegistryKeyName
$changeWriteCommandKey = Join-Path $changeWriteTimeRegKey 'command'

$RegKeys = @(
    @{
        Path = $changeWriteTimeRegKey
        Value = "Fix Date"
    }
    @{
        Path = $changeWriteCommandKey
        Value = $registryValue
    }
)

$enviromentFolders = @(
    @{
        Path = $rootFolder
    }
    @{
        Path = $changeDateInstallFolder
    }
)

if (Test-Path -Path $changeDateScriptResourceLocation -PathType Leaf) {

    function Copy-ScriptResources {
        $statement = 'Copied file: '

        #Wrapper content, used to prevent a PowerShell window from appearing
        $wrapperScriptContent = 'Set objShell = WScript.CreateObject("WScript.Shell")
        objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""{0}"" -FilePath """ & WScript.Arguments(0) & """", 0, True' -f $changeDateScriptInstallLocation

        try {
            if (Test-Path -Path $changeDateInstallFolder -PathType Container) {

                #Write content to vbs file, in the install folder
                $wrapperScriptContent | Out-File -FilePath $changeDateWrapper -Force
                Write-Host "Made wrapper file: $changeDateWrapper"

                if (-not (Test-Path -Path $changeDateScriptInstallLocation -PathType Leaf)) {

                    Copy-Item -Path $changeDateScriptResourceLocation -Destination $changeDateScriptInstallLocation -Force
                    Write-Host -Object "$statement $changeDateScriptResourceLocation"
                }
            }
        }
        catch {
            Write-Host "Error copying/creating scripts: $_"
        }
    }

    function Initialize-ScriptEnviroment {
        $statement = 'Created folder: '

        try {
            foreach ($Item in $enviromentFolders) {
                New-Item -ItemType Directory -Path $Item['Path'] -Force | Out-Null
                Write-Host -Object "$statement $($Item['Path'])"
            }
            # if (-not (Test-Path -Path $Item['Path'] -PathType Container)) {
            #     New-Item -ItemType Directory -Path $Item['Path'] -Force | Out-Null
            #     Write-Host -Object "$statement $($Item['Path'])"
            # }

            # if (-not (Test-Path -Path $changeDateInstallFolder -PathType Container)) {
            #     New-Item -ItemType Directory -Path $changeDateInstallFolder -Force | Out-Null
            #     Write-Host -Object  "$statement $changeDateInstallFolder"
            # }
        }
        catch {
            Write-Host "Error creating script enviroment: $_"
        }
    }

    function Initialize-RegistryKeys {
        $statement = 'Created registry key: '

        try {
            foreach ($Item in $RegKeys) {
                New-Item -Path $Item['Path'] -Value $Item['Value'] -Force | Out-Null
                Write-Host "Created registry key: $($Item['Path']) with value: $($Item['Value'])"
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

        Write-Host 'Install completed.'
    }
    catch {
        Write-Host "Error creating registry entry: $_"
    }
}
else {
    Write-Host 'Installer files were missing.'
}




