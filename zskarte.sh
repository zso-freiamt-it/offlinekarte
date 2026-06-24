#!/usr/bin/env bash
set -e

CMD=$1

if [ "$CMD" = "init" ]; then
    echo "Running INIT workflow..."

    docker compose -f mapserv-init/docker-compose.yml run --rm offlinekarte-tileserver-init
    docker compose -f searchserv-db-init/docker-compose.yml up --build --abort-on-container-exit --exit-code-from searchserv-loader
    docker compose -f zskarte/docker-compose-init.yml up --build --abort-on-container-exit

    echo "Init complete."

elif [ "$CMD" = "update" ]; then
    echo "Running UPDATE workflow for zskarte..."

    cd zskarte
    docker compose down
    cd ..
    docker compose down

    echo "Containers stopped."
    ./zskarte.sh init

    echo "Starting zskarte services..."
    ./zskarte.sh start -b
    echo "Init complete for zskarte."

elif [ "$CMD" = "start" ]; then
    BUILD_ARG=""
    
    
    if [ "$FLAG" = "-b" ]; then
        BUILD_ARG="--build"
        echo "Starting services and forcing build..."
    else
        echo "Starting services..."
    fi

    docker compose -f zskarte/docker-compose.yml up -d $BUILD_ARG
    docker compose up -d $BUILD_ARG

    echo "Services started."

else
    echo "Usage: $0 {init|update|start [-b]}"
    exit 1
fi
