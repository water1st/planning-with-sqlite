# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-29

### Added
- **SQLite Database Integration:** Fully migrated from a 3-file markdown pattern to a normalized local SQLite database (`planning.db`).
- **MCP Server Support:** Added comprehensive instructions (`SKILL.md`) for AI agents to query and update the database natively using the Model Context Protocol (`@modelcontextprotocol/server-sqlite`).
- **Automated Initialization:** New `init_db.py` script automatically creates `tasks`, `phases`, `findings`, `decisions`, `issues`, and `progress_logs` tables.
- **Python-based Status Check:** Replaced text-parsing logic with `check_complete.py` that accurately counts phase completion via raw SQL queries.
- **Unit Tests:** Added Python `unittest` suite for database initialization and completion status checking.

### Changed
- **CLI Commands:** Updated `/plan` and `/start` descriptions to reflect the new SQLite logic.
- **Hooks Migration:** Shell and PowerShell scripts (`init-session` & `check-complete`) now invoke the Python SQL integration instead of writing dummy markdown files.
- **Installation Strategy:** Refactored `README.md`

### Removed
- Deprecated legacy markdown template generation for `task_plan.md`, `findings.md`, and `progress.md`.

---
## [Original] - Pre-fork versions
- Initial file-based implementation by OthmanAdi (planning-with-files up to v2.35.0).
