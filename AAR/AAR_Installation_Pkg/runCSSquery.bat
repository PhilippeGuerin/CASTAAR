@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

IF "%1" == 1 (
 GOTO :EXECUTE
 ) ELSE (
	CALL config.bat 
)


REM update all SQL query output
REM SQL query should be saved in %AAR%Automation\SQL
REM the output of the query are save in %AAR%Inputs as pPipe Separated Value

   for /f %%f in ('dir /b %_CAST_CSS_query%') do (
		echo executing %%f 
			%_psql% -h %_SERVER% -U %_USER% -d %_DB_NAME% -p %_PORT%  -v v1=%parmeter% -A -P footer -o %_inputs_folder%%%~nxf.psv -f %_CAST_CSS_query%%%f
		echo OK	
	   )
ECHO(
ECHO(   