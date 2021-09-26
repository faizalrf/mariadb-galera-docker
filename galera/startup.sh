#!/bin/bash

# TODO Add logic for bootstrap! 
StartUp="/usr/local/bin/docker-entrypoint.sh mysqld"

# If BOOTSTRAP argument is passed as 1 then start the node as galera_new_cluster
if [ ${BOOTSTRAP} -eq 1 ]; then
   if [ -f /var/lib/mysql/bootstrap.ind ]; then
      StartUp="${StartUp} --wsrep-new-cluster"
   fi
fi

rm -rf /var/lib/mysql/bootstrap.ind

exec ${StartUp}