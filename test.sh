#!/bin/bash
set -e

# random name with timestamp as prefix to give a cleanup script more information
PROJECT_NAME=$(TZ=UTC date +"%Y%m%d%H%M%S")$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8 ; echo)

function cleanup {
  # capture the original exit code
  code=$?
  echo "cleaning up"

  # ignore errors on docker-compose down
  set +e
  docker-compose --project-name ${PROJECT_NAME} down

  # exit with original exit code
  exit $code
}

# run cleanup when the script exits
trap cleanup EXIT

docker-compose --project-name ${PROJECT_NAME} build test
docker-compose --project-name ${PROJECT_NAME} run test "$@"
