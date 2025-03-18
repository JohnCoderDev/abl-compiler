@echo off
set prowin="%DLC%\bin\prowin.exe"

goto GETOPTIONS

:HELP

echo USAGE:
echo ablc [-h]
echo 	displays this help
echo.
echo ablc [-c ^<compiler-options.json^>]
echo 	compile once according to the specification in the json file
echo.
echo ablc [-s ^<compiler-options.json^> -t ^<seconds^>]
echo 	start the compiation service with the periodicity of `-t`

goto PROGRAMEND

:GETOPTIONS

if /I "%1" == "-h" goto HELP
if /I "%1" == "-c" (
	set compilerSpecs=%2
	goto COMPILEONCE
)
if /I "%1" == "-s" if "%3" == "-t" (
	set compilerSpecs=%2 
	set interval=%4
	goto SERVICE
)

goto HELP

:COMPILEONCE
echo "compile once called"
echo %compilerSpecs%

goto PROGRAMEND

:SERVICE
echo "compiler service called"
echo %compilerSpecs%
echo %interval%


goto PROGRAMEND

:PROGRAMEND
@echo on
