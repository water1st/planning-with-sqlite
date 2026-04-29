# Planning with SQLite

> SQLite-powered task planning for AI agents — a persistent, queryable alternative to planning-with-files.

A plugin/skill that transforms your AI agent workflow to use a persistent local SQLite database (`planning.db`) for planning, progress tracking, and knowledge storage.

## The Problem

AI agents (like Claude Code, Cursor, etc.) suffer from:

- **Volatile memory** — Context resets erase plans and goals.
- **Goal drift** — After 50+ tool calls, original goals get forgotten.
- **Hidden errors** — Failures aren't tracked, so the same mistakes repeat.
- **Context stuffing** — Everything crammed into context instead of stored structurally.

## The Solution: SQLite + MCP

This project replaces the traditional 3-file markdown pattern (`task_plan.md`, `findings.md`, `progress.md`) with a **normalized SQLite database** accessed via the **Model Context Protocol (MCP)**.

```
Context Window = RAM (volatile, limited)
SQLite Database = Disk (persistent, structured, queryable)

→ Anything important gets written to the database.
```

### Database Schema

- **`tasks`**: High-level goals and project descriptions.
- **`phases`**: The breakdown of the task into completable steps.
- **`findings`**: Research discoveries, observations, and external knowledge.
- **`decisions`**: Technical choices and their rationale.
- **`issues`**: Errors encountered and how they were resolved.
- **`progress_logs`**: A chronological record of actions taken.

## Installation

Since this SQLite version is currently not published to the global Agent Skills registry, you need to install it manually:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/water1st/planning-with-sqlite.git
   cd planning-with-sqlite
   ```

2. **Copy the skill to your global agents folder:**
   
   For the standard Agent Skills ecosystem (`~/.agents/skills/`):
   ```bash
   # Create the skills directory if it doesn't exist
   mkdir -p ~/.agents/skills
   
   # Copy the specific skill folder
   cp -r skills/planning-with-files ~/.agents/skills/planning-with-sqlite
   ```

   Alternatively, for Claude Code (`~/.claude/skills/`):
   ```bash
   mkdir -p ~/.claude/skills
   cp -r skills/planning-with-files ~/.claude/skills/planning-with-sqlite
   ```
   
   *(On Windows, you can copy the `skills\planning-with-files` folder into `%USERPROFILE%\.agents\skills\planning-with-sqlite` or `%USERPROFILE%\.claude\skills\planning-with-sqlite`)*

## Usage

Once installed, the AI agent will:

1. **Initialize the Database**: If `planning.db` does not exist, the agent or you can initialize it using the provided scripts.
2. **Create the Plan**: Insert tasks and phases into the database via MCP SQL tools.
3. **Query Before Decisions**: The agent will query the database to refresh its goals and constraints.
4. **Log Findings & Errors**: The agent immediately inserts key findings into the `findings` table and errors into the `issues` table.
5. **Update Progress**: After completing a phase, the agent updates its status and logs the session progress.

## Quick Start

### 1. Initialize a Session

Before ANY complex task, if `planning.db` does not exist in your **current project directory**, initialize it locally:

**Linux/macOS:**
```bash
# If installed globally via Claude Code skills
sh "${CLAUDE_PLUGIN_ROOT}/scripts/init-session.sh" "$(basename "$PWD")"
```

**Windows:**
```powershell
# If installed globally via Claude Code skills
& "$env:USERPROFILE\.claude\skills\planning-with-files\scripts\init-session.ps1" (Split-Path -Leaf (Get-Location))
```

### 2. Connect MCP Server (Recommended)

Ensure your AI environment is running the official `@modelcontextprotocol/server-sqlite` and is connected to the `planning.db` in your project root.

*Fallback: If MCP is not available or configured, the AI agent is instructed to use the standard `sqlite3` CLI command (`sqlite3 planning.db "..."`) to read and write to the database.*

### 3. Start Planning

Ask your AI agent to begin the task. It will use the `query_database` tool to insert the initial plan:

```sql
-- Example: Creating the task
INSERT INTO tasks (title, goal) VALUES ('CLI App', 'Create a Python CLI todo app');

-- Example: Creating phases
INSERT INTO phases (task_id, phase_number, title, status) VALUES 
(1, 1, 'Requirements & Discovery', 'in_progress'),
(1, 2, 'Planning & Structure', 'pending'),
(1, 3, 'Implementation', 'pending');
```

## Scripts

Helper scripts for automation are located in the `scripts/` directory:

- `init-session.sh` / `init-session.ps1` — Initialize the SQLite database.
- `init_db.py` — The underlying Python script that creates the schema.
- `check-complete.sh` / `check-complete.ps1` — Verifies if all phases in the database are marked as complete.
- `check_complete.py` — The underlying Python script that queries phase completion.

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

MIT — feel free to use, modify, and distribute.
