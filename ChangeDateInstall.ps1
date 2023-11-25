

$registryParentPath = 'Registry::HKCR\*\shell\'

try {
    # Get the ACL for the registry key.
    $registryParentPath = 'Registry::HKCR\*\shell\'
    $keyAcl = Get-Acl -LiteralPath $registryParentPath -ErrorAction Stop

    # Get username.
    $currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    $userRegistryPermissions = $keyAcl.Access | Where-Object {
        $_.IdentityReference.Value -eq $currentUserName -and (
            $_.RegistryRights -eq 'FullControl' -or
            ($_.RegistryRights -eq 'ReadKey' -and $_.RegistryRights -eq 'WriteKey')
        )
    }


}
catch {
    if (-not $userRegistryPermissions) {
        Write-Host "The current user does not have read/write permissions on $registryParentPath."
        Write-Host "Enter 'i' to ignore this warning or any other key to exit."
        $userInput = Read-Host "Input: "

        if (-not ($userInput -eq 'i')) {
            Write-Host "Closing..."
            Exit
        }
    }
}
# Check if powershell is running as admin.
$userPermissions = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent() `
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $userPermissions) {
    # Start a new PowerShell process with the -Verb RunAs flag to request elevation.
    do {
        # Start a new PowerShell process with the -Verb RunAs flag to request elevation.
        Write-Host "The script is not currently running with administrator privileges. Would you like to spawn an admin shell? (Y/n)"
        $userInput = Read-Host "Input: "

        if ($userInput -eq 'y') {
            $curr = Get-Location
            $command = "-NoExit -ExecutionPolicy Bypass -Command cd '$curr'; .\ChangeDateInstall.ps1"

            Write-Host $command
            Start-Process powershell -ArgumentList $command -Verb RunAs
            Exit
        }
        elseif ($userInput -eq 'n') {
            Write-Host "Closing..."
            Exit
        }
        else {
            Write-Host "Invalid input. Please enter 'y' or 'n'."
        }
    } while ($true)
}

# Install locations
# Files: C:\Users\%USERNAME%\Documents\Powershell Scripts\ChangeDate
# The parent folder containing this and maybe other scripts.
$rootFolder = Join-Path $env:USERPROFILE 'Documents\Powershell Scripts'

# The folder for this script to install into.
$changeDateInstallFolder = Join-Path $rootFolder 'ChangeDate'

# The locations for the script files to be installed.
$changeDateWrapperInstallLocation = Join-Path $changeDateInstallFolder 'ChangeDateWrapper.vbs'
$changeDateScriptInstallLocation = Join-Path $changeDateInstallFolder 'ChangeDate.ps1'

# The script file local to the installer.
$changeDateScriptResourceLocation = Join-Path (Get-Location) 'ChangeDate.ps1'

# The value for the context menu entry, what will be executed upon click.
$contextMenuRegistryCommand = 'wscript.exe "{0}" "%1"' -f $changeDateWrapperInstallLocation

# Registry: Computer\HKEY_CLASSES_ROOT\*\shell\FixLastWriteDate
$scriptRegistryKeyName = 'FixLastWriteDate'
$changeWriteTimeRegKey = Join-Path $registryParentPath $scriptRegistryKeyName
$changeWriteScriptCommandKey = Join-Path $changeWriteTimeRegKey 'command'

# The registry keys to be created.
$RegKeys = @(
    @{
        Path  = $changeWriteTimeRegKey
        Value = "Fix Date"
    }
    @{
        Path  = $changeWriteScriptCommandKey
        Value = $contextMenuRegistryCommand
    }
)

# The folders to be created, used a hash map to challenge myself.
$enviromentFolders = @(
    @{
        Path = $rootFolder
    }
    @{
        Path = $changeDateInstallFolder
    }
)

if (Test-Path -Path $changeDateScriptResourceLocation -PathType Leaf) {

    <#
    .SYNOPSIS
        Copies the PowerShell script to the user's documents and creates a wrapper file.
    .DESCRIPTION
        Copies the script and creates an additional wrapper (ChangeDateWrapper.vbs) to prevent the PowerShell window from popping up.
    .NOTES
        All files will be overwritten if this is rerun; the install directories are required.
    #>
    function Copy-ScriptResources {
        $statement = 'Copied file: '

        # Wrapper content, used to prevent a PowerShell window from appearing.
        $wrapperScriptContent = 'Set objShell = WScript.CreateObject("WScript.Shell")
        objShell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""{0}"" -FilePath """ & WScript.Arguments(0) & """", 0, True' -f $changeDateScriptInstallLocation

        try {
            if (Test-Path -Path $changeDateInstallFolder -PathType Container) {

                # Write content to vbs file, in the install folder.
                $wrapperScriptContent | Out-File -FilePath $changeDateWrapperInstallLocation -Force
                Write-Host "Made wrapper file: $changeDateWrapperInstallLocation `n"

                if (-not (Test-Path -Path $changeDateScriptInstallLocation -PathType Leaf)) {

                    Copy-Item -Path $changeDateScriptResourceLocation -Destination $changeDateScriptInstallLocation -Force
                    Write-Host "$statement $changeDateScriptResourceLocation `n"
                }
            }
        }
        catch {
            Write-Host "Error copying/creating scripts: $_"
        }
    }

    <#
    .SYNOPSIS
        Creates the folders required to install the script.
    .DESCRIPTION
        Creates folders to provide some organization for customer PowerShell scripts.
    .NOTES
        The selected installation directory is in the user's documents, this helps with transparency and hopefully encourages learning.
    #>
    function Initialize-ScriptEnviroment {
        $statement = 'Created folder: '

        try {
            foreach ($Item in $enviromentFolders) {
                New-Item -ItemType Directory -Path $Item['Path'] -Force | Out-Null
                Write-Host "$statement $($Item['Path']) `n"
            }
        }
        catch {
            Write-Host "Error creating script enviroment: $_"
        }
    }

    <#
    .SYNOPSIS
        Adds the required keys to the registry.
    .DESCRIPTION
        Creates the keys and values in the registry for the context menu name and the command to execute.
    .NOTES
        This will only be installed for the administrative user.
    #>
    function Initialize-RegistryKeys {
        $statement = 'Created registry key: '

        try {
            foreach ($Item in $RegKeys) {
                New-Item -Path $Item['Path'] -Value $Item['Value'] -Force | Out-Null
                Write-Host "$statement$($Item['Path']) with value: $($Item['Value']) `n"
            }
        }
        catch {
            Write-Host "Error creating script enviroment: $_"
        }
    }

    try {
        # Setup folders and copy/create resources.
        Initialize-ScriptEnviroment
        Copy-ScriptResources

        # Setup the registry entries.
        Initialize-RegistryKeys

        Write-Host 'Install completed.'
    }
    catch {
        Write-Host "Error creating registry entry: $_"
    }
}
else {
    Write-Host 'Installer files missing.'
}
