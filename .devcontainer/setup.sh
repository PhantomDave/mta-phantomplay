#!/bin/bash
set -e

echo "🚀 Setting up MTA PhantomPlay Development Environment..."

# Create necessary directories first
mkdir -p /workspace/.devcontainer/scripts
mkdir -p /opt/mta/mods/deathmatch/logs

# Ensure the MTA directory structure exists
sudo mkdir -p /opt/mta/mods/deathmatch/resources/\[gamemodes\]/
sudo mkdir -p /opt/mta/mods/deathmatch/resources/\[gamemodes\]/phantomplay
sudo mkdir -p /opt/mta/mods/deathmatch/resources/\[gamemodes\]/guieditor

# Set up proper permissions for development
sudo chown -R mtauser:mtauser /opt/mta/mods/deathmatch/resources/
sudo chown -R mtauser:mtauser /workspace
sudo chmod -R 755 /opt/mta/mods/deathmatch/resources/

# Copy gamemode files if they exist in workspace but not in MTA resources
# Check multiple possible locations for the source files
PHANTOMPLAY_SOURCE=""
GUIEDITOR_SOURCE=""

# Look for phantomplay source files
if [ -d "/workspace/mta-phantomplay/phantomplay" ]; then
    PHANTOMPLAY_SOURCE="/workspace/mta-phantomplay/phantomplay"
elif [ -d "/workspace/phantomplay" ]; then
    PHANTOMPLAY_SOURCE="/workspace/phantomplay"
fi

# Look for guieditor source files
if [ -d "/workspace/mta-phantomplay/guieditor" ]; then
    GUIEDITOR_SOURCE="/workspace/mta-phantomplay/guieditor"
elif [ -d "/workspace/guieditor" ]; then
    GUIEDITOR_SOURCE="/workspace/guieditor"
fi

# Copy PhantomPlay files if source found and destination is empty
if [ -n "$PHANTOMPLAY_SOURCE" ] && [ ! "$(ls -A /opt/mta/mods/deathmatch/resources/\[gamemodes\]/phantomplay 2>/dev/null)" ]; then
    echo "📁 Copying PhantomPlay gamemode files from $PHANTOMPLAY_SOURCE..."
    cp -r "$PHANTOMPLAY_SOURCE"/* /opt/mta/mods/deathmatch/resources/\[gamemodes\]/phantomplay/
    sudo chown -R mtauser:mtauser /opt/mta/mods/deathmatch/resources/\[gamemodes\]/phantomplay
    echo "✅ PhantomPlay files copied successfully!"
else
    echo "⚠️  PhantomPlay source not found or already exists in MTA resources"
fi

# Copy GUIEditor files if source found and destination is empty
if [ -n "$GUIEDITOR_SOURCE" ] && [ ! "$(ls -A /opt/mta/mods/deathmatch/resources/\[gamemodes\]/guieditor 2>/dev/null)" ]; then
    echo "📁 Copying GUIEditor files from $GUIEDITOR_SOURCE..."
    cp -r "$GUIEDITOR_SOURCE"/* /opt/mta/mods/deathmatch/resources/\[gamemodes\]/guieditor/
    sudo chown -R mtauser:mtauser /opt/mta/mods/deathmatch/resources/\[gamemodes\]/guieditor
    echo "✅ GUIEditor files copied successfully!"
else
    echo "⚠️  GUIEditor source not found or already exists in MTA resources"
fi

# Create a development configuration if it doesn't exist
if [ ! -f /opt/mta/mods/deathmatch/mtaserver.conf.dev ]; then
    cp /opt/mta/mods/deathmatch/mtaserver.conf /opt/mta/mods/deathmatch/mtaserver.conf.dev
    echo "📝 Created development server configuration"
fi

# Install development tools
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    vim \
    nano \
    htop \
    curl \
    jq \
    mysql-client \
    telnet \
    netcat \
    rsync

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
until mysql -h db -u my_user -p user_password -e "SELECT 1" &>/dev/null; do
    echo "Database not ready yet, waiting 2 seconds..."
    sleep 2
done
echo "✅ Database is ready!"

# Create a simple database test
mysql -h db -u my_user -p user_password mta_sa -e "
CREATE TABLE IF NOT EXISTS test_connection (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR(255)
);
INSERT INTO test_connection (message) VALUES ('DevContainer setup completed successfully');
"

echo "✅ Database test table created and populated"

# Create useful aliases and functions for both bash and zsh
for shell_rc in ~/.bashrc ~/.zshrc; do
    if [ -f "$shell_rc" ]; then
        cat >> $shell_rc << 'EOF'

# MTA Development Aliases
alias mta-start='cd /opt/mta/multitheftauto_linux_x64 && ./mta-server64'
alias mta-logs='tail -f /opt/mta/multitheftauto_linux_x64/mods/deathmatch/logs/server.log'
alias mta-restart='pkill -f mta-server64; sleep 2; mta-start'
alias db-connect='mysql -h db -u my_user -puser_password mta_sa'
alias phantomplay='cd /workspace/mta-phantomplay/phantomplay'
alias guieditor='cd /workspace/mta-phantomplay/guieditor'
alias workspace='cd /workspace'
alias project='cd /workspace/mta-phantomplay'
alias mta-resources='cd /opt/mta/mods/deathmatch/resources/\[gamemodes\]'

# Sync functions for development - updated to use correct paths
sync-phantomplay() {
    local source_dir="/workspace/mta-phantomplay/phantomplay"
    local dest_dir="/opt/mta/mods/deathmatch/resources/\[gamemodes\]/phantomplay"
    
    if [ -d "$source_dir" ]; then
        echo "🔄 Syncing PhantomPlay files from $source_dir to MTA resources..."
        rsync -av --delete "$source_dir/" "$dest_dir/"
        echo "✅ PhantomPlay files synced!"
    else
        echo "❌ PhantomPlay source directory not found: $source_dir"
    fi
}

sync-guieditor() {
    local source_dir="/workspace/mta-phantomplay/guieditor"
    local dest_dir="/opt/mta/mods/deathmatch/resources/\[gamemodes\]/guieditor"
    
    if [ -d "$source_dir" ]; then
        echo "🔄 Syncing GUIEditor files from $source_dir to MTA resources..."
        rsync -av --delete "$source_dir/" "$dest_dir/"
        echo "✅ GUIEditor files synced!"
    else
        echo "❌ GUIEditor source directory not found: $source_dir"
    fi
}

sync-all() {
    sync-phantomplay
    sync-guieditor
}

# Quick functions
mta-status() {
    if pgrep -f mta-server64 > /dev/null; then
        echo "✅ MTA Server is running (PID: $(pgrep -f mta-server64))"
    else
        echo "❌ MTA Server is not running"
    fi
}

mta-list-resources() {
    echo "📁 Available resources:"
    ls -la /opt/mta/mods/deathmatch/resources/
    echo ""
    echo "📁 Gamemodes:"
    ls -la /opt/mta/mods/deathmatch/resources/\[gamemodes\]/
}
EOF
    fi
done

echo "🎉 MTA PhantomPlay development environment setup completed!"
echo ""
echo "📚 Useful commands:"
echo "  mta-start          - Start MTA server"
echo "  mta-logs           - View server logs"  
echo "  mta-restart        - Restart MTA server"
echo "  mta-status         - Check server status"
echo "  db-connect         - Connect to database"
echo "  phantomplay        - Navigate to PhantomPlay directory"
echo "  workspace          - Navigate to workspace root"
echo "  mta-resources      - Navigate to MTA resources directory"
echo "  sync-phantomplay   - Sync PhantomPlay files to MTA"
echo "  sync-guieditor     - Sync GUIEditor files to MTA"
echo "  sync-all           - Sync all gamemode files"
echo ""
echo "🌐 Ports:"
echo "  22003 (UDP)   - MTA Game Port"
echo "  22126 (TCP)   - MTA HTTP Port" 
echo "  3306 (TCP)    - MariaDB"
echo "  8080 (TCP)    - phpMyAdmin"
echo ""
echo "📁 File locations:"
echo "  Source files:      /workspace/phantomplay, /workspace/guieditor"
echo "  MTA resources:     /opt/mta/mods/deathmatch/resources/[gamemodes]/"
echo ""
echo "💡 Note: Use 'sync-all' to copy your changes to the MTA server directories"
