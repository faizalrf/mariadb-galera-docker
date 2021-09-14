#!/bin/bash

StartUp="/usr/local/bin/docker-entrypoint.sh mysqld"

# If BOOTSTRAP argument is passed as 1 then start the node as galera_new_cluster
if [ ${BOOTSTRAP} -eq 1 ]; then
   StartUp="${StartUp} --wsrep-new-cluster"
fi

exec ${StartUp}