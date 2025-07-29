# Multi-stage build for maximum caching efficiency
FROM ubuntu:20.04 AS base

# Set environment variables early for better caching
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and create user in optimized layers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    lib32gcc-s1 \
    libmysqlclient21 \
    tree \
    unzip \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd -r mtauser && \
    useradd -r -g mtauser -d /opt/mta -s /bin/bash mtauser && \
    mkdir -p /opt/mta && \
    chown -R mtauser:mtauser /opt/mta

WORKDIR /opt/mta

# MTA Server installation stage
FROM base AS mta-installer

# Copy and run install script (cached unless script changes)
COPY mta-server-install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh && \
    /tmp/install.sh && \
    rm /tmp/install.sh && \
    chown -R mtauser:mtauser /opt/mta

# Final runtime stage
FROM base AS runtime

# Copy MTA server files from installer stage
COPY --from=mta-installer --chown=mtauser:mtauser /opt/mta /opt/mta

WORKDIR /opt/mta/multitheftauto_linux_x64

# Create resource directory structure early (cached unless structure changes)
RUN mkdir -p mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay && \
    chown -R mtauser:mtauser mods/deathmatch/resources/[gamemodes] && \
    chmod -R 777 mods/deathmatch/resources/[gamemodes]

# Copy configuration files (cached unless configs change)
COPY --chown=mtauser:mtauser mta-server.conf mods/deathmatch/mtaserver.conf
COPY --chown=mtauser:mtauser acl.xml mods/deathmatch/acl.xml

# Set permissions for config files
RUN chmod 777 mods/deathmatch/mtaserver.conf

# Copy application code LAST (changes most frequently, minimal cache invalidation)
COPY --chown=mtauser:mtauser . mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay

# Set final permissions for application code
RUN chmod -R 777 mods/deathmatch/resources/[gamemodes]/[phantomplay]/phantomplay

# Switch to non-root user
USER mtauser

# Expose ports
EXPOSE 22003/udp
EXPOSE 22126/tcp

# Health check for better container management
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -f mta-server64 || exit 1

CMD ["/bin/bash", "-c", "./mta-server64 & tail -F mods/deathmatch/logs/server.log"]
