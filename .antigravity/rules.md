# Workspace Rules

## Flutter Hot Reload Rule
**Scope:** Always Apply

- Whenever you finish creating, editing, or deleting any `.dart` file, you MUST trigger a Flutter Hot Reload before completing your turn.
- **First choice (MCP):** Invoke the `hot_reload` tool from the Dart MCP server if active.
- **Second choice (Terminal/PID):** If `.flutter.pid` exists in the project root, execute `kill -USR1 $(cat .flutter.pid)` via terminal.
- If `pubspec.yaml` or `main()` initializers were modified, trigger a Hot Restart (`hot_restart` tool or `kill -USR2`) instead.
