# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to non-interactive
# ENV DEBIAN_FRONTEND=noninteractive

# Add i386 architecture and install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    lib32gcc-s1 \
    tree \
    unzip \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Create mtauser with appropriate permissions
RUN groupadd -r mtauser && \
    useradd -r -g mtauser -d /opt/mta -s /bin/bash mtauser

# Create a directory for the MTA server
WORKDIR /opt/mta

# Create the directory and set ownership
RUN mkdir -p /opt/mta && \
    chown -R mtauser:mtauser /opt/mta

# Download and extract the latest MTA:SA server
ADD https://linux.multitheftauto.com/dl/multitheftauto_linux_x64.tar.gz /tmp/mta.tar.gz
RUN tar -xzf /tmp/mta.tar.gz --strip-components=1 && \
    rm /tmp/mta.tar.gz && \
    chmod +x mta-server64 && \
    chown -R mtauser:mtauser /opt/mta

# Download and extract base configuration
ADD https://linux.multitheftauto.com/dl/baseconfig.tar.gz /tmp/baseconfig.tar.gz
RUN tar -xf /tmp/baseconfig.tar.gz -C mods/deathmatch && \
    rm /tmp/baseconfig.tar.gz && \
    chown -R mtauser:mtauser /opt/mta/mods

# Download and extract default resources
ADD https://mirror.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip /tmp/mtasa-resources.zip
RUN unzip /tmp/mtasa-resources.zip -d mods/deathmatch/resources/ && \
    rm /tmp/mtasa-resources.zip && \
    chown -R mtauser:mtauser /opt/mta/mods/deathmatch/resources
# Copy server configuration
COPY mta-server.conf mods/deathmatch/mtaserver.conf
COPY acl.xml mods/deathmatch/acl.xml

RUN chmod 644 mods/deathmatch/mtaserver.conf && \
    chown mtauser:mtauser mods/deathmatch/mtaserver.conf


# Create a directory for our gamemode
RUN mkdir -p mods/deathmatch/resources/[gamemodes]/phantomplay && \
    chown -R mtauser:mtauser mods/deathmatch/resources/[gamemodes]

# Copy gamemode files
COPY account/ mods/deathmatch/resources/[gamemodes]/phantomplay/account/
COPY house/ mods/deathmatch/resources/[gamemodes]/phantomplay/house/
COPY database/ mods/deathmatch/resources/[gamemodes]/phantomplay/database/
COPY shared/ mods/deathmatch/resources/[gamemodes]/phantomplay/shared/
COPY utils.lua mods/deathmatch/resources/[gamemodes]/phantomplay/utils.lua
COPY meta.xml mods/deathmatch/resources/[gamemodes]/phantomplay/meta.xml

# Set ownership and permissions for gamemode files
RUN chown -R mtauser:mtauser mods/deathmatch/resources/[gamemodes]/phantomplay && \
    chmod -R 755 mods/deathmatch/resources/[gamemodes]/phantomplay

# Switch to the mtauser
USER mtauser

# Expose MTA server ports
EXPOSE 22003/udp
EXPOSE 22126/tcp

# Keep the container running so you can exec into it
CMD ["./mta-server64"]
