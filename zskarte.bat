@echo off
setlocal enabledelayedexpansion

set CMD=%~1
set FLAG=%~2

if /I "%CMD%"=="init" (
    echo Running INIT workflow...

    docker compose -f mapserv-init/docker-compose.yml run --rm offlinekarte-tileserver-init
    docker compose -f searchserv-db-init/docker-compose.yml up --build --abort-on-container-exit --exit-code-from searchserv-loader
    docker compose -f zskarte/docker-compose-init.yml up --build --abort-on-container-exit

    echo Init complete.

) else if /I "%CMD%"=="update" (
    echo Running UPDATE workflow for zskarte...

    cd zskarte
    docker compose down
    cd ..
    docker compose down

    echo Containers stopped.
    call "%~nx0" init

    echo Starting zskarte services...
    call "%~nx0" start -b
    echo Init complete for zskarte.

) else if /I "%CMD%"=="start" (
    set "BUILD_ARG="
    
    if /I "%FLAG%"=="-b" (
        set "BUILD_ARG=--build"
        echo Starting services and forcing build...
    ) else (
        echo Starting services...
    )

    docker compose -f zskarte/docker-compose.yml up -d !BUILD_ARG!
    docker compose up -d !BUILD_ARG!

    echo Services started.

) else (
    echo Usage: %~nx0 {init^|update^|start [-b]}
    exit /b 1
)