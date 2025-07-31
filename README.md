# MTA PhantomPlay Development Environment

A comprehensive Multi Theft Auto (MTA) server development environment using VS Code Dev Containers with Docker Compose. This setup provides everything you need to develop, test, and debug MTA resources in an isolated, reproducible environment.

## 🚀 Quick Start

### Prerequisites

- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (or Docker Engine + Docker Compose)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PhantomDave/mta-phantomplay.git
   cd mta-phantomplay
   ```

2. **Open in VS Code:**
   ```bash
   code .
   ```

3. **Reopen in Container:**
   - VS Code will prompt you to "Reopen in Container" when it detects the `.devcontainer` folder
   - Alternatively, press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) and select "Dev Containers: Reopen in Container"
   - Or use the workspace file: `File > Open Workspace from File` and select `workspace.code-workspace`

4. **Wait for the container to build:**
   - First time setup will take a few minutes as Docker downloads and builds the container
   - Subsequent starts will be much faster

## 🏗️ What's Included

### Development Environment
- **MTA Server**: Pre-configured Multi Theft Auto server
- **MariaDB Database**: Full MySQL-compatible database with phpMyAdmin
- **VS Code Extensions**: Lua language support, debugging tools, and more
- **Linux Environment**: Ubuntu 20.04.6 LTS with Zsh shell

### Pre-installed Tools
- Git (latest version from source)
- Lua language server and debugging tools
- MySQL client
- Common utilities: `curl`, `wget`, `vim`, `nano`, `htop`, and more

### Port Forwarding
The following ports are automatically forwarded from the container:
- **22003** (UDP): MTA Server Game Port
- **22126**: MTA Server HTTP Port  
- **22005**: MTA Server ASE Port
- **3306**: MariaDB Database
- **8080**: phpMyAdmin Web Interface

## 🗂️ Project Structure

```
/workspace/
├── mta-phantomplay/           # Main project directory
│   ├── .devcontainer/         # Dev container configuration
│   ├── guieditor/            # GUI Editor resource
│   ├── phantomplay/          # Main gamemode resource
│   ├── docker-compose.yml    # Docker services configuration
│   └── Dockerfile           # MTA server container definition
├── multitheftauto_linux_x64/ # MTA server binaries
└── workspace.code-workspace  # VS Code workspace configuration
```

## 🔧 Development Workflow

### Starting the MTA Server

The MTA server starts automatically when the container launches. You can also control it manually:

```bash
# Start the server (if not running)
sudo systemctl start mta-server

# Stop the server
sudo systemctl stop mta-server

# Restart the server
sudo systemctl restart mta-server

# View server logs
sudo journalctl -u mta-server -f
```

### Database Access

**Using MySQL Client (Command Line):**
```bash
mysql -h db -u my_user -p mta_sa
# Password: user_password
```

**Using phpMyAdmin (Web Interface):**
- Open http://localhost:8080 in your browser
- Username: `my_user`
- Password: `user_password`
- Database: `mta_sa`

### Resource Development

1. **Edit resources** in the `phantomplay/` or `guieditor/` directories
2. **Hot reload**: Changes are automatically synced to the running server
3. **Restart resources** in-game using: `/restart [resource-name]`
4. **View logs** in the terminal or MTA server console

### Testing Your Changes

1. **Connect to your server:**
   - IP: `localhost` or `127.0.0.1`
   - Port: `22003`

2. **Use MTA client** to connect and test your gamemode

## 🛠️ Configuration

### Environment Variables

The following environment variables are available in the container:

- `MTA_DEV=true`: Development mode flag
- `DATABASE_HOST=db`: Database hostname
- `DATABASE_PORT=3306`: Database port
- `DATABASE_NAME=mta_sa`: Database name
- `DATABASE_USER=my_user`: Database username
- `DATABASE_PASSWORD=user_password`: Database password

### VS Code Settings

The devcontainer includes pre-configured settings for:
- Lua language support with MTA-specific globals
- Terminal defaults to `/workspace` directory
- Integrated debugger configuration
- File associations for MTA resources

### Custom Setup Scripts

- **setup.sh**: Runs after container creation (one-time setup)
- **post-start.sh**: Runs every time the container starts

## 🐛 Debugging

### Lua Debugging
- Set breakpoints in your Lua code
- Use the integrated debugger in VS Code
- Output debug information with `outputDebugString()`

### Server Logs
```bash
# View real-time MTA server logs
tail -f /opt/mta/mods/deathmatch/logs/server.log

# View resource-specific logs
tail -f /opt/mta/mods/deathmatch/logs/resources.log
```

### Database Debugging
```bash
# Check database connection
mysql -h db -u my_user -p -e "SHOW DATABASES;"

# Monitor database queries (if query logging is enabled)
mysql -h db -u my_user -p -e "SHOW PROCESSLIST;"
```

## 🔄 Docker Compose Services

### MTA Server (`mta-server`)
- Builds from the included Dockerfile
- Mounts your code for hot-reloading
- Runs the MTA server daemon

### Database (`db`)
- MariaDB 10.5 instance
- Persistent data storage
- Pre-configured with development database

### phpMyAdmin (`phpmyadmin`)
- Web-based database management
- Accessible at http://localhost:8080

## 📚 Useful Commands

### Container Management
```bash
# Rebuild the container (if you modify Dockerfile or dependencies)
# In VS Code: Ctrl+Shift+P > "Dev Containers: Rebuild Container"

# View running containers
docker ps

# View container logs
docker-compose logs mta-server
```

### MTA Server Management
```bash
# Check server status
sudo systemctl status mta-server

# View server configuration
cat /opt/mta/mods/deathmatch/mtaserver.conf

# List running resources
# (Connect to server and use /aclrequest console command)
```

### File Operations
```bash
# The workspace directory is automatically set to /workspace
cd /workspace

# All your project files are available here
ls -la
```

## 🤝 Contributing

1. Make your changes in the appropriate resource directories
2. Test thoroughly using the development server
3. Commit your changes following conventional commit format
4. Create a pull request with a clear description

## 🆘 Troubleshooting

### Container Won't Start
- Ensure Docker is running
- Check for port conflicts (22003, 22126, 3306, 8080)
- Try rebuilding the container

### Server Won't Connect
- Verify port 22003 is accessible
- Check firewall settings
- Ensure the MTA server is running: `sudo systemctl status mta-server`

### Database Connection Issues
- Verify database service is running: `docker-compose ps`
- Check credentials in environment variables
- Test connection: `mysql -h db -u my_user -p`

### Hot Reload Not Working
- Check file permissions
- Verify file paths in docker-compose.yml watch configuration
- Restart the container if needed

---

## 📝 Notes

- The default workspace folder is set to `/workspace` for consistency
- All MTA-specific Lua globals are pre-configured for IntelliSense
- The environment supports both server-side and client-side resource development
- Database changes persist between container restarts via Docker volumes

Happy coding! 🎮