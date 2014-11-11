@echo off

rem GitHub definition
rem GITHUB_USERNAME and GITHUB_PASSWORD are required
rem ---------------------------------
SET GITHUB_USERNAME=<YOUR_USERNAME>
SET GITHUB_PASSWORD=<YOUR_PASSWORD>

rem Proxy definition (only if needed)
rem ---------------------------------
SET PROXY_PROTOCOL=
SET PROXY_USER=
SET PROXY_PASSWORD=
SET PROXY_HOST=
SET PROXY_PORT=

rem CURL path (only edit, if another curl path will be used)
rem --------------------------------------------------------
SET CURL_PATH=.\curl

rem Default values
SET DEFAULT_GITHUB_REPOSITORIES=
SET DEFAULT_LABEL_SETS=default