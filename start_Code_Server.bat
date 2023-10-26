@echo off
setlocal enabledelayedexpansion

set "workspaceFolder=%1"

set SRVROOT=%workspaceFolder%\Code-Server

rem Create a temporary httpd.conf file
(for /f "tokens=*" %%a in (%workspaceFolder%\Code-Server\conf\httpd.conf) do (
    set "line=%%a"
    echo !line:%workspaceFolder%\Code Server=%SRVROOT%!
)) > %workspaceFolder%\Code-Server\conf\temp-httpd.conf

rem Start Apache using the temporary httpd.conf file
%workspaceFolder%\Code-Server\bin\httpd.exe -d %workspaceFolder%\Code-Server -f %workspaceFolder%\Code-Server\conf\temp-httpd.conf

endlocal