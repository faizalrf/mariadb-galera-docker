#!/bin/bash

CMD="/usr/local/bin/docker-entrypoint.sh mysqld"

if [ ${BOOTSTRAP} -eq 1 ]; then
   CMD="$CMD --wsrep-new-cluster"
fi

exec $CMD