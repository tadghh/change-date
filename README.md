# Change Date

Adds a context menu entry to change the last modified time of a file to be something more sensible.

# Install

For Windows 10 1809 or greater

```powershell
cd $env:USERPROFILE/Downloads;
mkdir ./temp;
cd ./temp;
curl -L -O https://github.com/tadghh/change-date/archive/main.zip;
Expand-Archive -Path .\main.zip -DestinationPath .\;
cd .\change-date-main\;
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser;
.\ChangeDateInstall.ps1;

```

# TODO

- Install instructions
- ~~Fix performance~~
- ~~Test in different environment~~
- ~~Clean up installer~~
- ~~Add more documentation~~
- Add admin prompt request
- GUI for specifying the date
