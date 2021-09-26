FROM mariadb:10.5

RUN apt -y update
RUN apt -y install pigz

COPY startup.sh /startup.sh

USER mysql:mysql
CMD /startup.sh

