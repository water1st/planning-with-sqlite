---
name: planning-with-sqlite
description: Implements Manus-style planning using a local SQLite database (via MCP) to organize and track progress on complex tasks. Creates and uses planning.db. Use when asked to plan out, break down, or organize a multi-step project, research task, or any work requiring 5+ tool calls.
user-invocable: true
allowed-tools: "Read Write Edit Bash Glob Grep query_database"
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "if [ -f planning.db ]; then echo '[planning-with-sqlite] ACTIVE PLAN — Use MCP to query planning.db for current state and context.'; fi"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "if [ -f planning.db ]; then echo '[planning-with-sqlite] Update progress_logs in planning.db with what you just did. If a phase is now complete, update its status in the phases table.'; fi"
  Stop:
    - hooks:
        - type: command
          command: "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"& (Get-ChildItem -Path (Join-Path ~ '.claude/plugins/cache') -Filter check-complete.ps1 -Recurse -EA 0 | Select-Object -First 1).FullName\" 2>/dev/null || sh \"$(ls $HOME/.claude/plugins/cache/*/*/*/scripts/check-complete.sh 2>/dev/null | head -1)\" 2>/dev/null || true"
metadata:
  version: "3.0.0"
---

# Planning with SQLite (MCP)

Work like Manus, but structured: Use a persistent SQLite database (`planning.db`) accessed via the Model Context Protocol (MCP) as your "working memory."

## FIRST: Restore Context

**Before doing anything else**, check if `planning.db` exists in the project root. If it does, use your `query_database` MCP tool (or equivalent SQLite tool) to read the current state:

```sql
-- Check current tasks
SELECT * FROM tasks;

-- Check phases and their status
SELECT * FROM phases;

-- Check recent progress logs
SELECT * FROM progress_logs ORDER BY created_at DESC LIMIT 5;
```

## Quick Start: Initializing a Session

Before ANY complex task, check if `planning.db` exists in the **current project directory**. If it does not exist, initialize it locally:

**Linux/macOS:**
```bash
# Use the script from the skill installation path to initialize the local DB
sh "${CLAUDE_PLUGIN_ROOT}/scripts/init-session.sh" "$(basename "$PWD")"
```

**Windows:**
```powershell
# Use the script from the skill installation path to initialize the local DB
& "$env:USERPROFILE\.claude\skills\planning-with-files\scripts\init-session.ps1" (Split-Path -Leaf (Get-Location))
```

Once initialized, use **MCP SQL tools** (if available) to insert the initial plan.
*Fallback: If the `query_database` tool is not available in your environment, use the standard `sqlite3 planning.db "SQL_QUERY"` CLI command.*

```sql
-- 1. Create the task
INSERT INTO tasks (title, goal) VALUES ('CLI App', 'Create a Python CLI todo app');

-- 2. Create phases
INSERT INTO phases (task_id, phase_number, title, status) VALUES 
(1, 1, 'Requirements & Discovery', 'in_progress'),
(1, 2, 'Planning & Structure', 'pending'),
(1, 3, 'Implementation', 'pending');
```

## The Core Pattern

```
Context Window = RAM (volatile, limited)
SQLite Database = Disk (persistent, structured, queryable)

→ Anything important gets written to the database.
```

## Database Schema (Summary)

- **`tasks`**: High-level goals.
- **`phases`**: The breakdown of the task into steps (status: `pending`, `in_progress`, `complete`).
- **`findings`**: Research discoveries, observations, and external knowledge.
- **`decisions`**: Technical choices and their rationale.
- **`issues`**: Errors encountered and how they were resolved.
- **`progress_logs`**: A chronological record of actions taken.

## Critical Rules

### 1. Create Plan First
Never start a complex task without initializing `planning.db` and populating the `tasks` and `phases` tables.

### 2. The 2-Action Rule
After every 2 view/browser/search operations, IMMEDIATELY insert key findings into the `findings` table.

```sql
INSERT INTO findings (task_id, phase_id, description) VALUES (1, 1, 'Discovered that argparse supports subparsers.');
```

### 3. Query Before Decide
Before major decisions, query the database to refresh your goals and constraints.

### 4. Update After Act
After completing any phase:
- Update phase status: `UPDATE phases SET status = 'complete' WHERE id = ?;`
- Log the session progress: `INSERT INTO progress_logs (phase_id, actions_taken) VALUES (?, ?);`

### 5. Log ALL Errors
Every error goes into the `issues` table. This builds knowledge and prevents repetition.

```sql
INSERT INTO issues (task_id, description, resolution) VALUES (1, 'FileNotFoundError on config.json', 'Created default config file.');
```

### 6. Never Repeat Failures
Query the `issues` table to see what you've already tried. If an action failed, mutate the approach.

## When to Use This Pattern

**Use for:**
- Multi-step tasks (3+ steps)
- Research tasks
- Building/creating projects
- Tasks spanning many tool calls

**Skip for:**
- Simple questions
- Single-file edits
- Quick lookups
