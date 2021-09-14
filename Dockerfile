FROM mariadb:latest

COPY startup.sh /startup.sh

USER mysql:mysql
CMD /startup.sh

