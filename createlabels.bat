@echo off

call "%~dp0\config.cmd"

set /p GITHUB_ACCOUNT="Please specify the GitHub user or organization (leave blank, if it corresponds to '%GITHUB_USERNAME%'): "
set /p GITHUB_REPOSITORIES="Please specify the GitHub Repository name(s) to create the labels for (leave blank for '%DEFAULT_GITHUB_REPOSITORIES%', use comma delimited list for bulk operation): "
set /p LABEL_SETS="Please specify the label set(s) (leave blank for '%DEFAULT_LABEL_SETS%', use comma delimited list for bulk operation): "

rem **************************************************
rem Check config for GitHub username and password
rem **************************************************
IF "%GITHUB_USERNAME%" == "" (
	echo.
	echo [ERROR] No GitHub username defined.
	GOTO :END
)
IF "%GITHUB_PASSWORD%" == "" (
	echo.
	echo [ERROR] No GitHub password defined.
	GOTO :END
)

rem **************************************************
rem Set the proxy environment
rem **************************************************
IF "%PROXY_HOST%" == "" GOTO :PROXY_DONE
SET CMD_PROXY=--proxy %PROXY_PROTOCOL%://%PROXY_USER%:%PROXY_PASSWORD%@%PROXY_HOST%:%PROXY_PORT%
echo.
echo Using proxy definition: %CMD_PROXY%

:PROXY_DONE

rem **************************************************
rem Set GitHub account
rem **************************************************
IF NOT "%GITHUB_ACCOUNT%" == "" GOTO :GITHUB_ACCOUNT_SET_DONE
SET GITHUB_ACCOUNT=%GITHUB_USERNAME%
IF "%GITHUB_ACCOUNT%" == "" (
	echo.
	echo [ERROR] No GitHub account defined.
	GOTO :END
)
echo.
echo Using GitHub account: %GITHUB_ACCOUNT%

:GITHUB_ACCOUNT_SET_DONE

rem **************************************************
rem Set the GitHub repositories
rem **************************************************
IF NOT "%GITHUB_REPOSITORIES%" == "" GOTO :GITHUB_REPOSITORIES_DONE
SET GITHUB_REPOSITORIES=%DEFAULT_GITHUB_REPOSITORIES%
IF "%GITHUB_REPOSITORIES%" == "" (
	echo.
	echo [ERROR] No GitHub repositories defined.
	GOTO :END
)
echo.
echo Using GitHub repositories: %GITHUB_REPOSITORIES%

:GITHUB_REPOSITORIES_DONE

rem **************************************************
rem Set the label sets
rem **************************************************
IF NOT "%LABEL_SETS%" == "" GOTO :LABEL_SETS_DONE
SET LABEL_SETS=%DEFAULT_LABEL_SETS%
IF "%LABEL_SETS%" == "" (
	echo.
	echo [ERROR] No label sets defined.
	GOTO :END
)
echo.
echo Using label sets: %LABEL_SETS%

:LABEL_SETS_DONE

call :LOOP "%GITHUB_REPOSITORIES%" "%LABEL_SETS%"
goto :END

rem **************************************************
rem The loop through repositories and label sets
rem **************************************************
:LOOP
setlocal
set GITHUB_REPOSITORY_LIST=%~1
set LABEL_SET_LIST=%~2

for /F "tokens=1* delims=," %%f in ("%GITHUB_REPOSITORY_LIST%") do (
	rem if the item exist
	if not "%%f" == "" (
		echo Actual repository: %%f
		call :PRINT_OLD_LABELS %%f
		for /F "tokens=1* delims=," %%v in ("%LABEL_SET_LIST%") do (
			rem if the item exist
			if not "%%v" == "" call :MODIFY_LABEL_SETS %%f %%v
			rem if next item exist
			if not "%%w" == "" call :LOOP "%GITHUB_REPOSITORY_LIST%" "%%w"
		)
	)
	rem if next item exist
	if not "%%g" == "" call :LOOP "%%g" "%LABEL_SETS%"
)
endlocal

rem The end of the script
:END

echo.
pause
exit

rem **************************************************
rem Print the current labels
rem **************************************************
:PRINT_OLD_LABELS

echo.
echo Current labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ACCOUNT%/%1/labels

goto :CLEAR

rem **************************************************
rem Print the new labels
rem **************************************************
:PRINT_NEW_LABELS

echo.
echo New labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ACCOUNT%/%1/labels

goto :CLEAR

rem **************************************************
rem Modify the labels
rem **************************************************
:MODIFY_LABEL_SETS

echo Actual label set: %2

echo.
echo Deleting labels ...
for /r ".\labelset\%2\delete" %%F in (*) do (
	echo Deleting ... %%~nxF
 	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request DELETE https://api.github.com/repos/%GITHUB_ACCOUNT%/%1/labels/%%~nxF
)

echo.
echo Creating labels ...
for /r ".\labelset\%2\create" %%F in (*) do (
	echo Creating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request POST https://api.github.com/repos/%GITHUB_ACCOUNT%/%1/labels --data @labelset\%2\create\%%~nxF
)

echo.
echo Updating labels ...
for /r ".\labelset\%2\update" %%F in (*) do (
	echo Updating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request PATCH https://api.github.com/repos/%GITHUB_ACCOUNT%/%1/labels/%%~nxF --data @labelset\%2\update\%%~nxF
)

goto :CLEAR

rem **************************************************
rem Define end of methods
rem **************************************************
:CLEAR
echo.