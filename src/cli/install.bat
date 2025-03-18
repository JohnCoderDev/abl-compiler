@echo off
setlocal

net session >nul 2>&1
if errorlevel 2 (
	echo you must run this script as admin.
	goto PROGRAMEND
)

goto GETOPTIONS

:HELP
echo USAGE:
echo.
echo install [-h]
echo 	display this help in the screen
echo.
echo install [-i]
echo 	try to install ablc in your environment
echo.
echo install [-u]
echo 	try to update or install the ablc in your environment

goto PROGRAMEND

:INSTALL
mkdir %~dp0^tmp
cd tmp
where /q ablc.bat

if errorlevel 1 (
	mkdir %appdata%\ablc >nul 2>&1
	setx /M path "%appdata%\ablc\;%path%" >nul 2>&1
	cd ..
	rmdir tmp
	copy * "%appdata%\ablc\" >nul 2>&1
	echo installed with success.
	goto PROGRAMEND
) 

echo already installed.
cd ..
rmdir tmp

goto PROGRAMEND

:GETOPTIONS

if /I "%1" == "-u" (
	mkdir %~dp0^tmp
	cd tmp
	where /q ablc.bat

	if errorlevel 1 (
		cd ..
		rmdir tmp
		goto INSTALL
	) else (
		copy * "%appdata%\ablc\" >nul 2>&1
		echo updated with success.
	)
	goto PROGRAMEND
)

if /I "%1" == "-i" (
	goto INSTALL
)

if /I "%1" == "-h" (
	goto HELP
)

if /I "%1" == "" (
	goto HELP
)

:PROGRAMEND
endlocal
@echo on
