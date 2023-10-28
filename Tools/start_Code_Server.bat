@echo off
setlocal enabledelayedexpansion

set "workspaceFolder=%1"
set SRVROOT=%2

rem Start Apache using the temporary httpd.conf file
%SRVROOT%\bin\httpd.exe -d %SRVROOT% -f %SRVROOT%\conf\httpd.conf

endlocal
