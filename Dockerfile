FROM mariadb:10.6

COPY startup.sh /startup.sh

USER mysql:mysql
CMD /startup.sh

