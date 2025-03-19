@echo off
setlocal
set prowin=%DLC%\bin\prowin.exe
set compilerScript=%~dp0^compiler-cli.p

goto GETOPTIONS

:HELP

cat "%~dp0help.txt"
goto PROGRAMEND

:GETOPTIONS
if /I "%1" == "-h" goto HELP
if /I "%1" == "-c" (
	set compilerSpecs=%2
	set compilationMode=c
	shift
	shift
)
if /I "%1" == "-s" (
	set compilerSpecs=%2
	set compilationMode=s
	shift
	shift
)
if /I "%1" == "-n" (
	copy %~dp0^project-template.json %2
	goto PROGRAMEND
)
if /I "%1" == "-ininame" (
	set additionalArgs=%additionalArgs% -basekey "ini" -ininame %2
	shift
	shift
)
if /I "%1" == "-p" (
	set extraProcedures=%2
	shift
	shift
)
if /I "%1" == "-pf" (
	set additionalArgs=%additionalArgs% -pf %2
	shift
	shift
)
if /I "%1" == "-pf1" (
	set additionalArgs=%additionalArgs% -pf %oepf1%
	shift
)
if /I "%1" == "-pf2" (
	set additionalArgs=%additionalArgs% -pf %oepf2%
	shift
)

shift
if /I "%1" == "" (
	goto RUNCOMPILATIONCMD
)

goto GETOPTIONS

:RUNCOMPILATIONCMD
if "%compilerScript%" == "" (
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

%prowin% -p %compilerScript% -param %compilationMode%;%compilerSpecs%,%extraProcedures% %additionalArgs%

goto PROGRAMEND

:PROGRAMEND
endlocal
@echo on
