@echo off

call %~dp0\config.cmd

set /p GITHUB_ORGANIZATION="Please specify the organization (leave blank, if it corresponds to '%GITHUB_USERNAME%'): "
set /p GITHUB_REPOSITORY="Please specify the GitHub Repository: "
set /p LABEL_SET="Please specify the label set (leave blank for 'default'): "

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
IF NOT "%LABEL_SET%" == "" GOTO :LABEL_SET_DONE
SET LABEL_SET=default
echo.
echo Using label set: %LABEL_SET%

:LABEL_SET_DONE

echo.
echo Current labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels

echo.
echo Deleting labels ...
for /r ".\labelset\%LABEL_SET%\delete" %%F in (*) do (
	echo Deleting ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request DELETE https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels/%%~nxF
)

echo.
echo Creating labels ...
for /r ".\labelset\%LABEL_SET%\create" %%F in (*) do (
	echo Creating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request POST https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels --data @labelset\%LABEL_SET%\create\%%~nxF
)

echo.
echo Updating labels ...
for /r ".\labelset\%LABEL_SET%\update" %%F in (*) do (
	echo Updating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" --request PATCH https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels/%%~nxF --data @labelset\%LABEL_SET%\update\%%~nxF
)

echo.
echo New labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USERNAME%:%GITHUB_PASSWORD%" https://api.github.com/repos/%GITHUB_ORGANIZATION%/%GITHUB_REPOSITORY%/labels

pause