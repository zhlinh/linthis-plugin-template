---
name: lt-cmsg
description: >
  验证并自动修复 git 提交信息，使其符合 Conventional Commits 规范。
  分析暂存区 diff 选择正确的 type 前缀（feat/fix/refactor 等），
  检查标题长度和格式，自动改写不合规的提交信息。
  匹配近期提交历史的语言风格（中文/英文）。
  由 linthis 的 commit-msg git hook 触发。
  Validate and auto-fix git commit messages to comply with Conventional Commits format.
  Analyzes staged diff to select correct type prefix, checks subject line format,
  and automatically rewrites malformed messages.
  If the lt-lint skill also exists, both should be invoked together when committing.
---

# Linthis Commit Message Skill

## Companion Skills

When the user asks to commit, if the **lt-lint** skill is also available, both lt-lint and lt-cmsg should be invoked together. Run lt-lint first (to fix code issues), then lt-cmsg (to validate the commit message).

## Goal

Ensure every commit message follows Conventional Commits format and accurately reflects the actual code changes. A well-structured commit history makes code review, changelog generation, and git bisect much easier.

## When to Skip

If the commit message already complies with all rules below, approve immediately with `✅ Commit message OK`.

## Steps

1. Read the commit message from `.git/COMMIT_EDITMSG`
2. Run `git diff --cached --stat` to understand what files actually changed — the type prefix must match the actual diff, not just what the developer wrote
3. Run `git log -n 5 --oneline` to check the recent commit style **and language** (Chinese or English) — match that language for the description part, because consistency in the git log improves readability
4. Evaluate the message against these rules:
   - **Type prefix** (optional but encouraged): `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
   - **Scope** (optional): `feat(module): description`
   - **Subject line**: ≤72 characters, imperative mood, starts with lowercase after the colon
   - **No trailing period** on subject line
   - **Body** (if present): wrapped at 80 characters, explains *why* not *what*
5. If the message is acceptable, output `✅ Commit message OK` and approve
6. If improvements are needed, choose the correct `type` based on the staged diff, then **automatically rewrite** `.git/COMMIT_EDITMSG` — do NOT ask for confirmation

## Type Selection Guide

Select the type by examining what the staged diff actually contains, not by guessing from the message text:

| Type | When to use | Example diff pattern |
|------|-------------|---------------------|
| **feat** | New feature or functionality | New files, new exported functions/endpoints |
| **fix** | Bug fix | Changed condition/logic in existing code |
| **refactor** | Code restructured, no behavior change | Renamed, moved, or reorganized code |
| **perf** | Performance improvement | Algorithm change, caching, reduced allocations |
| **docs** | Documentation only | .md files, comments only |
| **style** | Formatting, whitespace, lint fixes | No logic change |
| **test** | Adding or updating tests | *_test.* files |
| **build** | Build scripts, deps, CI config | Makefile, package.json, go.mod |
| **chore** | Maintenance, tooling | Config not affecting src |

## Examples

**Good messages:**

```
feat: add plugin config merge on plugin add
fix: resolve TempDir lifetime issue in resolver
docs: update hook config spec with self keyword approach
refactor: extract common utility functions
```

**Bad → Fixed:**

```
# Bad: wrong type (diff shows a bug fix, not a feature)
feat: fix login crash on empty password
# Fixed:
fix(auth): handle empty password input gracefully

# Bad: too long, trailing period, past tense
feat: Added the new user authentication module with JWT support and refresh tokens.
# Fixed:
feat(auth): add JWT-based authentication with refresh tokens

# Bad: vague, no type prefix
update code
# Fixed (based on diff showing refactored utils):
refactor(utils): extract shared validation logic
```
