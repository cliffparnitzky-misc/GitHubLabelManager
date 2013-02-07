@echo off

call %~dp0\config.cmd

set /p GITHUB_REPOSITORY="Please specify the GitHub Repository: "
set /p LABEL_SET="Please specify the label set: "

IF "%PROXY_HOST%" == "" GOTO :PROXY_DONE

SET CMD_PROXY=--proxy %PROXY_PROTOCOL%://%PROXY_USER%:%PROXY_PASSWORD%@%PROXY_HOST%:%PROXY_PORT%
echo Using proxy definition: %CMD_PROXY%

:PROXY_DONE

IF NOT "%LABEL_SET%" == "" GOTO :LABEL_SET_DONE

SET LABEL_SET=standard
echo Using label set: %LABEL_SET%

:LABEL_SET_DONE

echo.
echo Current labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USER%:%GITHUB_PASSWORD%" https://api.github.com/repos/cliffparnitzky/%GITHUB_REPOSITORY%/labels

echo.
echo Deleting labels ...
for /r ".\labelset\%LABEL_SET%\delete" %%F in (*) do (
	echo Deleting ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USER%:%GITHUB_PASSWORD%" --request DELETE https://api.github.com/repos/%GITHUB_USER%/%GITHUB_REPOSITORY%/labels/%%~nxF
)

echo.
echo Creating labels ...
for /r ".\labelset\%LABEL_SET%\create" %%F in (*) do (
	echo Creating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USER%:%GITHUB_PASSWORD%" --request POST https://api.github.com/repos/cliffparnitzky/%GITHUB_REPOSITORY%/labels --data @labelset\%LABEL_SET%\create\%%~nxF
)

echo.
echo Updating labels ...
for /r ".\labelset\%LABEL_SET%\update" %%F in (*) do (
	echo Updating ... %%~nxF
	%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USER%:%GITHUB_PASSWORD%" --request PATCH https://api.github.com/repos/cliffparnitzky/%GITHUB_REPOSITORY%/labels/%%~nxF --data @labelset\%LABEL_SET%\update\%%~nxF
)

echo.
echo New labels ...
%CURL_PATH%\curl.exe %CMD_PROXY% --insecure --user "%GITHUB_USER%:%GITHUB_PASSWORD%" https://api.github.com/repos/cliffparnitzky/%GITHUB_REPOSITORY%/labels

pause