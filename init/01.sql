CREATE USER mxs@'%' IDENTIFIED BY 'password';
GRANT ALL ON *.* TO mxs@'%';

CREATE USER app_user@'%' IDENTIFIED BY 'password';
GRANT ALL ON testdb.* to app_user@'%';
