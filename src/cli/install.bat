@echo off
setlocal
net session >nul 2>&1
if errorlevel 2 (
	echo you must run this script as admin.
	goto PROGRAMEND
)

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
) else (
	echo already installed.
)

cd ..
rmdir tmp

:PROGRAMEND
endlocal
@echo on
