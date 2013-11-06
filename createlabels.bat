@echo off

call "%~dp0\config.cmd"

set /p GITHUB_ORGANIZATION="Please specify the organization (leave blank, if it corresponds to '%GITHUB_USERNAME%'): "
set /p GITHUB_REPOSITORY="Please specify the name of the GitHub Repository to create the labels for: "
set /p LABEL_SETS="Please specify the label set(s) (leave blank for 'default', use comma delimited list for bulk operation): "

rem set proxy environment
rem ---------------------
IF "%PROXY_HOST%" == "" GOTO :PROXY_DONE
SET CMD_PROXY=--proxy %PROXY_PROTOCOL%://%PROXY_USER%:%PROXY_PASSWORD%@%PROXY_HOST%:%PROXY_PORT%
echo.
echo Using proxy definition: %CMD_PROXY%

:PROXY_DONE

rem set organization
rem ----------------
IF NOT "%GITHUB_ORGANIZATION%" == "" GOTO :ORGANIZATION_SET_DONE
SET GITHUB_ORGANIZATION=%GITHUB_USERNAME%
echo.
echo Using organization: %GITHUB_ORGANIZATION%

:ORGANIZATION_SET_DONE

rem set label set
rem -------------
IF NOT "%LABEL_SETS%" == "" GOTO :LABEL_SETS_DONE
SET LABEL_SETS=default
echo.
echo Using label set: %LABEL_SETS%

:LABEL_SETS_DONE

echo.
echo Current labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels

call :LOOP_LABEL_SETS "%LABEL_SETS%"
goto :END

:LOOP_LABEL_SETS
setlocal
set LABEL_SET_LIST=%~1

for /F "tokens=1* delims=," %%f in ("%LABEL_SET_LIST%") do (
	rem if the item exist
	if not "%%f" == "" call :MODIFY_LABEL_SETS %%f
	rem if next item exist
	if not "%%g" == "" call :LOOP_LABEL_SETS "%%g"
)
endlocal

:END

echo.
echo New labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels

pause
exit

:MODIFY_LABEL_SETS

echo Actual labelset: %1

echo.
echo Deleting labels ...
for /r ".\labelset\%1\delete" %%F in (*) do (
	echo Deleting ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request DELETE https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels/%%~nxF
)

echo.
echo Creating labels ...
for /r ".\labelset\%1\create" %%F in (*) do (
	echo Creating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request POST https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels --data @labelset\%1\create\%%~nxF
)

echo.
echo Updating labels ...
for /r ".\labelset\%1\update" %%F in (*) do (
	echo Updating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request PATCH https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels/%%~nxF --data @labelset\%1\update\%%~nxF
)