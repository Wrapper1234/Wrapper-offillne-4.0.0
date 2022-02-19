title Wrapper: Offline Settings Script
:: Interactive config.bat changer
:: Author: benson#0411
:: License: MIT

:: DON'T EDIT THIS FILE! If you need a text version of the settings like it used to be, edit utilities\config.bat. This file is now just an interface for changing that file.

:: Initialize (stop command spam, clean screen, make variables work, set to UTF-8)
@echo off && cls
SETLOCAL ENABLEDELAYEDEXPANSION
if exist "!onedrive!\Documents" (
	set PATHTOEXPORTEDCONFIG=!onedrive!\Documents
) else (
	set PATHTOEXPORTEDCONFIG=!userprofile!\Documents
)
set CONFIGNAME=%username%_config

:: Move to base folder, and make sure it worked (otherwise things would go horribly wrong)
pushd "%~dp0"
if !errorlevel! NEQ 0 goto error_location
if not exist utilities\config.bat ( goto error_location )
if not exist start_wrapper.bat ( goto error_location )
goto noerror_location
:error_location
echo Doesn't seem like this script is in the Wrapper: Offline folder.
goto end
:devmodeerror
echo Ooh, sorry. You have to have developer mode on
echo in order to access these features.
echo:
echo Please turn developer mode on, then try again.
goto reaskoptionscreen
:noerror_location

:: Prevents CTRL+C cancelling and keeps window open when crashing
if "!SUBSCRIPT!"=="" (
	if "%~1" equ "point_insertion" goto point_insertion
	start "" /wait /B "%~F0" point_insertion
	exit
)
:point_insertion

:: patch detection
if exist "patch.jpg" echo MESSAGE GOES HERE && goto end

:: Preload variable
set CFG=utilities\config.bat
set ENV=wrapper\env.json
set TMPCFG=utilities\tempconfig.bat
set TMPENV=wrapper\tempenv.json
set META=utilities\metadata.bat
set BACKTODEFAULTTOGGLE=n
set CHROMIUMENABLE=n
set CHROMIUMDISABLE=n
set BACKTOCUSTOMTOGGLE=n
set BACKTOCUSTOMTOGGLE2=n

:: Load current settings
if "%SUBSCRIPT%"=="" ( 
	set SUBSCRIPT=y
	call !cfg!
	call !meta!
	set "SUBSCRIPT="
) else (
	call !cfg!
	call !meta!
)

::::::::::
:: Menu ::
::::::::::
:: this code is a form of hell have fun going through it cause i dont :)
:optionscreen
cls
echo:
echo Enter 0 to leave settings
echo Enter the number next to the option to change it.
echo Enter a ? before the number for more info on the option.
echo:

if !DEVMODE!==y (
	echo Standard options:
	echo --------------------------------------
)

:: Verbose
if !VERBOSEWRAPPER!==y (
	echo ^(1^) Verbose mode is[92m ON [0m
) else ( 
	echo ^(1^) Verbose mode is[91m OFF [0m
)
:: Skip checking dependenceis
if !SKIPCHECKDEPENDS!==n (
	echo ^(2^) Checking dependencies is[92m ON [0m
) else ( 
	echo ^(2^) Checking dependencies is[91m OFF [0m
)
:: Debug mode
if !DEBUG_VM!==y (
	echo ^(3^) Debug videomaker is[92m ON [0m
) else ( 
	echo ^(3^) Debug videomaker is[91m OFF [0m
)
:: RPC
if !RPC!==y (
	echo ^(4^) Discord RPC is[92m ON [0m
) else ( 
	echo ^(4^) Discord RPC is[91m OFF [0m
)
:: Skip updating
if !AUTOUPDATE!==y (
	echo ^(5^) Auto updating is[92m ON [0m
) else ( 
	echo ^(5^) Auto updating is[91m OFF [0m
)
:: Dark mode
if !DARK_MODE!==y (
	echo ^(6^) Dark mode is[92m ON [0m
) else (
	echo ^(6^) Dark mode is[91m OFF [0m
)
:: Truncated themelist
if !TRUNCATE_THEMES!==y (
	echo ^(7^) Truncated themelist is[92m ON [0m
) else ( 
	echo ^(7^) Truncated themelist is[91m OFF [0m
)
:: Developer mode
if !DEVMODE!==y (
	echo ^(8^) Developer mode is[92m ON [0m
) else ( 
	echo ^(8^) Developer mode is[91m OFF [0m
)
:: Video List
if exist "wrapper\grid" (
        echo ^(9^) Video List Grid Mode is[91m OFF [0m
) else ( 
	echo ^(9^) Video List Grid Mode is[92m ON [0m
)

if !DEVMODE!==y (
	echo:
	echo Developer options:
	echo --------------------------------------
)

:: Dev options
:: These are really specific options that no casual user would ever really need
if !DEVMODE!==y (
	if !DRYRUN!==y (
		echo ^(D1^) Dry run mode is[92m ON [0m
	) else ( 
		echo ^(D1^) Dry run mode is[91m OFF [0m
	)
	if !PORT!==4343 (
		echo ^(D2^) Localhost port for Wrapper: Offline frontend is[92m 4343 [0m
	) else ( 
		echo ^(D2^) Localhost port for Wrapper: Offline frontend is[91m !PORT! [0m
	)
)
:reaskoptionscreen
echo:
set /p CHOICE=Choice:
if "!choice!"=="0" goto end
:: Verbose
if "!choice!"=="1" (
	set TOTOGGLE=VERBOSEWRAPPER
	if !VERBOSEWRAPPER!==n (
		set TOGGLETO=y
	) else (
		set TOGGLETO=n
	)
	set CFGLINE=5
	set ISENV=0
	goto toggleoption
)
if "!choice!"=="?1" (
	echo When enabled, two extra windows with more info about what Offline is doing.
	echo The launcher will also say more about what it's doing, and never clear itself.
	echo Mostly meant for troubleshooting and development. Default setting is off.
	goto reaskoptionscreen
)
:: Check depends
if "!choice!"=="2" (
	set TOTOGGLE=SKIPCHECKDEPENDS
	if !SKIPCHECKDEPENDS!==n (
		set TOGGLETO=y
	) else (
		set TOGGLETO=n
	)
	set CFGLINE=7
	set ISENV=0
	goto toggleoption
)
if "!choice!"=="?2" (
	echo Turning this off skips checking for Flash, Node.js, http-server, and if the HTTPS cert is installed.
	echo This is automatically disabled when Offline launches and finds all dependencies.
	echo If you're on a new computer, or having issues with security messages, you may wanna turn this back on.
	goto reaskoptionscreen
)
:: Debug Mode
if "!choice!"=="3" (
	set TOTOGGLE=DEBUG_VM
	if !DEBUG_VM!==n (
		set TOGGLETO=y
	) else (
		set TOGGLETO=n
	)
	set CFGLINE=21
	set ISENV=1
	goto toggleoption
)
if "!choice!"=="?3" (
	echo By default, debug mode is disabled in the video editor.
	echo:
	echo While useful with showing asset IDs and paths, it freezes when you use character search in ANY theme, 
        echo which can be very annoying to some.
        echo:
	echo Turning this off will stop the asset IDs and paths from showing, and in addition,
        echo will also make character search work again.
	goto reaskoptionscreen
)
:: RPC
if "!choice!"=="4" (
	set TOTOGGLE=RPC
	if !RPC!==y (
		set TOGGLETO=n
	) else (
		set TOGGLETO=y
	)
	set CFGLINE=17
	set ISENV=1
	goto toggleoption
)
if "!choice!"=="?4" (
	echo rpc description i do not feel like writing this
	goto reaskoptionscreen
)
:: Auto Update
if "!choice!"=="5" (
	set TOTOGGLE=AUTOUPDATE
	if !AUTOUPDATE!==y (
		set TOGGLETO=n
	) else (
		set TOGGLETO=y
	)
	set CFGLINE=15
	set ISENV=0
	goto toggleoption
)
if "!choice!"=="?5" (
	echo By default, when you open start_wrapper.bat it 
	echo will auto-update to the newest commit on Github.
	echo This may be annoying to developers making modifications to the program, 
	echo as when this is done it resets uncommitted work.
	echo Turning this off will stop Wrapper from auto-updating.
	goto reaskoptionscreen
)
:: Dark Mode
if "!choice!"=="6" (
	set TOTOGGLE=DARK_MODE
	if !DARK_MODE!==n (
		set TOGGLETO=y
	) else (
		set TOGGLETO=n
	)
	set CFGLINE=19
	set ISENV=1
	goto toggleoption
)
if "!choice!"=="?6" (
	echo By default, dark mode is enabled on the video and theme lists.
        echo:
	echo Dark mode is used to help reduce eyestrain when viewing those lists, and
        echo also improves the user experience quite a bit.
        echo:
	echo Turning this off will revert Offline back to the original light theme.
	goto reaskoptionscreen
)
:: Truncated themelist
if "!choice!"=="7" (
	set TOTOGGLE=TRUNCATE_THEMES
	if !TRUNCATE_THEMES!==y (
		set TOGGLETO=n
	) else (
		set TOGGLETO=y
	)
	set CFGLINE=23
	set ISENV=1
	goto toggleoption
)
if "!choice!"=="?7" (
	echo Cuts down the amount of themes that clog up the themelist in the videomaker.
	echo Keeping this off is highly suggested.
	echo However, if you want to see everything the program has to offer, turn this on.
	goto reaskoptionscreen
)
:: Check depends
if "!choice!"=="8" (
	set TOTOGGLE=DEVMODE
	if !DEVMODE!==n (
		set TOGGLETO=y
	) else (
		set TOGGLETO=n
	)
	set CFGLINE=11
	set ISENV=0
	goto toggleoption
)
if "!choice!"=="?8" (
	echo Wrapper: Offline is free and open-source, and a lot of folks in the community like to make mods for it.
	echo:
	echo Turning on developer mode will provide you with some useful features for development or making your own
	echo mods for Wrapper: Offline, mostly the mods having to do with the batch script.
	echo:
	echo The developer settings will be visible both in these settings and in the Wrapper launcher.
	goto reaskoptionscreen
)
:: Video List
if "!choice!"=="9" goto videoListChange
if "!choice!"=="?9" (
    echo When first getting Wrapper: Offline, you will notice that the video list is not in grid mode. 
    echo if you witch to change it, please turn this thing on or off.
    goto reaskoptionscreen
)

if !DEVMODE!==n (
	if /i "!choice!"=="D1" ( goto devmodeerror )
	if /i "!choice!"=="?D1" ( goto devmodeerror )
	if /i "!choice!"=="D2" ( goto devmodeerror )
	if /i "!choice!"=="?D2" ( goto devmodeerror )
)

if !DEVMODE!==y (
	if /i "!choice!"=="D1" (
		set TOTOGGLE=DRYRUN
		if !DRYRUN!==n (
			set TOGGLETO=y
		) else (
			set TOGGLETO=n
		)
		set CFGLINE=9
		set ISENV=0
		goto toggleoption
	)
	if /i "!choice!"=="?D1" (
		echo Turning this on will run through all of the launcher's code without affecting anything.
		echo Useful for debugging the launcher without uninstalling things and all that.
		goto reaskoptionscreen
	)
	if /i "!choice!"=="D2" goto changeportnumber
	if /i "!choice!"=="?D2" (
		echo By default, the port number of the frontend is 4343.
		echo:
		echo However, some people seem to be having issues with Wrapper: Offline and
		echo sometimes it
		 has to do with what port the frontend is on.
		echo:
		echo Toggling this feature will allow you to change the port number that
		echo the frontend is on.
		goto reaskoptionscreen
	)	
)
if "!choice!"=="clr" goto optionscreen
if "!choice!"=="cls" goto optionscreen
if "!choice!"=="clear" goto optionscreen
echo Time to choose. && goto reaskoptionscreen

:::::::::::::::::::
:: Toggle option ::
:::::::::::::::::::
:toggleoption
echo Toggling setting...
:: Find line after setting to edit
set /a AFTERLINE=!cfgline!+1
:: Loop through every line until one to edit
if exist !tmpcfg! del !tmpcfg!
set /a count=1
for /f "tokens=1,* delims=0123456789" %%a in ('find /n /v "" ^< !cfg!') do (
	set "line=%%b"
	>>!tmpcfg! echo(!line:~1!
	set /a count+=1
	if !count! GEQ !cfgline! goto linereached
)
:linereached
:: Overwrite the original setting
echo set !totoggle!=!toggleto!>> !tmpcfg!
echo:>> !tmpcfg!
:: Print the last of the config to our temp file
more +!afterline! !cfg!>> !tmpcfg!
:: Make our temp file the normal file
copy /y !tmpcfg! !cfg! >nul
del !tmpcfg!
:: Set in here for displaying
set !totoggle!=!toggleto!
if "!isenv!"=="1" (
	if exist "!env!" del "!env!"
	echo {>> !env!
	echo 	"CHAR_BASE_URL": "https://localhost:4664/characters",>> !env!
	echo 	"THUMB_BASE_URL": "https://localhost:4664/thumbnails",>> !env!
	echo 	"XML_HEADER": "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n",>> !env!
	echo 	"CROSSDOMAIN": "<cross-domain-policy><allow-access-from domain=\"*\"/></cross-domain-policy>",>> !env!
	echo 	"FILE_WIDTH": 1000,>> !env!
	echo 	"GATHER_THREADS": 100,>> !env!
	echo 	"GATHER_THRESH1": 250000000,>> !env!
	echo 	"GATHER_THRESH2": 328493000,>> !env!
	echo 	"GATHER_THRESH3": 400000000,>> !env!
	echo 	"FILE_NUM_WIDTH": 9,>> !env!
	echo 	"XML_NUM_WIDTH": 3,>> !env!
	echo 	"SERVER_PORT": !PORT!,>> !env!
	echo 	"SAVED_FOLDER": "./_SAVED",>> !env!
	echo 	"CACHÉ_FOLDER": "./_CACHÉ",>> !env!
	echo 	"THEME_FOLDER": "./_THEMES",>> !env!
	echo 	"PREMADE_FOLDER": "./_PREMADE",>> !env!
	echo 	"EXAMPLE_FOLDER": "./_EXAMPLES",>> !env!
	echo 	"WRAPPER_VER": "!WRAPPER_VER!",>> !env!
	echo 	"NODE_TLS_REJECT_UNAUTHORIZED": "0",>> !env!
	echo 	"RPC": "!RPC!",>> !env!
	echo 	"DARK_MODE": "!DARK_MODE!",>> !env!
	echo 	"DEBUG_VM": "!DEBUG_VM!",>> !env!
	echo 	"TRUNCATE_THEMES": "!TRUNCATE_THEMES!">> !env!
	echo }>> !env!
)
if !BACKTODEFAULTTOGGLE!==y goto backtodefault
if !BACKTOCUSTOMTOGGLE!==y goto backtocustom
if !BACKTOCUSTOMTOGGLE2!==y goto backtocustom2
goto optionscreen

:: Change port number for frontend of Wrapper: Offline
:changeportnumber
echo Which port number would you like to change the frontend to?
echo:
echo Press 1 to change it to 80
echo Press 2 to change it to a custom port number
echo Press 3 if you're changing it back to 4343
echo:
:portnumberreask
set /p PORTCHOICE= Option: 
echo:
if /i "!portchoice!"=="0" goto end
if /i "!portchoice!"=="1" ( 
	set PORTNUMBER=80
	goto porttoggle
)
if /i "!portchoice!"=="2" (
	echo Which port would you like the frontend to be hosted on?
	echo:`
	set /p PORTNUMBER= Port: 
	goto porttoggle
)
if /i "!portchoice!"=="3" (
	set PORTNUMBER=4343
	goto porttoggle
)
echo You must answer with a valid option. && goto portnumberreask

:porttoggle
echo Toggling setting...
if exist "!env!" del "!env!"
echo {>> !env!
echo 	"CHAR_BASE_URL": "https://localhost:4664/characters",>> !env!
echo 	"THUMB_BASE_URL": "https://localhost:4664/thumbnails",>> !env!
echo 	"XML_HEADER": "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n",>> !env!
echo 	"CROSSDOMAIN": "<cross-domain-policy><allow-access-from domain=\"*\"/></cross-domain-policy>",>> !env!
echo 	"FILE_WIDTH": 1000,>> !env!
echo 	"GATHER_THREADS": 100,>> !env!
echo 	"GATHER_THRESH1": 250000000,>> !env!
echo 	"GATHER_THRESH2": 328493000,>> !env!
echo 	"GATHER_THRESH3": 400000000,>> !env!
echo 	"FILE_NUM_WIDTH": 9,>> !env!
echo 	"XML_NUM_WIDTH": 3,>> !env!
echo 	"SERVER_PORT": !PORTNUMBER!,>> !env!
echo 	"SAVED_FOLDER": "./_SAVED",>> !env!
echo 	"CACHÉ_FOLDER": "./_CACHÉ",>> !env!
echo 	"THEME_FOLDER": "./_THEMES",>> !env!
echo 	"PREMADE_FOLDER": "./_PREMADE",>> !env!
echo 	"EXAMPLE_FOLDER": "./_EXAMPLES",>> !env!
echo 	"WRAPPER_VER": "!WRAPPER_VER!",>> !env!
echo 	"NODE_TLS_REJECT_UNAUTHORIZED": "0",>> !env!
echo 	"RPC": "!RPC!",>> !env!
echo 	"DARK_MODE": "!DARK_MODE!",>> !env!
echo 	"DEBUG_VM": "!DEBUG_VM!">> !env!
echo }>> !env!
set TOTOGGLE=PORT
set TOGGLETO=!PORTNUMBER!
set CFGLINE=13
goto toggleoption
	

:::::::::::::::::::::::::
:: Truncated Themelist ::
:::::::::::::::::::::::::
:allthemechange
echo Toggling setting...
pushd wrapper\_THEMES
if exist "_themelist-allthemes.xml" (
	:: disable
	ren _themelist.xml _themelist-lessthemes.xml
	ren _themelist-allthemes.xml _themelist.xml
) else ( 
	:: enable
	ren _themelist.xml _themelist-allthemes.xml
	ren _themelist-lessthemes.xml _themelist.xml
)
popd
pushd wrapper\pages\html
if exist "create-allthemes.html" (
	:: disable
	ren create.html create-lessthemes.html
	ren create-allthemes.html create.html
) else ( 
	:: enable
	ren create.html create-allthemes.html
	ren create-lessthemes.html create.html
)
popd
goto optionscreen

:::::::::::::::
:: Waveforms ::
:::::::::::::::
:waveformchange
echo Toggling setting...
pushd wrapper\static
if exist "info-nowave.json" (
	:: disable
	ren info.json info-wave.json
	ren info-nowave.json info.json
	if exist "info-watermark.json" (
		ren info-watermark.json info-wave-watermark.json
		ren info-nowave-watermark.json info-watermark.json
	) else (
		ren info-nowatermark.json info-wave-nowatermark.json
		ren info-nowave-nowatermark.json info-nowatermark.json
	)
) else (
	:: enable
	ren info.json info-nowave.json
	ren info-wave.json info.json
	if exist "info-watermark.json" (
		ren info-watermark.json info-nowave-watermark.json
		ren info-wave-watermark.json info-watermark.json
	) else (
		ren info-nowatermark.json info-nowave-nowatermark.json
		ren info-wave-nowatermark.json info-nowatermark.json
	)
)
popd
goto optionscreen

::::::::::::::::
:: Debug Mode ::
::::::::::::::::
:debugmodechange
echo Toggling setting...
pushd wrapper\static
if exist "page-nodebug.js" (
	:: disable
	ren page.js page-debug.js
	ren page-nodebug.js page.js
) else ( 
	:: enable
	ren page.js page-nodebug.js
	ren page-debug.js page.js
)
popd
goto optionscreen

:::::::::::::::
:: Dark Mode ::
:::::::::::::::
:darkmodechange
echo Toggling dark mode...
pushd wrapper\pages\css
if exist "global-light.css" (
	:: disable
	ren global.css global-dark.css
	ren global-light.css global.css
	ren create.css create-dark.css
	ren create-light.css create.css
	ren list.css list-dark.css
	ren list-light.css list.css
	ren swf.css swf-dark.css
	ren swf-light.css swf.css
) else ( 
	:: enable
	ren global.css global-light.css
	ren global-dark.css global.css
	ren create.css create-light.css
	ren create-dark.css create.css
	ren list.css list-light.css
	ren list-dark.css list.css
	ren swf.css swf-light.css
	ren swf-dark.css swf.css
)
popd
pushd server\css
if exist "global-light.css" (
	:: disable
	ren global.css global-dark.css
	ren global-light.css global.css
) else ( 
	:: enable
	ren global.css global-light.css
	ren global-dark.css global.css
)
popd
pushd server\animation\414827163ad4eb60
if exist "cc-light.swf" (
	:: disable
	ren cc.swf cc-dark.swf
	ren cc-light.swf cc.swf
	ren cc_browser.swf cc_browser-dark.swf
	ren cc_browser-light.swf cc_browser.swf
) else ( 
	:: enable
	ren cc.swf cc-light.swf
	ren cc-dark.swf cc.swf
	ren cc_browser.swf cc_browser-light.swf
	ren cc_browser-dark.swf cc_browser.swf
)
popd
goto optionscreen

::::::::::::::::::
:: Discord RPC  ::
::::::::::::::::::
:rpcchange
echo Toggling setting...
pushd wrapper
if exist "main-norpc.js" (
	:: disable
	ren main.js main-rpc.js
	ren main-norpc.js main.js
) else ( 
	:: enable
	ren main.js main-norpc.js
	ren main-rpc.js main.js
)
popd
goto optionscreen

:extractchars
if exist "server\characters\characters.zip" (
    echo Are you sure you wish to enable original LVM character IDs?
    echo This will take a while, depending on your computer.
    echo Characters will still be compressed, just put into separate usable files.
    echo Press Y to do it, press N to not do it.
    echo:
    :replaceaskretry
    set /p REPLACECHOICE= Response:
    echo:
    if not '!replacechoice!'=='' set replacechoice=%replacechoice:~0,1%
    if /i "!replacechoice!"=="0" goto end
    if /i "!replacechoice!"=="y" goto startextractchars
    if /i "!replacechoice!"=="n" goto optionscreen
    echo You must answer Yes or No. && goto replaceaskretry
    
    :startextractchars
    echo Opening 7za.exe...
    echo:
    start utilities\7za.exe e "server\characters\characters.zip" -o"server\characters"
    echo The extraction process should be starting now.
	echo:
	echo Please leave both this window and the other window open, otherwise
	echo it could fail hard.
    tasklist /FI "IMAGENAME eq 7za.exe" 2>NUL | find /I /N 7za.exe">NUL
	if "!errorlevel!"=="0" (
		echo:>nul
	) else (
		echo Extraction completed.
		del server\characters\characters.zip
	)
    echo:
	pause
	goto optionscreen
)
goto optionscreen

:::::::::::::::::::::::::
:: Truncated Themelist ::
:::::::::::::::::::::::::
:allthemechange
echo Toggling setting...
pushd wrapper\_THEMES
if exist "themelist-allthemes.xml" (
	:: disable
	ren themelist.xml themelist-lessthemes.xml
	ren themelist-allthemes.xml themelist.xml
) else ( 
	:: enable
	ren themelist.xml themelist-allthemes.xml
	ren themelist-lessthemes.xml themelist.xml
)
popd
pushd wrapper\pages\html
if exist "create-allthemes.html" (
	:: disable
	ren create.html create-lessthemes.html
	ren create-allthemes.html create.xml
) else ( 
	:: enable
	ren create.html create-allthemes.html
	ren create-lessthemes.html create.html
)
popd
goto optionscreen

::::::::::::::::
:: Watermarks ::
::::::::::::::::
:watermarktoogle
echo Toggling setting...
pushd wrapper\static
if exist "info-nowatermark.json" (
	:: disable
	ren info.json info-watermark.json
	ren info-nowatermark.json info.json
	if exist "info-wave.json" (
		ren info-wave.json info-wave-watermark.json
		ren info-wave-nowatermark.json info-wave.json
	) else (
		ren info-nowave.json info-nowave-watermark.json
		ren info-nowave-nowatermark.json info-nowave.json
	)
) else ( 
	:: enable
	ren info.json info-nowatermark.json
	ren info-watermark.json info.json
	if exist "info-wave.json" (
		ren info-wave.json info-wave-nowatermark.json
		ren info-wave-watermark.json info-wave.json
	) else (
		ren info-nowave.json info-nowave-nowatermark.json
		ren info-nowave-watermark.json info-nowave.json
	)
)
popd
goto optionscreen

::::::::::::::::
:: Video List ::
::::::::::::::::
:videoListChange
echo Toggling setting...
pushd wrapper
if exist "grid" (
	:: disable
	ren pages list
	ren grid pages
) else ( 
	:: enable
	ren pages grid
	ren list pages
)
popd
goto optionscreen

:end
endlocal
if "%SUBSCRIPT%"=="" (
	echo Closing...
	pause & exit
) else (
	exit /b
)
