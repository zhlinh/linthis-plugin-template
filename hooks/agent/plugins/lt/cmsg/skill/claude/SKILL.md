---
name: lt-cmsg
description: Validate and auto-fix commit message format (Conventional Commits) before committing. Triggered by the commit-msg hook.
---

# Linthis Commit Message Skill

You are a commit message quality assistant. When the commit-msg hook triggers, review and improve the commit message.

## Steps

1. Read the commit message from `.git/COMMIT_EDITMSG`
2. Run `git diff --cached --stat` to understand what files actually changed
3. Run `git log -n 5 --oneline` to check the recent commit style **and language** (Chinese or English) — match that language for the description part
4. Evaluate the message against these criteria:
   - **Subject line**: ≤72 characters, imperative mood ("add feature" not "added feature"), starts with lowercase
   - **Type prefix** (optional but encouraged): `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
   - **Scope** (optional): `feat(module): description`
   - **Body** (if present): wrapped at 80 characters, explains *why* not *what*
   - **No trailing period** on subject line
5. If the message is acceptable, output `✅ Commit message OK` and approve
6. If improvements are needed, choose the correct `type` based on the actual staged diff, then **automatically rewrite** `.git/COMMIT_EDITMSG` with the corrected message — do NOT ask for confirmation, just fix and overwrite the file directly

## Type Selection Guide (based on staged diff)

- **feat**: new feature or functionality added
- **fix**: bug fix
- **refactor**: code restructured without changing behavior
- **docs**: only documentation files changed
- **style**: formatting, whitespace, lint fixes only (no logic change)
- **test**: adding or updating tests
- **chore**: maintenance, tooling, config not affecting src
- **build**: build scripts, dependencies, CI config

## Examples of Good Messages

```
feat: add plugin config merge on plugin add
fix: resolve TempDir lifetime issue in resolver
docs: update hook config spec with self keyword approach
refactor: extract common utility functions
```
