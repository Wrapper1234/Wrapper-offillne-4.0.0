:: Wrapper: Offline Metadata
:: Important useful variables that are displayed by start_wrapper.bat
:: You probably shouldn't touch most of this. This only exists to make things easier for the devs everytime we go up a build number or something like that.

:: Opens this file in Notepad when run
setlocal
if "%SUBSCRIPT%"=="" ( start notepad.exe "%CD%\%~nx0" & exit )
endlocal

:: Version number, build number and branch/build type
set WRAPPER_VER=1.3.0
set WRAPPER_BRNCH=Beta
