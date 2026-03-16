---
name: lt-review
description: >
  推送前审查待推送的提交，检查代码质量、安全性和正确性问题。
  检查本地 HEAD 与远程分支的完整 diff，发现逻辑错误、
  安全漏洞（注入、硬编码密钥）、代码质量问题及测试覆盖缺失。
  将发现分为阻塞、重要和轻微三个等级。
  由 linthis 的 pre-push git hook 触发。
  Review outgoing commits for quality, security, and correctness before pushing.
  Catches logic errors, security vulnerabilities, code quality issues,
  and missing test coverage. Categorizes as blocking/important/minor.
  Triggered by pre-push hook.
---

# Linthis Review Skill

## Goal

Catch issues that lint can't — logic errors, security vulnerabilities, architectural problems, and missing test coverage. This is the last automated quality gate before code reaches the remote, so focus on issues that would be costly to fix after pushing.

## When to Skip

If there are no outgoing commits (local is up-to-date with remote), approve immediately.

## Steps

1. Run `git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline` to list outgoing commits
2. Run `git diff origin/$(git rev-parse --abbrev-ref HEAD)..HEAD` to see the full diff
3. Review the diff across these dimensions:

   | Dimension | What to look for | Severity |
   |-----------|-----------------|----------|
   | **Correctness** | Logic errors, off-by-one, unhandled edge cases, race conditions | Blocking if affects functionality |
   | **Security** | SQL/command injection, hardcoded secrets, insecure defaults, path traversal | Blocking |
   | **Code quality** | Unnecessary complexity, duplication, missing error handling | Important |
   | **Test coverage** | New features without tests, changed logic without updated tests | Important |

4. Categorize and report findings:
   - **Blocking** (`🚫 Push blocked`) — Must fix before push. Security vulnerabilities, data loss risks, or correctness bugs
   - **Important** (`⚠️ Push with caution`) — Should fix, but can proceed with user confirmation
   - **Clean** (`✅ Review passed`) — No significant issues found

## Output Format

```
### 🚫 Blocking Issues

1. **[src/db.go:42] SQL injection risk** — User input concatenated directly into query string.
   Fix: Use parameterized query `db.Query("SELECT * FROM users WHERE id = ?", id)`

### ⚠️ Important Issues

1. **[src/handler.go:15] Missing error handling** — `os.Open()` error is ignored.
   Fix: Check and handle the error, or return it to caller.

2. **[src/service.go:80] No test coverage** — New `ProcessBatch` function has no test.
   Fix: Add test cases covering normal, empty, and error inputs.

### ✅ No other issues found
```

## Review Principles

- **Focus on the diff, not the whole file** — only review what changed, unless context is needed to understand the change
- **Explain why something is a problem** — "SQL injection lets attackers execute arbitrary queries" is more actionable than just "SQL injection found"
- **Suggest concrete fixes** — show the corrected code when possible, not just "fix this"
- **Don't nitpick style** — that's what the lint skill handles. Focus on logic, security, and architecture
