@echo off
setlocal

set CMD=%1

if "%CMD%"=="init" goto init
if "%CMD%"=="start" goto start

echo Usage: zskarte.bat init ^| start
exit /b 1


:init
echo Running INIT workflow...

docker compose -f mapserv-init/docker-compose.yml run --rm offlinekarte-tileserver-init
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

docker compose -f searchserv-db-init/docker-compose.yml up --build --abort-on-container-exit --exit-code-from searchserv-loader
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo Init complete.
exit /b 0


:start
echo Starting services...

REM TODO: adjust to your real runtime setup
docker compose up -d
IF %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo Services started.
exit /b 0