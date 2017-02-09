@echo off

REM --add the following to the top of your bat file--


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

REM ------------------------------------------------------------------------------
REM ------
REM ------	CONFIGURATION AREA 
REM ------
REM ------------------------------------------------------------------------------

SET client=AAR

CALL config.bat 

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------
REM ------
REM ------	FILE SYSTEM 
REM ------
REM ------------------------------------------------------------------------------

if not exist "%_installation_folder%" mkdir %_installation_folder%
if not exist "%_inputs_folder%" mkdir %_inputs_folder%
if not exist "%_views_folder%" mkdir %_views_folder%
if not exist "%_CAST_Feed_folder%" mkdir %_CAST_Feed_folder%
if not exist "%_CAST_Reports_folder%" mkdir %_CAST_Reports_folder%
if not exist "%_CAST_CSS_query%" mkdir %_CAST_CSS_query%

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------
REM ------	
REM ------	Refresh Feed Automation
REM ------
REM ------------------------------------------------------------------------------	

ECHO(
ECHO(
ECHO Prepare APMQ Inputs Files...
ECHO(

COPY config.bat %_CAST_Feed_folder%
COPY get_JSON_RestAPI.bat %_CAST_Feed_folder%
COPY runCSSQuery.bat %_CAST_Feed_folder%

   for /f %%f in ('dir /b cssQuery\') do (
		echo COPY %%f 
			COPY cssQuery\%%f %_CAST_CSS_query%
	   )
	   
COPY curl.exe %_CAST_Feed_folder%
COPY reports/Dashboard_Checks.xlsm %_CAST_Reports_folder%
COPY Refresh_Data.bat %_CAST_Feed_folder%
COPY replace_all_in_folder.ps1 %_CAST_Feed_folder%

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------
REM ------	
REM ------	Add the JDBC Driver PSQL to the Apache drill installation 
REM ------
REM ------------------------------------------------------------------------------	


ECHO(
ECHO(
ECHO Prepare JDBC PSQL Plugin...
ECHO(

COPY postgresql-9.1-901-1.jdbc4.jar %apache_drill_installation%jars\3rdparty

REM ECHO(
REM ECHO(
REM ECHO If it is your first installation, restart APACHE DRILL NOW...
REM pause 
REM ECHO(



REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------
REM ------	 
REM ------	RUN CSS sample SQL Query 
REM ------
REM ------------------------------------------------------------------------------

CALL runCSSQuery.bat 1


REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------
REM ------	 
REM ------	CREATE & SEND PSQL Plugin 
REM ------
REM ------------------------------------------------------------------------------

ECHO(
ECHO(
ECHO Creating the PSQL plugin...
	%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy Unrestricted -File prepare_JSON_psql_plugin.ps1 "%_SERVER%" "%_DB_NAME%" "%_PORT%" "%_USER%" "%_PASSWORD%"
ECHO OK!
ECHO Sending the PSQL plugin to Apache-Drill...
	curl -X POST -H "Content-Type: application/json" -d @psql_plugin\psql_plugin.json %_url_drill_storage%
ECHO OK!

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------
REM ------	 
REM ------	CREATE & SEND JSON Storage Plugin 
REM ------
REM ------------------------------------------------------------------------------

ECHO(
ECHO(
ECHO Creating the storage plugin...
	%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy Unrestricted -File prepare_JSON_drill_storage.ps1 "%client%"
ECHO OK!
ECHO Sending the storage plugin to Apache-Drill...
	curl -X POST -H "Content-Type: application/json" -d @storage_plugin\storage_plugin.json %_url_drill_storage%
ECHO OK!

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------
REM ------	 
REM ------	CREATE & SEND JSON Views 
REM ------
REM ------------------------------------------------------------------------------

ECHO(
ECHO(
ECHO POWERSHELL - Creating the custom views for this account...
ECHO(
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy Unrestricted -File prepare_JSON_views.ps1 "%client%"

ECHO(
ECHO(
ECHO Creating the basic views in Apache-Drill...

for /f %%f in ('dir /b %cd%\views\') do (
		echo sending %%f 
		
			curl -X POST -H "Content-Type: application/json" -d @views\%%f %_url_drill_views%
		echo OK	
	   )


REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------



REM ------------------------------------------------------------------------------
REM ------	 
REM ------	GET JSON Files from CAST RestAPI 
REM ------
REM ------------------------------------------------------------------------------
set /P c=Do you want to update input data using RestAPI [Y/N]?
if /I "%c%" EQU "Y" CALL get_JSON_RestAPI.bat 1

	

:END
ECHO(
ECHO(
ECHO AAR! ...CAST is Drilliant :) 
ECHO(
ECHO(
pause
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	