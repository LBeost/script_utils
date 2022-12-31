@echo off

call :find-files %1 %2
goto :EOF

:::::::::::::::::::::::::::::::::::::::::::
:: call me with : .\mp3.bat . *.anything
:::::::::::::::::::::::::::::::::::::::::::

:find-files
    for /R "%~1" %%P in ("%~2") do (
        set "OLD_PATH=%%P"
        set "NEW_PATH=!OLD_PATH:~0,-5!.mp3"
        call ffmpeg -y -i "%%OLD_PATH%%" -map 0:a -codec:a libmp3lame -b:a 320k "%%NEW_PATH%%"
        call del "%%OLD_PATH%%"
    )
goto :EOF
