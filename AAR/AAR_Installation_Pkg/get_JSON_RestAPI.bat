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

:EXECUTE 
ECHO(
ECHO(
ECHO REST API - Getting the needed JSON files...
ECHO(


REM RestAPI queries
	SET Applications="%url%AAD/applications"
	SET FP="%url%AAD/results?sizing-measures=(functional-weight-measures)&snapshots=($all)"
	SET Business-Criteria="%url%AAD/results?quality-indicators=(business-criteria)&snapshots=($all)&applications=($all)"
	SET Technical-Debt="%url%AAD/results?sizing-measures=(technical-debt-statistics)&snapshots=($all)"
	
	SET CV="%url%AAD/results?select=evolutionSummary&snapshots=($all)&applications=($all)"
	
	SET Compliance="%url%AAD/results?select=(violationRatio)&quality-indicators=(quality-rules)&technologies=($all)&snapshots=(-1)&application=($all)"
	REM SET Compliance="%url%AAD/results?select=(violationRatio)&quality-indicators=(quality-rules)&technologies=($all)&snapshots=($all)&application=($all)"
	
	SET Size="%url%AAD/results?sizing-measures=(technical-size-measures)&snapshots=($all)"
	SET Snapshots="%url%AAD/results?snapshots=($all)"
	SET AllDimensions="%url%AAD/results?quality-indicators=(61001,61003,61004,61006,61007,61008,61009,61010,61011,61013,61014,61015,61016,61017,61018,61019,61020,61022,61023,61024,61026,61027,61028,61029,61031,66008,66009,66062,66063,66064,66065,66066,66068,66069,66070)&snapshots=($all)&application=($all)"

	  SET ModuleSizeStats="%url%AAD/results?sizing-measures=(technical-size-measures)&modules=$all&snapshots=-2&applications=$all"
      SET ModuleCVStats="%url%AAD/results?sizing-measures=(critical-violation-statistics)&modules=$all&snapshots=-2&applications=$all"
	  SET ModuleTechDebtStats="%url%AAD/results?sizing-measures=(technical-debt-statistics)&modules=$all&snapshots=-2&applications=$all"
      SET ModuleFunctWeightStats="%url%AAD/results?sizing-measures=(functional-weight-measures)&modules=$all&snapshots=-2&applications=$all"
	
REM run Rest API command
	  curl -k -H "Accept: application/json"  -u "%user%" %Applications% -o %_inputs_folder%CLIENT-Application.json
	ECHO 	getting FP measures .... %Applications%
	 curl -k -H "Accept: application/json"  -u "%user%" %FP% -o %_inputs_folder%CLIENT-FP.json
	ECHO 	getting Business Crieria scores .... %FP%
	 curl -k -H "Accept: application/json"  -u "%user%" %Business-Criteria% -o %_inputs_folder%CLIENT-BusinessCriteria.json
	ECHO getting Technical Debt scores .... %Business-Criteria% 
	 curl -k -H "Accept: application/json"  -u "%user%" %Technical-Debt% -o %_inputs_folder%CLIENT-TechnicalDebt.json
	ECHO 	getting Critical Violations scores .... %Technical-Debt%
	 curl -k -H "Accept: application/json"  -u "%user%" %CV% -o %_inputs_folder%CLIENT-CriticalViolation.json
	ECHO 	getting Compliance scores .... %CV%
	 curl -k -H "Accept: application/json"  -u "%user%" %Compliance% -o %_inputs_folder%CLIENT-Compliance.json
	ECHO 	getting Technical Size data .... %Compliance%
	 curl -k -H "Accept: application/json"  -u "%user%" %Size%  -o %_inputs_folder%CLIENT-Size.json
	ECHO 	getting Technical Attributes scores .... %Size%
	 curl -k -H "Accept: application/json"  -u "%user%" %AllDimensions% -o %_inputs_folder%CLIENT-AllDimensions.json
	ECHO 	getting All dimensions .... %AllDimensions%
	
	 curl -k -H "Accept: application/json"  -u "%user%" %ModuleSizeStats% -o %_inputs_folder%CLIENT-ModuleSizeStats.json
	ECHO 	getting ModuleSizeStats .... %ModuleSizeStats%
	 curl -k -H "Accept: application/json"  -u "%user%" %ModuleCVStats% -o %_inputs_folder%CLIENT-ModuleCVStats.json
	ECHO 	getting ModuleCVStats .... %ModuleCVStats%
	 curl -k -H "Accept: application/json"  -u "%user%" %ModuleTechDebtStats% -o %_inputs_folder%CLIENT-ModuleTechDebtStats.json
	ECHO 	getting ModuleTechDebtStats .... %ModuleTechDebtStats%
	 curl -k -H "Accept: application/json"  -u "%user%" %ModuleFunctWeightStats% -o %_inputs_folder%CLIENT-ModuleFunctWeightStats.json
	ECHO 	getting ModuleFunctWeightStats .... %ModuleFunctWeightStats%
	
	
REM ------------------------------------------------------------------------------
REM ------	 
REM ------	Clean JSON Files from CAST RestAPI 
REM ------
REM ------------------------------------------------------------------------------

ECHO(
ECHO(
ECHO Cleaning the JSON files from RestAPI (infinity bug)...
	%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy Unrestricted -File replace_all_in_folder.ps1 %_inputs_folder% "-Infinity" "0.0"
ECHO OK!