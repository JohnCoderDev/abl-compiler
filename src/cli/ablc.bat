@echo off
setlocal
set prowin=%DLC%\bin\prowin.exe
set compilerScript=%~dp0^compiler-cli.p

goto GETOPTIONS

:HELP
echo USAGE:
echo.
echo ablc [-h]
echo 	displays this help
echo.
echo ablc [-n ^<name-of-file.json^>]
echo 	copy the project template to the specified path
echo.
echo ablc [-c ^<compiler-options.json^>] [...OPTIONS]
echo 	compile once according to the specification in the json file
echo.
echo ablc [-s ^<compiler-options.json^>] [...OPTIONS]
echo 	starts the compilation service according with the specified json file
echo.
echo OPTIONS
echo 	-ininame 	= path to the .ini file
echo 	-p		= extra procedures to run before the compilation/compilation service

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

shift
if /I "%1" == "" (
	goto RUNCOMPILATIONCMD
)

goto GETOPTIONS

:RUNCOMPILATIONCMD
if "%compilerScript%" == "" (
	goto HELP
)
%prowin% -p %compilerScript% -param %compilationMode%;%compilerSpecs%,%extraProcedures% %additionalArgs%

goto PROGRAMEND

:PROGRAMEND
endlocal
@echo on
