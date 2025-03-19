@echo off
setlocal
set ablcInstallDir=%appdata%\ablc

net session >nul 2>&1
if errorlevel 2 (
	echo you must run this script as admin.
	goto PROGRAMEND
)

goto GETOPTIONS

:HELP
cat "%~dp0help-install.txt"
goto PROGRAMEND

:INSTALL
mkdir "%~dp0tmp" >nul 2>&1
cd tmp >nul 2>&1
where /q ablc.bat

if errorlevel 1 (
	mkdir %appdata%\ablc >nul 2>&1
	echo. "%path%" | findstr /C:"%ablcInstallDir%\;" >nul
	if errorlevel 1 (
		setx /M path "%ablcInstallDir%\;%path%" >nul 2>&1
	)
	cd ..
	rmdir tmp >nul 2>&1
	copy * "%ablcInstallDir%\" >nul 2>&1
	echo installed with success.
	goto PROGRAMEND
) 

echo already installed.
cd ..
rmdir tmp

goto PROGRAMEND

:GETOPTIONS

if /I "%1" == "-u" (
	mkdir %~dp0^tmp >nul 2>&1
	cd tmp >nul 2>&1
	where /q ablc.bat

	if errorlevel 1 (
		goto INSTALL
	) else (
		cd ..
		rmdir tmp >nul 2>&1
		copy * "%ablcInstallDir%\" >nul 2>&1
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
