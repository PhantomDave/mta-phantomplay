# Copilot Instructions for mta-phantomplay

## General Guidelines
- Use Lua best practices for MTA:SA scripting.
- Follow the existing project structure and naming conventions.
- Prioritize code readability and maintainability.
- Use comments to explain non-obvious logic, especially in event handlers and database interactions.

## Commit Message Format
- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for all commit messages.
- Example: `feat(account): add password hashing to login events`

## Event Handling
- Register and handle events using `addEvent` and `addEventHandler` as shown in `login_events.lua`.
- Always check for valid `client` before proceeding with player actions.
- Use `triggerClientEvent` for client-server communication.

## Authentication & Character Selection
- Use functions like `loginUser`, `isTableNotEmpty`, and `GetCharactersByAccountId` for authentication and character management.
- On successful login, spawn the player and open character selection as in `login_events.lua`.
- On failure, provide clear feedback to the user via `outputChatBox`.

## File Organization
- Place server-side logic in `[server]` folders and client-side logic in `[client]` folders.
- Use the `shared/` folder for constants and code shared between client and server.

## Database
- Use the `database/` folder for all database-related scripts.
- Follow the structure in `database_init.lua` and other database files for queries and connections.

## Docker & Deployment
- Use the provided `Dockerfile` and `docker-compose.yml` for containerization and deployment.
- Update documentation in `README.md` when making changes that affect setup or usage.

## Additional Notes
- Always test event handlers and database changes before committing.
- Document new features and changes in `README.md` if relevant.

---
This file guides GitHub Copilot and contributors to maintain consistency and quality in the mta-phantomplay project.
