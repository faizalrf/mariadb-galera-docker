#!/bin/bash

StartUp="/usr/local/bin/docker-entrypoint.sh mysqld"

# If BOOTSTRAP argument is passed as 1 then start the node as galera_new_cluster
if [ ${BOOTSTRAP} -eq 1 ]; then
   StartUp="${StartUp} --wsrep-new-cluster"
   sed -i -e 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat
else
   sed -i -e 's/safe_to_bootstrap: 1/safe_to_bootstrap: 0/g' /var/lib/mysql/grastate.dat
fi

exec ${StartUp}