# Dockerfile for the 2.4 GA version of MariaDB MaxScale
FROM ubuntu:focal

COPY maxscale.list /etc/apt/sources.list.d/maxscale.list.tmp

RUN apt-get -y update && \
    apt-get -y install gnupg2 ca-certificates less sysstat wget curl && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "0xE3C94F49" && \
    mv /etc/apt/sources.list.d/maxscale.list.tmp /etc/apt/sources.list.d/maxscale.list && \
    apt-get -y update && \
    apt-get -y install maxscale && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
RUN chmod +x mariadb_repo_setup
RUN ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6"
RUN apt -y update && \
    apt -y install mariadb-client

COPY maxscale.cnf /etc/
COPY monitor.sh /var/lib/maxscale
COPY .maxinfo /var/lib/maxscale

RUN chown maxscale:maxscale /var/lib/maxscale/.maxinfo && chown maxscale:maxscale /var/lib/maxscale/monitor.sh
RUN chmod 400 /var/lib/maxscale/.maxinfo && chmod 750 /var/lib/maxscale/monitor.sh

ENTRYPOINT ["maxscale", "-d", "-U", "maxscale", "-l", "stdout"]
