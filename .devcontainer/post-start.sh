#!/bin/bash
set -e

echo "🔄 Post-start setup for MTA PhantomPlay..."

# Source the aliases we created for the current shell
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
elif [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Check if MTA server is running, if not start it
if ! pgrep -f mta-server64 > /dev/null; then
    echo "🚀 Starting MTA Server..."
    cd /opt/mta/multitheftauto_linux_x64
    nohup ./mta-server64 > /dev/null 2>&1 &
    sleep 3
    
    if pgrep -f mta-server64 > /dev/null; then
        echo "✅ MTA Server started successfully!"
    else
        echo "❌ Failed to start MTA Server. Check logs with 'mta-logs'"
    fi
else
    echo "✅ MTA Server is already running"
fi

# Display connection info
echo ""
echo "🎮 MTA Server Connection Info:"
echo "  Server: localhost:22003"
echo "  Admin Panel: http://localhost:22126"
echo ""
echo "🗄️ Database Connection Info:"
echo "  Host: db (or localhost from host machine)"
echo "  Port: 3306"
echo "  Database: mta_sa"
echo "  User: my_user"
echo "  Password: user_password"
echo "  phpMyAdmin: http://localhost:8080"
echo ""
echo "📁 Your code locations:"
echo "  Workspace: /workspace"
echo "  PhantomPlay source: /workspace/phantomplay"
echo "  MTA resources: /opt/mta/mods/deathmatch/resources/[gamemodes]/phantomplay"
echo ""
echo "🎉 Development environment is ready!"
echo "💡 Use 'workspace' to go to your project root or 'phantomplay' to go to the gamemode folder"
