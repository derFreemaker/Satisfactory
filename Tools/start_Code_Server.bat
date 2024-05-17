@echo off
setlocal enabledelayedexpansion

set SRVROOT=%1

echo %SRVROOT%

%SRVROOT%\bin\httpd.exe -d %SRVROOT% -f %SRVROOT%\conf\httpd.conf

endlocal
