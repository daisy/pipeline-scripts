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
ECHO     Converts FILE to an EPUB 2.0 publication.
ECHO     FILE must be a valid ZedAI book document.
ECHO.
ECHO Options:
ECHO     -o FILE : the name of the created EPUB 2.0 publication
ECHO               default is name_of_the_input_document.epub
ECHO     -h      : print this help
ECHO     -v      : verbose
ECHO.
ECHO Example:
ECHO     %CMD% sample/alice.xml
ECHO     %CMD% -o test.epub sample/alice.xml
GOTO:EOF

:Continue

set IN_FILE=%1
IF "%IN_FILE%"=="" (
	ECHO The input ZedAI document must be set
	ECHO.
	GOTO Usage
)

set CP=
for %%f IN (%LIB_DIR%\*.jar) do set CP=!CP!;%%f

%JAVA% -classpath %CP%  -Dcom.xmlcalabash.phonehome=false com.xmlcalabash.drivers.Main -c file:///%CONF_DIR:\=/%/calabash-config.xml %MODULE_DIR%\xproc\zedai2epub.xpl href=%IN_FILE:\=/% output=%OUT_FILE:\=/%

IF "%OUT_FILE%"=="" (
	RD /S /Q epub
) ELSE (
	FOR %%A IN ("%OUT_FILE%") DO RD /S /Q %%~dpA\epub
)