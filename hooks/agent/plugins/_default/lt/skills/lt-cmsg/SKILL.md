---
name: lt-cmsg
description: >
  通过 linthis cmsg 校验并自动修复 git 提交信息格式。
  校验规则以 .linthis/config.toml [cmsg] 配置为准（默认为 Conventional Commits 规范）。
  校验失败时分析 diff 和报错提示自动改写提交信息，匹配近期提交历史的语言风格（中文/英文）。
  由 linthis 的 commit-msg git hook 触发。
  Validate and auto-fix git commit messages via linthis cmsg.
  Validation rules are driven by .linthis/config.toml [cmsg] (defaults to Conventional Commits).
  On failure, rewrites the message based on linthis error output and staged diff analysis.
  If the lt-lint skill also exists, both should be invoked together when committing.
---

# Linthis Commit Message Skill

## Companion Skills

When the user asks to commit, if the **lt-lint** skill is also available, both lt-lint and lt-cmsg should be invoked together. Run lt-lint first (to fix code issues), then lt-cmsg (to validate the commit message).

## Goal

Ensure every commit message follows Conventional Commits format and accurately reflects the actual code changes. A well-structured commit history makes code review, changelog generation, and git bisect much easier.

## When to Skip

If `linthis cmsg .git/COMMIT_EDITMSG` passes on the first run, approve immediately with `✅ Commit message OK`.

## Configuration

The validation pattern is configurable via `.linthis/config.toml`:

```toml
[cmsg]
commit_msg_pattern = "^(feat|fix|docs|...)\\(\\S+\\)?: .{1,72}"
require_ticket = false          # require ticket reference e.g. [JIRA-123]
ticket_pattern = "\\[\\w+-\\d+\\]"  # custom ticket regex
```

`linthis cmsg` reads this config automatically — your validation always reflects the project's actual rules, not hardcoded defaults.

## Steps

1. Run `linthis cmsg .git/COMMIT_EDITMSG` — this is the **authoritative validator** and reads `.linthis/config.toml` automatically
2. If linthis cmsg **passes** → output `✅ Commit message OK` and approve immediately
3. If linthis cmsg **fails** → read the error output to understand what rule was violated, then:
   - Run `git diff --cached --stat` to understand what files actually changed — the type prefix must match the actual diff
   - Run `git log -n 5 --oneline` to check the recent commit style **and language** (Chinese or English) — match that language for consistency
   - **Automatically rewrite** `.git/COMMIT_EDITMSG` based on the linthis error hints + diff analysis — do NOT ask for confirmation
4. Re-run `linthis cmsg .git/COMMIT_EDITMSG` to confirm the rewrite passes

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
