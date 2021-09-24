CREATE USER mxs@'%' IDENTIFIED BY 'password';
GRANT ALL ON *.* TO mxs@'%';

CREATE USER app_user@'%' IDENTIFIED BY 'password';
GRANT ALL ON testdb.* to app_user@'%';

CREATE USER mariabackup@localhost identified by 'password';
GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT, REPLICATION SLAVE ADMIN ON *.* TO mariabackup@localhost;
