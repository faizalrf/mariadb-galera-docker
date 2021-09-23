#!/bin/bash

TableName=tab2
UserName=app_user
PassWord=password
maxHost=127.0.0.1
Port=5002

mariadb -u ${UserName} -p${PassWord} -h${maxHost} -P${Port} -e "DROP TABLE IF EXISTS testdb.${TableName}; CREATE DATABASE IF NOT EXISTS testdb; CREATE TABLE IF NOT EXISTS testdb.${TableName} (id serial, c1 varchar(100), ts timestamp(6));"

i=1
while [ $? -eq 0 ]
do
    echo "INSERT INTO testdb.${TableName}(c1) VALUES (CONCAT('Data - ', ROUND(RAND() * 100000, 0)));"
    echo "UPDATE testdb.${TableName} SET c1 = CONCAT('Data - ', ROUND(RAND() * 100000, 0)) LIMIT 1000;"
    echo -e "SELECT concat('SELECT FROM ${TableName} on ', @@hostname, ' ->'), rpad($i, 10, '.'), 
                IF(COUNT(*)> 0, '\033[0;32mRecord Found\033[0m','\033[0;31m! Not Found !\033[0m' ) 
            FROM testdb.${TableName} WHERE id = $i;"
    i=$((i+6))
    sleep 0.03
done | mariadb -N -u ${UserName} -p${PassWord} -h${maxHost} -P${Port}
