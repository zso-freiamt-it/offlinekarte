#!/usr/bin/env bash
set -e

CMD=$1

if [ "$CMD" = "init" ]; then
    echo "Running INIT workflow..."

    docker compose -f mapserv-init/docker-compose.yml run --rm offlinekarte-tileserver-init
    docker compose -f searchserv-db-init/docker-compose.yml up --build --abort-on-container-exit --exit-code-from searchserv-loader
    docker compose -f zskarte/docker-compose-init.yml up --build --abort-on-container-exit
    
    echo "Init complete."

elif [ "$CMD" = "start" ]; then
    echo "Starting services..."

    docker compose up -d

    echo "Services started."

else
    echo "Usage: ./zskarte.sh {init|start}"
    exit 1
fi
