# Change Date

Adds a context menu entry to change the last modified time of a file to be something more sensible.

# Install

This powershell command will download and run the installer, just paste it in easy peasy

```powershell
cd $env:USERPROFILE/Downloads;
mkdir ./temp;
cd ./temp;
$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } –PassThru;
Invoke-WebRequest -OutFile $tmp https://github.com/tadghh/change-date/archive/main.zip;
$tmp | Expand-Archive -DestinationPath ./ -Force; $tmp | Remove-Item;
cd .\change-date-main\;
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser;
.\ChangeDateInstall.ps1
;
```

# TODO

- ~~Install instructions~~
- ~~Fix performance~~
- ~~Test in different environment~~
- ~~Clean up installer~~
- ~~Add more documentation~~
- ~~Add admin prompt request~~
- GUI for specifying the date
