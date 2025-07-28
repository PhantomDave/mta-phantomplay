FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    lib32gcc-s1 \
    tree \
    unzip \
    wget \
    libmysqlclient21

RUN groupadd -r mtauser && \
    useradd -r -g mtauser -d /opt/mta -s /bin/bash mtauser

WORKDIR /opt/mta

RUN mkdir -p /opt/mta && \
    chown -R mtauser:mtauser /opt/mta

ADD https://linux.multitheftauto.com/dl/multitheftauto_linux_x64.tar.gz /tmp/mta.tar.gz
RUN tar -xzf /tmp/mta.tar.gz --strip-components=1 && \
    rm /tmp/mta.tar.gz && \
    chmod +x mta-server64 && \
    chown -R mtauser:mtauser /opt/mta

ADD https://linux.multitheftauto.com/dl/baseconfig.tar.gz /tmp/baseconfig.tar.gz
RUN tar -xf /tmp/baseconfig.tar.gz -C mods/deathmatch && \
    rm /tmp/baseconfig.tar.gz && \
    chown -R mtauser:mtauser /opt/mta/mods

ADD https://mirror.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip /tmp/mtasa-resources.zip
RUN unzip /tmp/mtasa-resources.zip -d mods/deathmatch/resources/ && \
    rm /tmp/mtasa-resources.zip && \
    chown -R mtauser:mtauser /opt/mta/mods/deathmatch/resources
COPY mta-server.conf mods/deathmatch/mtaserver.conf
COPY acl.xml mods/deathmatch/acl.xml

RUN chmod 777 mods/deathmatch/mtaserver.conf && \
    chown mtauser:mtauser mods/deathmatch/mtaserver.conf


RUN mkdir -p mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay && \
    chown -R mtauser:mtauser mods/deathmatch/resources/[gamemodes] \
    && chmod -R 777 mods/deathmatch/resources/[gamemodes]

COPY . mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay

RUN tree mods/deathmatch/resources/[gamemodes]/

RUN chown -R mtauser:mtauser mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay && \
    chmod -R 777 mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay


USER mtauser

EXPOSE 22003/udp
EXPOSE 22126/tcp

CMD ["/bin/bash", "-c", "./mta-server64 & tail -F mods/deathmatch/logs/server.log"]
