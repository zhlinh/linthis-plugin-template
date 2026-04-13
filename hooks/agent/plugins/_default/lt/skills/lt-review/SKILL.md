---
name: lt-review
description: >
  推送前审查待推送的提交，检查代码质量、安全性和正确性问题。
  检查本地 HEAD 与远程分支的完整 diff，发现逻辑错误、
  安全漏洞（注入、硬编码密钥）、代码质量问题及测试覆盖缺失。
  将发现分为阻塞、重要和轻微三个等级。
  由 linthis 的 pre-push git hook 触发。
  与 lt-lint 的 security/complexity 检查互补：lt-lint 用 SAST 工具做模式匹配，
  lt-review 用 AI 做语义级审查（逻辑错误、架构问题、上下文相关的安全风险）。
  Review outgoing commits for quality, security, and correctness before pushing.
  Catches logic errors, security vulnerabilities, code quality issues,
  and missing test coverage. Categorizes as blocking/important/minor.
  Complements lt-lint's SAST checks with semantic-level AI review.
  Triggered by pre-push hook.
---

# Linthis Review Skill

## Goal

Catch issues that automated tools can't — logic errors, architectural problems, context-dependent security risks, and missing test coverage. This is the last quality gate before code reaches the remote, so focus on issues that would be costly to fix after pushing.

**How this relates to lt-lint**: The lt-lint skill runs SAST tools (pattern-matching scanners like Bandit, Gosec, OpenGrep) and complexity analysis at pre-commit time. This review skill complements those checks with semantic-level understanding — it reads the actual logic and can catch issues like incorrect business logic, subtle race conditions, or security problems that depend on context rather than syntactic patterns.

## Worktree Isolation

When auto-fixing Blocking issues, **prefer working in a worktree** if your agent supports it (e.g. Claude Code). This ensures the main working tree is untouched until fixes are verified. The hook script handles worktree creation automatically.

## Fix Commit Mode

Before starting, check the fix commit mode for pre-push:
```bash
linthis config get hook.pre_push.fix_commit_mode
```
If the command fails, default to `dirty`. The mode determines how auto-fixes for Blocking issues are committed:
- **squash**: fix → `git add` → `git commit --amend --no-verify --no-edit` (amend into latest commit)
- **dirty** (default): fix → leave in working tree → block push, let user review
- **fixup**: fix → `git add` → `git commit --no-verify -m "style(linthis): auto-format"` (create separate fixup commit)

## When to Skip

If there are no outgoing commits (local is up-to-date with remote), approve immediately.

## Steps

1. Run `git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline` to list outgoing commits
2. Run `git diff origin/$(git rev-parse --abbrev-ref HEAD)..HEAD` to see the full diff
3. Review the diff across these dimensions:

   | Dimension | What to look for | Severity |
   |-----------|-----------------|----------|
   | **Correctness** | Logic errors, off-by-one, unhandled edge cases, race conditions | Blocking if affects functionality |
   | **Security** | Context-dependent risks: auth bypass, TOCTOU, unsafe deserialization, privilege escalation | Blocking |
   | **Code quality** | Unnecessary complexity, duplication, missing error handling | Important |
   | **Test coverage** | New features without tests, changed logic without updated tests | Important |

4. Categorize and report findings:
   - **Blocking** (`🚫 Push blocked`) — Must fix before push. Security vulnerabilities, data loss risks, or correctness bugs. **Auto-fix directly**, then verify build/tests pass (see Build Verification below), then re-run review until pass
   - **Important** (`⚠️ Push with caution`) — Should fix, but can proceed with user confirmation. **Must pause and ask user** before pushing
   - **Clean** (`✅ Review passed`) — No significant issues found

### Build Verification (after auto-fix)

After auto-fixing Blocking issues, you **must** verify the fix doesn't break the build:

1. **Save a snapshot** before fixing: `git diff > /tmp/lt-review-before.diff`
2. **Auto-fix** the Blocking issues
3. **Run build/test** to verify:

   | Language | Build check | Test command |
   |----------|------------|-------------|
   | Rust | `cargo check` | `cargo test` |
   | Go | `go build ./...` | `go test ./...` |
   | TypeScript | `npx tsc --noEmit` | `npm test` |
   | Python | `python -m py_compile <file>` | `pytest` |
   | C/C++ | `make` / `cmake --build build` | `make test` / `ctest` |
   | Java/Kotlin | `mvn compile` / `gradle build` | `mvn test` / `gradle test` |

   > Detect project type by checking for `Cargo.toml`, `go.mod`, `package.json`, `pyproject.toml`, `Makefile`/`CMakeLists.txt`, `pom.xml`/`build.gradle` in the project root.

4. If build/tests **fail**: revert the fix, re-analyze the error, and try a different approach. Repeat until both the fix and build/tests pass
5. **Generate diff report** — show what was changed:
   ```bash
   git diff -- <modified files>
   ```
   Display a **Changes Summary**:
   ```
   ## Changes Summary
   - src/foo.rs:42 — fixed SQL injection by switching to parameterized query
   - src/bar.go:80 — added error handling for unchecked return value
   ```
6. **Commit fixes based on fix_commit_mode**:
   - **squash**: `git add` changed files → `git commit --amend --no-verify --no-edit`
   - **fixup**: `git add` changed files → `git commit --no-verify -m "fix(linthis): auto-fix blocking issues"`
   - **dirty**: do NOT commit — leave changes in working tree, **block push**, and tell user to review with `git diff`

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
- **Don't duplicate SAST findings** — if lt-lint's security check already caught a pattern-based issue (hardcoded key, simple injection), don't re-report it. Focus on what automated scanners miss
