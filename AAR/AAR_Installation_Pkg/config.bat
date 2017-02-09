REM ------------------------------------------------------------------------------
REM ------
REM ------	CONFIGURATION THE FOLLOWING PARAMETER
REM ------
REM ------------------------------------------------------------------------------

REM *************
REM Apache Drill Installation folder
REM Make sure you update Apache Drill installation folder
SET apache_drill_installation=C:\apache-drill-1.6.0\

REM *************
REM Rest API configuration
REM Set the URL and Login credential for your target RestAPI.  
SET url=http://demo-us.castsoftware.com/AAD/rest/
SET user=admin:cast

REM   Make sure to change the path of the psql command 
set _psql= "C:\Program Files\CAST\CASTStorageService2\bin\psql.exe"
 
REM *************
REM Configure access to CSS2
REM JDBC POSTGRESQL Configuration 
SET _SERVER=localhost
SET _DB_NAME=postgres
SET _PORT=2280
SET _USER=operator
SET _PASSWORD=CastAIP
SET _appnameForQualityModel=wpf_training8


REM ************************** DO NOT CHANGE ANYTHING BELOW THIS LINE ****************************************
REM ************************** unless you do what you are doing :) *******************************************

REM File System 
SET _installation_folder=C:\AAR\
SET _views_folder=%_installation_folder%Views\
SET _inputs_folder=%_installation_folder%Inputs\
SET _CAST_Feed_folder=%_installation_folder%Automation\
SET _CAST_Reports_folder=%_installation_folder%Reports\
SET _CAST_CSS_query=%_CAST_Feed_folder%SQL\

REM Apache Drill URLs
SET _url_drill_storage=http://127.0.0.1:8047/storage/query.json
SET _url_drill_views=http://127.0.0.1:8047/query.json 

REM ------------------------------------------------------------------------------
REM ------------------------------------------------------------------------------