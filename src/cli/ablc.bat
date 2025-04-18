@echo off
setlocal
set programCaller=%DLC%\bin\prowin.exe
set ablcInstallDir=%appdata%\ablc
set compilerScript=%ablcInstallDir%\compiler-cli.p
set compilerLogOutput=ablc-compiler-log.log
set quiet=0

if not exist %ablcInstallDir% (
	echo ERROR: the ablc is not installed yet, please install with the install-ablc script
	goto PROGRAMEND
)

goto GETOPTS

:HELP

if exist "%ablcInstallDir%\help.txt" (
	powershell -c $(get-content "%ablcInstallDir%\help.txt"^)
) else (
	powershell -c $(get-content "%~dp0help.txt"^) 
)

goto PROGRAMEND


:GETOPTS
if /I "%1" == "-h" (
	goto HELP
) else if /I "%1" == "--help" (
	goto HELP
) else if /I "%1" == "-q" (
	set quiet=1
	shift
) else  if /I "%1" == "-c" (
	set compilerSpecs=%2
	set compilationMode=c
	shift
	shift
) else if /I "%1" == "--compile" (
	set compilerSpecs=%2
	set compilationMode=c
	shift
	shift
) else if /I "%1" == "-dc" (
	if "%oedbn%" == "" (
		echo environment variable %%oedbn%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oedbn%
	set compilationMode=c
	shift
) else if /I "%1" == "-c1" (
	if "%oebn1%" == "" (
		echo environment variable %%oebn1%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oebn1%
	set compilationMode=c
	shift
) else if /I "%1" == "-c2" (
	if "%oebn2%" == "" (
		echo environment variable %%oebn2%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oebn2%
	set compilationMode=c
	shift
) else if /I "%1" == "-s" (
	set compilerSpecs=%2
	set compilationMode=s
	shift
	shift
) else if /I "%1" == "--service" (
	set compilerSpecs=%2
	set compilationMode=s
	shift
	shift
) else if /I "%1" == "-ds" (
	if "%oedbn%" == "" (
		echo environment variable %%oedbn%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oedbn%
	set compilationMode=s
	shift
) else if /I "%1" == "-s1" (
	if "%oebn1%" == "" (
		echo environment variable %%oebn1%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oebn1%
	set compilationMode=s
	shift
) else if /I "%1" == "-s2" (
	if "%oebn2%" == "" (
		echo environment variable %%oebn2%% is not settled
		goto PROGRAMEND
	)
	set compilerSpecs=%oebn2%
	set compilationMode=s
	shift
) else if /I "%1" == "-n" (
	copy %~dp0^project-template.json %2
	goto PROGRAMEND
) else if /I "%1" == "--new" (
	copy %~dp0^project-template.json %2
	goto PROGRAMEND
) else if /I "%1" == "-ininame" (
	set additionalArgs=%additionalArgs% -basekey "ini" -ininame %2
	shift
	shift
) else if /I "%1" == "-p" (
	set extraProcedures=%2
	shift
	shift
) else if /I "%1" == "-pf" (
	set additionalArgs=%additionalArgs% -pf %2
	shift
	shift
) else if /I "%1" == "-pf1" (
	set additionalArgs=%additionalArgs% -pf %oepf1%
	shift
) else if /I "%1" == "-pf2" (
	set additionalArgs=%additionalArgs% -pf %oepf2%
	shift
) else if /I "%1" == "-log" (
	set compilerLogOutput=%2
	shift
	shift
) else (
	echo ERROR: unknown parameter `%1`, type `ablc -h` to check the help
	goto PROGRAMEND
)

if /I "%1" == "" (
	goto RUNCOMPILATIONCMD
)

goto GETOPTS

:RUNCOMPILATIONCMD
if not exist %compilerScript% (
	echo ERROR: compiler script was not found in the path %compilerScript%
	goto PROGRAMEND
)
if "%compilerSpecs%" == "" (
	goto HELP
)

echo.%compilerSpecs% | findstr /C:":" 1>nul
if errorlevel 1 (
	set compilerSpecs=%cd%\%compilerSpecs%
)

echo.%additionalArgs% | findstr /C:"-ininame " 1>nul
if errorlevel 1 (
	if not "%oeini%" == "" (
		set additionalArgs=%additionalArgs% -basekey "ini" -ininame %oeini%	
	)
)

echo.%additionalArgs% | findstr /C:"-pf " 1>nul
if errorlevel 1 (
	if not "%oedpf%" == "" (
		set additionalArgs=%additionalArgs% -pf %oedpf%	
	)
)

if "%extraProcedures%" == "" (
	set extraProcedures=%oedcs%
)

%programCaller% -b -p %compilerScript% -param %compilationMode%;%compilerSpecs%;%compilerLogOutput%,%extraProcedures% %additionalArgs%
if %quiet% == 0 if exist %compilerLogOutput% (
	powershell -c $(get-content "%compilerLogOutput%"^)
)
goto PROGRAMEND

:PROGRAMEND
endlocal
@echo on
