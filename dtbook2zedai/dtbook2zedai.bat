@echo off
rem This is the path to Java. Edit this variable to suite your needs.
set JAVA=java

SETLOCAL ENABLEDELAYEDEXPANSION  

set CMD=%~n0
set MODULE_DIR=%~dp0
set COMMON_DIR=%MODULE_DIR%\..\common
set LIB_DIR=%COMMON_DIR%\lib
set CONF_DIR=%COMMON_DIR%\conf
set OUT_FILE=

:Loop
IF "%~1"=="-h" (
	GOTO Usage
)
IF "%~1"=="-o" (
	SHIFT
	GOTO param-o
)
GOTO Continue

:param-o
set OUT_FILE=%1
SHIFT
GOTO Loop

:Usage
ECHO Usage: %CMD% [options] FILE
ECHO     Converts FILE to a ZedAI book.
ECHO     FILE must be a valid DTBook document.
ECHO.
ECHO Options:
ECHO     -o FILE : the name of the created ZedAI document
ECHO               default is name_of_the_input_dtbook-zedai.xml
ECHO     -h      : print this help
ECHO     -v      : verbose
ECHO.
ECHO Example:
ECHO     %CMD% sample/greatpainters.xml
ECHO     %CMD% -o zedai.xml sample/greatpainters.xml
GOTO:EOF

:Continue

set IN_FILE=%1
IF "%IN_FILE%"=="" (
	ECHO The input ZedAI document must be set
	ECHO.
	GOTO Usage
)

IF "%OUT_FILE%"=="" (
	set OUT_FILE=
) ELSE (
	set OUT_FILE=%OUT_FILE:\=/%
)

set CP=
for %%f IN (%LIB_DIR%\*.jar) do set CP=!CP!;%%f

%JAVA% -classpath %CP%  -Dcom.xmlcalabash.phonehome=false com.xmlcalabash.drivers.Main -c file:///%CONF_DIR:\=/%/calabash-config.xml -i source=%IN_FILE:\=/% %MODULE_DIR%\src\dtbook2zedai.xpl output=%OUT_FILE%