Param(
    [string]$gamePath
)

# TODO: find out why i can't do this and i have to use the stupid batch file
# Start-Process `
#     -FilePath "$gamePath/Binaries/Win64/Launcher/ModLauncherWPF.exe" `
#     -ArgumentList "-allowconsole", "-log", "-autodebug" `
#     -NoNewWindow `
#     -Wait

Start-Process -FilePath "$gamePath/Binaries/Win64/Launcher/StartDebugging.bat" -Wait -NoNewWindow -WorkingDirectory "$gamePath/Binaries/Win64/Launcher"