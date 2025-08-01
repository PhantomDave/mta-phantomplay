# PhantomPlay ACL Setup Guide

This document explains the ACL (Access Control List) configuration for the PhantomPlay MTA:SA server.

## ACL Groups Overview

### 1. PhantomPlayAdmin
**Purpose**: Full administrative access to PhantomPlay server
**Members**: Server owners, head administrators
**Permissions**: 
- All server management functions
- Database access
- Player management (kick, ban, mute)
- Resource management
- File operations
- All PhantomPlay-specific commands and functions

### 2. PhantomPlayModerator  
**Purpose**: Moderate player interactions and basic server management
**Members**: Trusted moderators
**Permissions**:
- Basic player management (kick, mute, freeze)
- Player teleportation
- Limited administrative commands
- No database or file access

### 3. PhantomPlayPlayer
**Purpose**: Standard player permissions for roleplay gameplay
**Members**: Regular players
**Permissions**:
- Character management (create, delete, select)
- Basic chat commands (me, do, pm)
- UI interactions
- Vehicle usage
- Report system access

## How to Assign Players to Groups

### Using Console Commands:
```
aclGroupAddObject PhantomPlayAdmin user.PlayerName
aclGroupAddObject PhantomPlayModerator user.PlayerName  
aclGroupAddObject PhantomPlayPlayer user.PlayerName
```

### Using Admin Panel:
1. Access the webadmin panel
2. Navigate to ACL management
3. Select the appropriate group
4. Add the player's username or account

## Available Commands by Group

### PhantomPlayAdmin Commands:
- `/setadmin <player> <level>` - Set admin level
- `/goto <player>` - Teleport to player
- `/gethere <player>` - Bring player to you
- `/freeze <player>` - Freeze player
- `/unfreeze <player>` - Unfreeze player
- `/setmoney <player> <amount>` - Set player money
- `/givemoney <player> <amount>` - Give player money
- `/sethp <player> <amount>` - Set player health
- `/setarmour <player> <amount>` - Set player armour
- `/giveweapon <player> <weapon> <ammo>` - Give weapon
- `/takeweapon <player> <weapon>` - Take weapon
- `/createvehicle <id>` - Create vehicle
- `/destroyvehicle` - Destroy vehicle
- `/repair` - Repair vehicle
- `/settime <hour> <minute>` - Set server time
- `/setweather <id>` - Set weather
- `/setgravity <value>` - Set gravity
- `/setgamespeed <value>` - Set game speed
- `/setwantedlevel <player> <level>` - Set wanted level
- `/setteam <player> <team>` - Set player team
- `/setname <player> <name>` - Set player name
- `/setskin <player> <skin>` - Set player skin
- `/setinterior <player> <interior>` - Set interior
- `/setdimension <player> <dimension>` - Set dimension
- `/jetpack <player>` - Give/remove jetpack
- `/invisible <player>` - Toggle invisibility
- `/noclip <player>` - Toggle noclip
- `/god <player>` - Toggle god mode
- `/adminannounce <message>` - Server announcement
- `/asay <message>` - Admin say
- `/warn <player> <reason>` - Warn player
- `/jail <player> <time> <reason>` - Jail player
- `/unjail <player>` - Unjail player
- `/mute <player> <time>` - Mute player
- `/unmute <player>` - Unmute player
- `/kick <player> <reason>` - Kick player
- `/ban <player> <reason>` - Ban player
- `/unban <player>` - Unban player
- `/reloadacl` - Reload ACL
- `/restart <resource>` - Restart resource
- `/start <resource>` - Start resource
- `/stop <resource>` - Stop resource

### PhantomPlayModerator Commands:
- `/goto <player>` - Teleport to player
- `/gethere <player>` - Bring player to you
- `/freeze <player>` - Freeze player
- `/unfreeze <player>` - Unfreeze player
- `/sethp <player> <amount>` - Set player health
- `/repair` - Repair vehicle
- `/warn <player> <reason>` - Warn player
- `/msay <message>` - Moderator say

### PhantomPlayPlayer Commands:
- `/me <action>` - Roleplay action
- `/do <description>` - Roleplay description
- `/pm <player> <message>` - Private message
- `/report <message>` - Report to admins
- `/stats` - View character stats
- `/time` - Check server time
- `/help` - Help commands
- `/rules` - Server rules
- `/changepassword <old> <new>` - Change password
- `/quitcharacter` - Quit character
- `/createcharacter` - Create new character
- `/deletecharacter` - Delete character

## Security Features

1. **Hierarchical Access**: Each group inherits from appropriate base ACLs
2. **Resource Isolation**: PhantomPlay-specific permissions are separate from core MTA functions
3. **Database Protection**: Only admin-level users can access database functions
4. **File System Security**: File operations restricted to administrators
5. **Command Restrictions**: Commands are properly restricted by user level

## Maintenance

### Regular Tasks:
1. Review group memberships monthly
2. Remove inactive admin accounts
3. Update permissions as new features are added
4. Monitor for permission violations in logs

### Backup:
Always backup the `acl.xml` file before making changes:
```bash
cp acl.xml acl.xml.backup
```

### Testing:
Test permissions with different account levels before deploying to production.

## Troubleshooting

### Common Issues:

1. **Player can't use commands**: Check if they're in the correct ACL group
2. **Permission denied errors**: Verify the command/function has the right permission in the ACL
3. **Database access issues**: Ensure admin users have database permissions
4. **Resource access problems**: Check resource objects are assigned to groups

### Debug Commands:
```
aclGet <aclname>
aclGroupList
aclList
hasObjectPermissionTo <object> <action>
```

## Admin Panel Access

### Web Admin Panel URL:
- **Local/Development**: `http://localhost:22005` or `http://127.0.0.1:22005`
- **Remote Server**: `http://YOUR_SERVER_IP:22005`

### Requirements:
1. **webadmin** resource must be running (configured in mta-server.conf)
2. Account must be in Admin or PhantomPlayAdmin group
3. HTTP port 22005 must be accessible (check firewall settings)

### Login:
- Use your MTA account username and password
- Account must have admin permissions in ACL

### ACL Management via Web Panel:
1. Navigate to **Resources** → **webadmin** → **ACL**
2. Select groups and add/remove users
3. Modify permissions as needed
4. Apply changes and reload ACL

## Notes

- Changes to ACL require server restart or `/reloadacl` command
- Always test changes on a development server first
- Keep detailed logs of ACL modifications
- Regular security audits are recommended

For more information, consult the MTA:SA wiki: https://wiki.multitheftauto.com/wiki/Access_Control_List
