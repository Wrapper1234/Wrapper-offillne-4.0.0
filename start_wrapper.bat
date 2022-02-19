:: Wrapper: Offline Launcher
:: Author: benson#0411
:: License: MIT

::::::::::::::::::::
:: Initialization ::
::::::::::::::::::::

:: Stop commands from spamming stuff, cleans up the screen
@echo off && cls

:: Lets variables work or something idk im not a nerd
SETLOCAL ENABLEDELAYEDEXPANSION

:: Load metadata
if not exist utilities\metadata.bat ( set NOMETA=y & goto metamissing )
set SUBSCRIPT=y
call utilities\metadata.bat
goto metaavailable

:metamissing
if %NOMETA%==y (
	title Wrapper: Offline [Metadata Missing]
	echo The metadata's missing for some reason?
	echo Restoring...
	goto metacopy
)

:returnfrommetacopy
if not exist utilities\metadata.bat ( echo Something is horribly wrong. You may be in a read-only system/admin folder. & pause & exit )
if %NOMETA%==n ( set SUBSCRIPT=y & call utilities\metadata.bat )

:rebootasadmin
if %ADMIN%==n (
	:: echo Set UAC = CreateObject^("Shell.Application"^)>> %tmp%\requestAdmin.vbs
	:: set params= %*
	:: echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1>> %tmp%\requestAdmin.vbs
	:: start "" %tmp%\requestAdmin.vbs
	exit
)
:metaavailable

:: Set title
title Wrapper: Offline v!WRAPPER_VER! [Initializing...]

:: Make sure we're starting in the correct folder, and that it worked (otherwise things would go horribly wrong)
pushd "%~dp0"
if !errorlevel! NEQ 0 goto error_location
if not exist utilities ( goto error_location )
if not exist wrapper ( goto error_location )
if not exist server ( goto error_location )
goto noerror_location
:error_location
echo Doesn't seem like this script is in a Wrapper: Offline folder.
pause && exit
:noerror_location

:: patch detection
if exist "patch.jpg" goto patched

:: Prevents CTRL+C cancelling (please close with 0) and keeps window open when crashing
if "%~1" equ "point_insertion" goto point_insertion
start "" /wait /B "%~F0" point_insertion
exit

:point_insertion

:: Check *again* because it seems like sometimes it doesn't go into dp0 the first time???
pushd "%~dp0"
if !errorlevel! NEQ 0 goto error_location
if not exist utilities ( goto error_location )
if not exist wrapper ( goto error_location )
if not exist server ( goto error_location )

:: Create checks folder if nonexistent
if not exist "utilities\checks" md utilities\checks

:: Welcome, Director Ford!
echo Wrapper: Offline
echo A project from VisualPlugin adapted by GoTest334 and the Wrapper: Offline team
echo Version !WRAPPER_VER!
echo:

:: Confirm measurements to proceed.
set SUBSCRIPT=y
echo Loading settings...
if not exist utilities\config.bat ( goto configmissing )
call utilities\config.bat
echo:
if !VERBOSEWRAPPER!==y ( echo Verbose mode activated. && echo:)
goto configavailable

:: Restore config
:configmissing
echo Creating config.bat...
goto configcopy
:returnfromconfigcopy
if not exist utilities\config.bat ( echo Something is horribly wrong. You may be in a read-only system/admin folder. & pause & exit )
call utilities\config.bat
:configavailable

if not exist wrapper\env.json ( goto envmissing )
goto envavailable

:: Restore env
:envmissing
echo Creating env.json...
goto envcopy
:returnfromenvcopy
if not exist wrapper\env.json ( echo Something is horribly wrong. You may be in a read-only system/admin folder. & pause & exit )
:envavailable

:: check for updates
if !AUTOUPDATE!==y ( 
	pushd "%~dp0"
	if exist .git (
		echo Updating...
		call utilities\PortableGit\bin\git.exe checkout -f main
		call utilities\PortableGit\bin\git.exe fetch --all
		call utilities\PortableGit\bin\git.exe reset --hard origin/main
		PING -n 3 127.0.0.1>nul
		cls
	) else (
		echo Git not found. Skipping update.
		PING -n 3 127.0.0.1>nul
		cls
	)
) else (
	echo Auto-updating is off. Skipping update.
	PING -n 3 127.0.0.1>nul
	cls
)

::::::::::::::::::::::
:: Dependency Check ::
::::::::::::::::::::::

if !SKIPCHECKDEPENDS!==y (
	echo Checking dependencies has been skipped.
	echo:
	goto skip_dependency_install
)

if !VERBOSEWRAPPER!==n (
	echo Checking for dependencies...
	echo:
)

title Wrapper: Offline v!WRAPPER_VER! [Checking dependencies...]

:: Preload variables
set NEEDTHEDEPENDERS=n
set ADMINREQUIRED=n
set FLASH_DETECTED=n
set FLASH_CHROMIUM_DETECTED=n
set NODEJS_DETECTED=n
set HTTPSERVER_DETECTED=n
set HTTPSCERT_DETECTED=n
if !INCLUDEDCHROMIUM!==y set BROWSER_TYPE=chrome

:: Flash Player
if !VERBOSEWRAPPER!==y ( echo Checking for Flash installation... )
if exist "!windir!\SysWOW64\Macromed\Flash\*pepper.exe" set FLASH_CHROMIUM_DETECTED=y
if exist "!windir!\System32\Macromed\Flash\*pepper.exe" set FLASH_CHROMIUM_DETECTED=y
	if !FLASH_CHROMIUM_DETECTED!==n (
		echo Flash for Chrome could not be found.
		echo:
		set NEEDTHEDEPENDERS=y
		set ADMINREQUIRED=y
		goto flash_checked
	) else (
		echo Flash is installed.
		echo:
		set FLASH_DETECTED=y
		goto flash_checked
	)
:flash_checked

:: Node.js
if !VERBOSEWRAPPER!==y ( echo Checking for Node.js installation... )
for /f "delims=" %%i in ('npm -v 2^>nul') do set output=%%i
IF "!output!" EQU "" (
	echo Node.js could not be found.
	echo:
	set NEEDTHEDEPENDERS=y
	set ADMINREQUIRED=y
	goto httpserver_checked
) else (
	echo Node.js is installed.
	echo:
	set NODEJS_DETECTED=y
)
:nodejs_checked

:: http-server
if !VERBOSEWRAPPER!==y ( echo Checking for http-server installation... )
npm list -g | findstr "http-server" >nul
if !errorlevel! == 0 (
	echo http-server is installed.
	echo:
	set HTTPSERVER_DETECTED=y
) else (
	echo http-server could not be found.
	echo:
	set NEEDTHEDEPENDERS=y
)
:httpserver_checked

:: HTTPS cert
if !VERBOSEWRAPPER!==y ( echo Checking for HTTPS certificate... )
call certutil -store -enterprise root | findstr "WOCRTV3" >nul
if !errorlevel! == 0 (
	echo HTTPS cert installed.
	echo:
	set HTTPSCERT_DETECTED=y
) else (
	:: backup check in case non-admin method used
	if exist "utilities\checks\httpscert.txt" (
		echo HTTPS cert probably installed.
		echo:
		set HTTPSCERT_DETECTED=y
	) else (
		echo HTTPS cert could not be found.
		echo:
		set NEEDTHEDEPENDERS=y
	)
)
popd

:: Assumes nothing is installed during a dry run
if !DRYRUN!==y (
	echo Let's just ignore anything we just saw above.
	echo Nothing was found. Nothing exists. It's all fake.
	set NEEDTHEDEPENDERS=y
	set ADMINREQUIRED=y
	set FLASH_DETECTED=n
	set FLASH_CHROMIUM_DETECTED=n
	set FLASH_FIREFOX_DETECTED=n
	set NODEJS_DETECTED=n
	set HTTPSERVER_DETECTED=n
	set HTTPSCERT_DETECTED=n
	set BROWSER_TYPE=n
)

::::::::::::::::::::::::
:: Dependency Install ::
::::::::::::::::::::::::

if !NEEDTHEDEPENDERS!==y (
	echo:
	echo Installing missing dependencies...
	echo:
) else (
	echo All dependencies are available.
	echo Turning off checking dependencies...
	echo:
	:: Initialize vars
	set CFG=utilities\config.bat
	set TMPCFG=utilities\tempconfig.bat
	:: Loop through every line until one to edit
	if exist !tmpcfg! del !tmpcfg!
	set /a count=1
	for /f "tokens=1,* delims=0123456789" %%a in ('find /n /v "" ^< !cfg!') do (
		set "line=%%b"
		>>!tmpcfg! echo(!line:~1!
		set /a count+=1
		if !count! GEQ 7 goto linereached
	)
	:linereached
	:: Overwrite the original setting
	echo set SKIPCHECKDEPENDS=y>> !tmpcfg!
	echo:>> !tmpcfg!
	:: Print the last of the config to our temp file
	more +8 !cfg!>> !tmpcfg!
	:: Make our temp file the normal file
	copy /y !tmpcfg! !cfg! >nul
	del !tmpcfg!
	:: Set in this script
	set SKIPCHECKDEPENDS=y
	goto skip_dependency_install
)

title Wrapper: Offline v!WRAPPER_VER! [Installing dependencies...]

:: Preload variables
set INSTALL_FLAGS=ALLUSERS=1 /norestart
set SAFE_MODE=n
if /i "!SAFEBOOT_OPTION!"=="MINIMAL" set SAFE_MODE=y
if /i "!SAFEBOOT_OPTION!"=="NETWORK" set SAFE_MODE=y
set CPU_ARCHITECTURE=what
if /i "!processor_architecture!"=="x86" set CPU_ARCHITECTURE=32
if /i "!processor_architecture!"=="AMD64" set CPU_ARCHITECTURE=64
if /i "!PROCESSOR_ARCHITEW6432!"=="AMD64" set CPU_ARCHITECTURE=64

:: Check for admin if installing Flash or Node.js
:: Skipped in Safe Mode, just in case anyone is running Wrapper in safe mode... for some reason
:: and also because that was just there in the code i used for this and i was like "eh screw it why remove it"
if !ADMINREQUIRED!==y (
	if !VERBOSEWRAPPER!==y ( echo Checking for Administrator rights... && echo:)
	if /i not "!SAFE_MODE!"=="y" (
		fsutil dirty query !systemdrive! >NUL 2>&1
		if /i not !ERRORLEVEL!==0 (
			color cf
			if !VERBOSEWRAPPER!==n ( cls )
			echo:
			echo ERROR
			echo:
			if !FLASH_DETECTED!==n (
				if !NODEJS_DETECTED!==n (
					echo Wrapper: Offline needs to install Flash and Node.js.
				) else (
					echo Wrapper: Offline needs to install Flash.
				)
			) else (
				echo Wrapper: Offline needs to install Node.js.
			)
			echo To do this, it must be started with Admin rights.
			echo:
			echo Close this window and re-open Wrapper: Offline as an Admin.
			echo ^(right-click start_wrapper.bat and click "Run as Administrator"^)
			echo:
			if !DRYRUN!==y (
				echo ...yep, dry run is going great so far, let's skip the exit
				pause
				goto postadmincheck
			)
			pause
			set ADMIN=n
			goto rebootasadmin
		)
	)
	if !VERBOSEWRAPPER!==y ( echo Admin rights detected. && echo:)
)
:postadmincheck
if exist "%tmp%\requestAdmin.vbs" ( del "%tmp%\requestAdmin.vbs">nul )

:: Flash Player
if !FLASH_DETECTED!==n (
	:start_flash_install
	echo Installing Flash Player...
	set BROWSER_TYPE=chrome && if !VERBOSEWRAPPER!==y ( echo Chromium-based browser picked. && echo:) && goto escape_browser_ask

	:escape_browser_ask
	echo To install Flash Player, Wrapper: Offline must kill any currently running web browsers.
	echo Please make sure any work in your browser is saved before proceeding.
	echo Wrapper: Offline will not continue installation until you press a key.
	echo:
	pause
	echo:

	:: Summon the Browser Slayer
	if !DRYRUN!==y (
		echo The users brought down the batch script upon the Browser Slayer, and in his defeat entombed him in the unactivated code.
		goto lurebrowserslayer
	)
	echo Rip and tear, until it is done.
	for %%i in (firefox,palemoon,tor,iexplore,maxthon,microsoftedge,chrome,chrome64,chromium,opera,brave,torch,waterfox,basilisk,Basilisk-Portable) do (
		if !VERBOSEWRAPPER!==y (
			 taskkill /f /im %%i.exe /t >nul
			 wmic process where name="%%i.exe" call terminate
		) else (
			 taskkill /f /im %%i.exe /t >nul
			 wmic process where name="%%i.exe" call terminate >nul
		)
	)
	:lurebrowserslayer
	echo:
		echo Starting the Flash Player installer...
		echo:
		if not exist "utilities\installers\flash_windows_chromium.msi" (
			echo ...erm. Bit of an issue there actually. The installer doesn't exist.
			echo A normal copy of Wrapper: Offline should come with one.
			echo You may be able to get the installer here:
			echo:
			echo Although Flash is needed, Offline will continue launching.
			pause
			goto after_flash_install
		)
		if !DRYRUN!==n ( msiexec /i "utilities\installers\flash_windows_chromium.msi" !INSTALL_FLAGS! /quiet )
	echo Flash has been installed.
	echo:
)
:after_flash_install

:: Node.js
if !NODEJS_DETECTED!==n (
	echo Installing Node.js...
	echo:
	:: Install Node.js
	if !CPU_ARCHITECTURE!==64 (
		if !VERBOSEWRAPPER!==y ( echo 64-bit system detected, installing 64-bit Node.js. )
		if not exist "utilities\installers\node_windows_x64.msi" (
			echo We have a problem. The 64-bit Node.js installer doesn't exist.
			echo A normal copy of Wrapper: Offline should come with one.
			echo You should be able to find a copy on this website:
			echo https://nodejs.org/en/download/
			echo Although Node.js is needed, Offline will try to install anything else it can.
			pause
			goto after_nodejs_install
		)
		echo Proper Node.js installation doesn't seem possible to do automatically.
		echo You can just keep clicking next until it finishes, and Wrapper: Offline will continue once it closes.
		if !DRYRUN!==n ( msiexec /i "utilities\installers\node_windows_x64.msi" !INSTALL_FLAGS! )
		goto nodejs_installed
	)
	if !CPU_ARCHITECTURE!==32 (
		if !VERBOSEWRAPPER!==y ( echo 32-bit system detected, installing 32-bit Node.js. )
		if not exist "utilities\installers\node_windows_x32.msi" (
			echo We have a problem. The 32-bit Node.js installer doesn't exist.
			echo A normal copy of Wrapper: Offline should come with one.
			echo You should be able to find a copy on this website:
			echo https://nodejs.org/en/download/
			echo Although Node.js is needed, Offline will try to install anything else it can.
			pause
			goto after_nodejs_install
		)
		echo Proper Node.js installation doesn't seem possible to do automatically.
		echo You can just keep clicking next until it finishes, and Wrapper: Offline will continue once it closes.
		if !DRYRUN!==n ( msiexec /i "utilities\installers\node_windows_x32.msi" !INSTALL_FLAGS! )
		goto nodejs_installed
	)
	if !CPU_ARCHITECTURE!==what (
		echo:
		echo Well, this is a little embarassing.
		echo:
		echo Wrapper: Offline can't tell if you're on a 32-bit or 64-bit system.
		echo Which means it doesn't know which version of Node.js to install...
		echo:
		echo If you have no idea what that means, press 1 to just try anyway.
		echo:
		echo If you know what kind of architecture you're running, but Offline
		echo didn't detect it, press 2.
		echo:
		echo If you're in the future with newer architectures or something
		echo and you know what you're doing, then press 3 to keep going.
		echo:
		:architecture_ask
		set /p CPUCHOICE= Response:
		echo:
		if "!cpuchoice!"=="1" if !DRYRUN!==n ( msiexec /i "utilities\installers\node_windows_x32.msi" !INSTALL_FLAGS! ) && if !VERBOSEWRAPPER!==y ( echo Attempting 32-bit Node.js installation. ) && goto nodejs_installed
		if "!cpuchoice!"=="2" (
			echo:
			echo Press 1 if you're running Wrapper: Offline on a 32-bit system.
			echo Press 2 if you're running Wrapper: Offline on a 64-bit system.
			echo:
			:whatsystemreask
			set /p WHATSYSTEM= Response:
			echo:
			if "!whatsystem!"=="1" set CPU_ARCHITECTURE=32
			if "!whatsystem!"=="2" set CPU_ARCHITECTURE=64
			if "!whatsystem!"=="32" echo Why couldn't you just type 1? & echo: & pause & set CPU_ARCHITECTURE=32
			if "!whatsystem!"=="64" echo Why couldn't you just type 2? & echo: & pause & set CPU_ARCHITECTURE=64			
			if "!whatsystem!"=="" echo That's an invalid option. Please try again. && goto whatsystemreask
		)
		if "!cpuchoice!"=="3" echo Node.js will not be installed. && goto after_nodejs_install
		echo You must pick one or the other.&& goto architecture_ask
	)
	:nodejs_installed
	echo Node.js has been installed.
	set NODEJS_DETECTED=y
	echo:
	goto install_cert
)
:after_nodejs_install

:: http-server
if !HTTPSERVER_DETECTED!==n (
	if !NODEJS_DETECTED!==y (
		echo Installing http-server...
		echo:

		:: Skip in dry run, not much use to run it
		if !DRYRUN!==y (
			echo ...actually, nah, let's skip this part.
			goto httpserverinstalled
		) 

		:: Attempt to install through NPM normally
		call npm install http-server -g

		:: Double check for installation
		echo Checking for http-server installation again...
		call npm list -g | find "http-server" > nul
		if !errorlevel! == 0 (
			goto httpserverinstalled
		) else (
			echo:
			echo Online installation attempt failed. Trying again from local files...
			echo:
			if not exist "utilities\installers\http-server-master" (
				echo Well, we'd try that if the files existed.
				echo A normal copy of Wrapper: Offline should come with them.
				echo You should be able to find a copy on this website:
				echo https://www.npmjs.com/package/http-server
				echo Although http-server is needed, Offline will try to install anything else it can.
				pause
				goto after_nodejs_install
			)
			call npm install utilities\installers\http-server-master -g
			goto triplecheckhttpserver
		)

		:: Triple check for installation
		echo Checking for http-server installation AGAIN...
		:triplecheckhttpserver
		npm list -g | find "http-server" > nul
		if !errorlevel! == 0 (
			goto httpserverinstalled
		) else (
			echo:
			echo Local file installation failed. Something's not right.
			echo Unless this was intentional, ask for support or install http-server manually.
			echo Enter "npm install http-server -g" into a separate Command Prompt window.
			echo:
			pause
			exit
		)
	) else (
		color cf
		echo:
		echo http-server is missing, but somehow Node.js has not been installed yet.
		echo Seems either the install failed, or Wrapper: Offline managed to skip it.
		echo If installing directly from nodejs.org does not work, something is horribly wrong.
		echo Please ask for help in the #support channel on Discord, or email me.
		pause
		exit
	)
	:httpserverinstalled
	echo http-server has been installed.
	echo:
	goto install_cert
)

:: Install HTTPS certificate
:install_cert
if !HTTPSCERT_DETECTED!==n (
	echo Installing HTTPS certificate...
	echo:
	if not exist "server\the.crt" (
		echo ...except it doesn't exist for some reason.
		echo Wrapper: Offline requires this to run.
		echo You should get a "the.crt" file from someone else, or redownload Wrapper: Offline.
		echo Offline has nothing left to do since it can't launch without the.crt, so it will close.
		pause
		exit
	)
	:: Check for admin
	if /i not "!SAFE_MODE!"=="y" (
		fsutil dirty query !systemdrive! >NUL 2>&1
		if /i not !ERRORLEVEL!==0 (
			if !VERBOSEWRAPPER!==n ( cls )
			echo For Wrapper: Offline to work, it needs an HTTPS certificate to be installed.
			echo If you have administrator privileges, you should reopen start_wrapper.bat as Admin.
			echo ^(it will do this automatically if you say you have admin rights^)
			echo:
			echo If you can't do that, there's another method, but it's less reliable and is done per-browser.
			echo: 
			echo Press Y if you have admin access, and press N if you don't.
			:certaskretry
			set /p CERTCHOICE= Response:
			echo:
			if not '!certchoice!'=='' set certchoice=%certchoice:~0,1%
			if /i "!certchoice!"=="y" echo This window will now close so you can restart it with admin. & set ADMIN=n & goto rebootasadmin
			if /i "!certchoice!"=="n" goto certnonadmin
			echo You must answer Yes or No. && goto certaskretry

			:: Non-admin cert install
			pushd utilities
			start SilentCMD open_http-server.bat
			popd
			echo: 
			echo A web browser window will open.
			echo When you see a security notice, go past it.
			echo This is completely harmless in a local setting like this.
			echo If you see a message like this on the real internet, you should stay away.
			:: Pause to allow startup
			PING -n 8 127.0.0.1>nul
			if !INCLUDEDCHROMIUM!==n (
				if !CUSTOMBROWSER!==n (
					start https://localhost:4664/certbypass.html
				) else (
					start !CUSTOMBROWSER! https://localhost:4664/certbypass.html >nul
				)
			) else (
				pushd utilities\ungoogled-chromium
				start chromium.exe --user-data-dir=the_profile https://localhost:4664/certbypass.html --allow-outdated-plugins >nul
				popd
			)
			pause
			echo:
			echo If you intend on using another browser, you'll have to do this again by going to the server page and passing the security message.
			echo You've used a non-admin method of installing the HTTPS certificate. To redo the process, delete this file. > utilities\checks\httpscert.txt
			goto after_cert_install
		)
	)
	pushd server
	if !VERBOSEWRAPPER!==y (
		if !DRYRUN!==n ( certutil -addstore -f -enterprise -user root the.crt )
	) else (
		if !DRYRUN!==n ( certutil -addstore -f -enterprise -user root the.crt >nul )
	)
	set ADMINREQUIRED=y
	popd
)
:after_cert_install

:: Alert user to restart Wrapper without running as Admin
if !ADMINREQUIRED!==y (
	color 20
	if !VERBOSEWRAPPER!==n ( cls )
	echo:
	echo Dependencies needing Admin now installed^^!
	echo:
	echo Wrapper: Offline no longer needs Admin rights,
	echo please restart normally by double-clicking.
	echo:
	echo If you saw this from running normally,
	echo Wrapper: Offline should continue normally after a restart.
	echo:
	if !DRYRUN!==y (
		echo ...you enjoying the dry run experience? Skipping closing.
		pause
		color 0f
		goto skip_dependency_install
	)
	pause
	exit
)
color 0f
echo Restarting explorer.exe...
echo:
TASKKILL /F /IM explorer.exe >nul
PING -n 2 127.0.0.1>nul
start explorer.exe
cls
echo All dependencies now installed^^!
echo:
echo It is recommended that you restart the computer
echo to make sure that everything is fully working.
echo:
echo Would you like to restart your system before
echo using Wrapper: Offline? [Y/n]
echo:
set /p RESTARTPC= Response: 
if not '!restartpc!'=='' set restartpc=%restartpc:~0,1%
if /i "!restartpc!"=="y" (
	echo Press any key to start the rebooting process.
	echo:
	pause
	echo Your PC will reboot in 10 seconds.
	PING -n 11 127.0.0.1>nul
	echo Rebooting your PC...
	call shutdown /r /t 00
	exit
)
if /i "!restartpc!"=="n" goto continuing

:continuing
echo Continuing with Wrapper: Offline boot.
echo:

:skip_dependency_install

::::::::::::::::::::::
:: Starting Wrapper ::
::::::::::::::::::::::

title Wrapper: Offline v!WRAPPER_VER! [Loading...]

:: Close existing node apps
:: Hopefully fixes EADDRINUSE errors??
if !VERBOSEWRAPPER!==y (
	echo Closing any existing node and/or PHP apps and batch processes...
	for %%i in (npm start,npm,http-server,HTTP-SERVER HASN'T STARTED,NODE.JS HASN'T STARTED YET,VFProxy PHP Launcher for Wrapper: Offline) do (
		if !DRYRUN!==n ( TASKKILL /FI "WINDOWTITLE eq %%i" >nul 2>&1 )
	)
	if !DRYRUN!==n ( TASKKILL /IM node.exe /F >nul 2>&1 )
	if !DRYRUN!==n ( TASKKILL /IM php.exe /F >nul 2>&1 )
	echo:
) else (
	if !DRYRUN!==n ( TASKKILL /IM node.exe /F >nul 2>&1 )
	if !DRYRUN!==n ( TASKKILL /IM php.exe /F >nul 2>&1 )
)

:: Start Node.js, http-server and PHP webserver for VFProxy
if !CEPSTRAL!==n (
	echo Loading Node.js, http-server and PHP webserver ^(for VFProxy only^)...
) else (
	echo Loading Node.js and http-server...
)
pushd utilities
if !VERBOSEWRAPPER!==y (
	if !DRYRUN!==n ( start /MIN open_http-server.bat )
	if !DRYRUN!==n ( start /MIN open_nodejs.bat )
	if !DRYRUN!==n ( start /MIN open_vfproxy_php.bat )
) else (
	if !DRYRUN!==n ( start SilentCMD open_http-server.bat )
	if !DRYRUN!==n ( start SilentCMD open_nodejs.bat )
	if !DRYRUN!==n ( start SilentCMD open_vfproxy_php.bat )
	)
)
popd

:: Pause to allow startup
:: Prevents the video list opening too fast
PING -n 16 127.0.0.1>nul

echo Opening Wrapper: Offline...
pushd utilities\ungoogled-chromium
set ARGS=--app=http://localhost:!port! --allow-outdated-plugins
if !DRYRUN!==n ( start chromium.exe --user-data-dir=the_profile !ARGS! )
echo Wrapper: Offline has been started^^! The video list should now be open.

::::::::::::::::
:: Post-Start ::
::::::::::::::::

title Wrapper: Offline v!WRAPPER_VER!
if !VERBOSEWRAPPER!==y ( goto wrapperstarted )
:wrapperstartedcls
cls
:wrapperstarted

echo:
echo Wrapper: Offline v!WRAPPER_VER! running
echo A project from VisualPlugin adapted by GoTest334 and the Wrapper: Offline team
echo:
if !VERBOSEWRAPPER!==n ( echo DON'T CLOSE THIS WINDOW^^! Use the quit option ^(0^) when you're done. )
if !VERBOSEWRAPPER!==y ( echo Verbose mode is on, see the extra CMD windows for extra output. )
if !DRYRUN!==y ( echo Don't forget, nothing actually happened, this was a dry run. )
:: Hello, code wanderer. Enjoy seeing all the secret options easily instead of finding them yourself.
if !DEVMODE!==y (
	echo:
	echo Standard options:
	echo --------------------------------------
)
:: Spacing when dev mode is off
if !DEVMODE!==n ( echo: )
echo Enter 1 to reopen the video list
echo Enter 2 to open the settings
echo Enter 3 to import a file
if exist .git (
	echo Enter 4 to update wrapper
)
echo Enter clr to clean up the screen
echo Enter 0 to close Wrapper: Offline
if !DEVMODE!==y (
	echo:
	echo Developer options:
	echo --------------------------------------
	echo Type "server" to open the server page.
	echo Type "amnesia" to wipe your save.
	echo Type "restart" to restart Wrapper: Offline.
	echo Type "reload" to reload your settings and metadata.
	echo Type "folder" to open the files.
)
echo:
:wrapperidle
popd
echo:

:::::::::::::
:: Choices ::
:::::::::::::

set /p CHOICE=Choice:
if "!choice!"=="0" goto exitwrapperconfirm
set FUCKOFF=n
if "!choice!"=="1" goto reopen_webpage
if "!choice!"=="2" goto settings
if "!choice!"=="3" goto start_importer
if "!choice!"=="4" goto update_wrapper
if /i "!choice!"=="clr" goto wrapperstartedcls
if /i "!choice!"=="cls" goto wrapperstartedcls
if /i "!choice!"=="clear" goto wrapperstartedcls
:: dev options
if /i "!choice!"=="server" goto open_server
if /i "!choice!"=="amnesia" goto wipe_save
if /i "!choice!"=="restart" goto restart
if /i "!choice!"=="reload" goto reload_settings
if /i "!choice!"=="folder" goto open_files

echo Time to choose. && goto wrapperidle

:reopen_webpage	
		echo Opening Wrapper: Offline...
		pushd utilities\ungoogled-chromium
		if !DRYRUN!==n ( start chromium.exe --user-data-dir=the_profile !ARGS! )
goto wrapperidle

:start_importer
echo Opening the importer...
start "" "utilities\import.bat"
goto wrapperidle

:update_wrapper
echo This will close Wrapper: Offline, are you sure you want to continue?
echo Be sure to save all your work.
echo Type Y to quit, and N to go back.
:updateretry
set /p UPDATECHOICE= Response:
echo:
if /i "!updatechoice!"=="y" goto continueupdate
if /i "!updatechoice!"=="yes" goto continueupdate
if /i "!updatechoice!"=="n" goto wrapperstartedcls
if /i "!updatechoice!"=="no" goto wrapperstartedcls
echo You must answer Yes or No. && goto updateretry
:continueupdate
cls
echo Updating...
if exist utilities\PortableGit\bin\git.exe (
	if exist .git (
		call utilities\PortableGit\bin\git.exe checkout -f main
		call utilities\PortableGit\bin\git.exe fetch --all
		call utilities\PortableGit\bin\git.exe reset --hard origin/main
		PING -n 3 127.0.0.1>nul
		goto point_extraction
	) else (
		echo Update failed!
		echo How did you manage to get rid of the .git folder before the update started???
		goto wrapperstartedcls
	)
) else (
	echo Update failed!
	echo Maybe don't delete PortableGit next time?
	goto wrapperstartedcls
)

:open_server
	echo Opening the server page...
	pushd utilities\ungoogled-chromium
	if !DRYRUN!==n ( start chromium.exe --user-data-dir=the_profile https://localhost:4664 --allow-outdated-plugins )
goto wrapperidle

:open_files
pushd
echo Opening the wrapper-offline folder...
start explorer.exe "%CD%"
popd
goto wrapperidle

:settings
echo Launching settings..
call settings.bat
cls
title Wrapper: Offline v!WRAPPER_VER!
goto wrapperstartedcls

:youfuckoff
echo You fuck off.
set FUCKOFF=y
goto wrapperidle

:reload_settings
call utilities\config.bat
call utilities\metadata.bat
goto wrapperstartedcls

:wipe_save
call utilities\reset_install.bat
if !errorlevel! equ 1 goto wrapperidle
goto wrapperidle
:: flows straight to restart below

:restart
TASKKILL /IM node.exe /F >nul 2>&1
if !CEPSTRAL!==n ( TASKKILL /IM php.exe /F >nul 2>&1 )
if !VERBOSEWRAPPER!==y (
	for %%i in (npm start,npm,http-server,HTTP-SERVER HASN'T STARTED,NODE.JS HASN'T STARTED YET,VFProxy PHP Launcher for Wrapper: Offline,Server for imported voice clips TTS voice) do (
		TASKKILL /FI "WINDOWTITLE eq %%i" >nul 2>&1
	)
)
start "" /wait /B "%~F0" point_insertion
exit

::::::::::::::
:: Shutdown ::
::::::::::::::

:: Confirmation before shutting down
:exitwrapperconfirm
echo:
echo Are you sure you want to quit Wrapper: Offline?
echo Be sure to save all your work.
echo Type Y to quit, and N to go back.
:exitwrapperretry
set /p EXITCHOICE= Response:
echo:
if /i "!exitchoice!"=="y" goto point_extraction
if /i "!exitchoice!"=="yes" goto point_extraction
if /i "!exitchoice!"=="n" goto wrapperstartedcls
if /i "!exitchoice!"=="no" goto wrapperstartedcls
if /i "!exitchoice!"=="with style" goto exitwithstyle
echo You must answer Yes or No. && goto exitwrapperretry

:point_extraction

title Wrapper: Offline v!WRAPPER_VER! [Shutting down...]

:: Shut down Node.js, PHP and http-server

:: Copies config.bat first in case for whatever reason this messes it up (it's happened before trust me)
pushd utilities
copy config.bat tmpcfg.bat>nul
popd

:: Deletes a temporary batch file again just in case
if exist %tmp%\importserver.bat ( del %tmp%\importserver.bat )

if !VERBOSEWRAPPER!==y (
	if !DRYRUN!==n (
	TASKKILL /IM SilentCMD.exe /F >nul 2>&1 
	TASKKILL /IM node.exe /F >nul 2>&1
	for %%i in (npm start,npm,http-server,HTTP-SERVER HASN'T STARTED,NODE.JS HASN'T STARTED YET,VFProxy PHP Launcher for Wrapper: Offline,Server for imported voice clips TTS voice) do (
	TASKKILL /FI "WINDOWTITLE eq %%i" >nul 2>&1 )
	)
	if !DRYRUN!==n ( 
		if !CEPSTRAL!==n ( 
			TASKKILL /IM php.exe /F >nul 2>&1
		)
	)
	if !DRYRUN!==n ( 
		if !INCLUDEDCHROMIUM!==y ( 
			TASKKILL /IM chromium.exe /F >nul 2>&1
		)
		if !INCLUDEDBASILISK!==y ( 
			TASKKILL /IM "utilities\basilisk\Basilisk-Portable\Basilisk-Portable.exe" /F >nul 2>&1
		)
	)
	echo:
) else (
	if !DRYRUN!==n ( TASKKILL /IM node.exe /F >nul 2>&1 )
	if !DRYRUN!==n ( 
		TASKKILL /IM SilentCMD.exe /F >nul 2>&1 
		if !CEPSTRAL!==n ( 
			TASKKILL /IM php.exe /F >nul 2>&1
		)
	)
	if !DRYRUN!==n ( 
		if !INCLUDEDCHROMIUM!==y ( 
			TASKKILL /IM chromium.exe /F >nul 2>&1 
		)
		if !INCLUDEDBASILISK!==y ( 
			TASKKILL /IM utilities\basilisk\Basilisk-Portable\Basilisk-Portable.exe /F 2>nul
		)
	)
)

:: Puts config.bat back to normal
pushd utilities
del config.bat
ren tmpcfg.bat config.bat
popd

:: This is where I get off.
echo Wrapper: Offline has been shut down.
if !FUCKOFF!==y ( echo You're a good listener. )
echo This window will now close.
echo Open start_wrapper.bat again to start W:O again.
if !DRYRUN!==y ( echo Go wet your run next time. ) 
pause & exit

:exitwithstyle
title Wrapper: Offline v!WRAPPER_VER! [Shutting down... WITH STYLE]
echo SHUTTING DOWN THE WRAPPER OFFLINE
PING -n 3 127.0.0.1>nul
color 9b
echo BEWEWEWEWWW PSSHHHH KSHHHHHHHHHHHHHH
PING -n 3 127.0.0.1>nul
for %%i in (npm start,npm,http-server,HTTP-SERVER HASN'T STARTED,NODE.JS HASN'T STARTED YET,VFProxy PHP Launcher for Wrapper: Offline,Server for imported voice clips TTS voice) do (
	if !DRYRUN!==n ( TASKKILL /FI "WINDOWTITLE eq %%i" >nul 2>&1 )
)
TASKKILL /IM node.exe /F >nul 2>&1
echo NODE DOT JS ANNIHILATED....I THINK
PING -n 3 127.0.0.1>nul
if !CEPSTRAL!==n (
	TASKKILL /IM php.exe /F >nul 2>&1
	echo PHP DESTROYED....MAYBE...THE BATCH WINDOW WAS ALREADY DESTROYED
	PING -n 3 127.0.0.1>nul
)
if !INCLUDEDCHROMIUM!==y (
	TASKKILL /IM chromium.exe /F >nul 2>&1
	echo UNGOOGLED CHROMIUM COMPLETELY OBLITERATED
	PING -n 3 127.0.0.1>nul
)
if !INCLUDEDBASILISK!==y (
	TASKKILL /IM %CD%\utilities\basilisk\Basilisk-Portable\Basilisk-Portable.exe /F >nul 2>&1
	echo BASILISK COMPLETELY OBLITERATED
	PING -n 3 127.0.0.1>nul
)
echo TIME TO ELIMINATE WRAPPER OFFLINE
PING -n 3 127.0.0.1>nul
echo BOBOOBOBMWBOMBOM SOUND EFFECTSSSSS
PING -n 3 127.0.0.1>nul
echo WRAPPER OFFLINE ALSO ANNIHILA
PING -n 2 127.0.0.1>nul
exit

:patched
title candypaper nointernet PATCHED edition
color 43
echo OH MY GODDDDD
PING -n 3 127.0.0.1>nul
echo SWEETSSHEET LACKOFINTERNS PATCHED DETECTED^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!^^!
PING -n 3 127.0.0.1>nul
echo can never be use again...
PING -n 4 127.0.0.1>nul
echo whoever put patch.jpeg back, you are grounded grounded gorrudjnmed for 6000
PING -n 3 127.0.0.1>nul
:grr
echo g r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r r 
PING -n 0.55 127.0.0.1>nul
goto grr

:configcopy
if not exist utilities ( md utilities )
echo setlocal>> utilities\config.bat
echo if "%%SUBSCRIPT%%"=="" ( start notepad.exe "%%CD%%\%%~nx0" ^& exit )>> utilities\config.bat
echo endlocal>> utilities\config.bat
echo:>> utilities\config.bat
echo set VERBOSEWRAPPER=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set SKIPCHECKDEPENDS=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set DRYRUN=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set DEVMODE=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set PORT=4343>> utilities\config.bat
echo:>> utilities\config.bat
echo set AUTOUPDATE=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set RPC=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set DARK_MODE=y>> utilities\config.bat
echo:>> utilities\config.bat
echo set DEBUG_VM=n>> utilities\config.bat
echo:>> utilities\config.bat
echo set TRUNCATE_THEMES=y>> utilities\config.bat
echo:>> utilities\config.bat
echo:>> utilities\config.bat
goto returnfromconfigcopy

:envcopy
	set ENV=wrapper\env.json
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
goto returnfromenvcopy

:metacopy
if not exist utilities ( md utilities )
echo :: Wrapper: Offline Metadata>> utilities\metadata.bat
echo :: Important useful variables that are displayed by start_wrapper.bat>> utilities\metadata.bat
echo :: You probably shouldn't touch this. This only exists to make things easier for the devs everytime we go up a build number or something like that.>> utilities\metadata.bat
echo:>> utilities\metadata.bat
echo :: Opens this file in Notepad when run>> utilities\metadata.bat
echo setlocal>> utilities\metadata.bat
echo if "%%SUBSCRIPT%%"=="" ( start notepad.exe "%%CD%%\%%~nx0" ^& exit )>> utilities\metadata.bat
echo endlocal>> utilities\metadata.bat
echo:>> utilities\metadata.bat
echo set WRAPPER_VER=1.3.0>> utilities\metadata.bat
echo:>> utilities\metadata.bat
set NOMETA=n
goto returnfrommetacopy
