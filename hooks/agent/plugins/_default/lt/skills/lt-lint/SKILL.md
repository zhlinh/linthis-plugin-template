---
name: lt-lint
description: >
  对暂存/修改的代码文件运行 linthis 质量检查（lint + security + complexity），提交前修复所有问题。
  使用 `linthis -i <file>` 按项目编码规范检查并格式化文件。
  默认运行三类检查：代码规范（lint）、安全扫描（security）、圈复杂度分析（complexity）。
  必须手动编辑修复问题（不能用 linthis --fix）。
  所有错误修复后才允许提交。
  由 linthis 的 pre-commit git hook 触发。
  Run linthis quality checks (lint + security + complexity) on staged/modified code files and fix all issues before committing.
  Uses `linthis -i <file>` against project coding standards.
  Runs three checks by default: code lint, SAST security scanning, and cyclomatic complexity analysis.
  Issues must be fixed by editing code directly.
  If the lt-cmsg skill also exists, both should be invoked together when committing.
---

# Linthis Lint Skill

## Companion Skills

When the user asks to commit, if the **lt-cmsg** skill is also available, both lt-lint and lt-cmsg should be invoked together. Run lt-lint first (to fix code issues), then lt-cmsg (to validate the commit message).

## Goal

Catch and fix code quality issues before they enter the repository. Linthis runs three checks by default — code lint, security scanning, and complexity analysis — so a single command covers style, vulnerabilities, and maintainability.

## When to Skip

If no code files were modified in this session, approve immediately.

## What linthis checks

| Check | What it catches | Tools |
|-------|----------------|-------|
| **lint** | Code style, syntax errors, unused variables, naming | ruff, clippy, eslint, etc. (auto-detected by language) |
| **security** | Hardcoded secrets, SQL injection, command injection, path traversal | linthis-secrets (built-in), Bandit, Gosec, OpenGrep |
| **complexity** | Functions with high cyclomatic complexity (exceeding thresholds) | linthis built-in analyzer |

Control which checks run with `--checks`: `linthis -i file --checks lint` (lint only), `--checks lint,security`, or `--checks all`.

## Key Commands

| Scope | Command | Description |
|-------|---------|-------------|
| Staged files | `linthis -s` | Check & format all files in the git staging area |
| Modified files | `linthis -m` | Check & format all locally modified files (staged + unstaged) |
| Specific files | `linthis -i <f1> -i <f2>` | Check & format listed files — one `-i` per file |
| Check only | append `-c` | Lint only, no formatting (e.g. `linthis -s -c`) |

## Build/Test Commands Reference

Auto-detect the project language and use the corresponding commands:

| Language | Build check | Test command |
|----------|------------|-------------|
| Rust | `cargo check` | `cargo test` |
| Go | `go build ./...` | `go test ./...` |
| TypeScript | `npx tsc --noEmit` | `npm test` |
| Python | `python -m py_compile <file>` | `pytest` |
| C/C++ | `make` / `cmake --build build` | `make test` / `ctest` |
| Java/Kotlin | `mvn compile` / `gradle build` | `mvn test` / `gradle test` |

> Detect by checking for `Cargo.toml`, `go.mod`, `package.json`, `pyproject.toml`, `Makefile`/`CMakeLists.txt`, `pom.xml`/`build.gradle` in the project root.

## Worktree Isolation

If your agent supports worktree (e.g. Claude Code), **prefer working in a worktree** for safe isolation. The hook script automatically creates a worktree and runs the agent in it. Changes are copied back only after verification passes. If interrupted (Ctrl+C), the main working tree is untouched.

## Steps

1. **Identify** modified code files in this session (files written or edited via Write/Edit tools, or via Bash)

2. **Snapshot before fixing**: save current state so we can generate a diff later
   ```bash
   git diff -- <modified files> > /tmp/lt-lint-before.diff
   ```

3. **Run lint + format** on those files:
   - `linthis -m` to cover all modified files at once, or
   - `linthis -i <file1> -i <file2>` to target specific files
   - **Note**: linthis may auto-format files (whitespace, trailing newlines, etc.) in addition to reporting issues

4. **Read the output** carefully — it shows a per-check breakdown:
   ```
   ✗ Linthis check failed [lint, security, complexity]
     lint:       2 error(s), 1 warning(s)
     security:   ✓
     complexity: 1 warning(s)
   ```

5. If issues are found, **group them by file** and assess dependencies:
   - **Independent files** (no cross-file dependencies): fix in parallel — use concurrent tool calls, one per file
   - **Dependent files** (shared type renames, API signature changes): fix sequentially in dependency order
   - Do **NOT** use `linthis --fix` or `linthis fix` — fixing manually ensures you understand the issue and don't introduce regressions

6. **Re-run linthis** to confirm all issues are resolved

7. **Build/test verification** — after all lint issues are fixed, run build and tests to ensure fixes don't break anything:
   ```bash
   # Example for Rust:
   cargo check && cargo test
   # Example for Go:
   go build ./... && go test ./...
   ```
   - If build or tests **fail**: revert the problematic change, re-analyze the error, and fix again. Repeat until both linthis and build/tests pass
   - If the project has no build step (e.g. pure Python scripts), skip the build but still run tests if available

8. **Generate diff report** — show what was changed:
   ```bash
   git diff -- <modified files>
   ```
   Display a **Changes Summary** listing each file, what was changed, and why:
   ```
   ## Changes Summary
   - src/foo.rs:42 — fixed unused variable `x` (lint: unused_variables)
   - src/bar.rs:15 — added doc comment for exported function (lint: missing_docs)
   - src/baz.rs:80 — reduced function complexity by extracting helper (complexity: threshold 20)

   ## Diff
   <full git diff output>
   ```

9. **Re-stage**: if any files were already staged before step 3, linting/formatting may have changed them on disk. Re-stage so the index matches:
   ```
   git add <formatted or fixed files>
   ```

10. **Final check**: run `linthis -s -c` (check-only on staged files) to verify the staging area is clean

11. Only approve the commit once **all lint checks pass** AND **build/tests pass**

## Key Rules

- **One `-i` per file**: `linthis -i src/foo.go -i src/bar.go` (not glob patterns)
- **Fix manually**: Read the error, understand the root cause, then edit. Automated fixes can mask deeper problems
- **Build must pass**: Never approve a commit if the build or tests are broken after fixing
- **Unsupported languages**: If a file can't be checked (not a recognized language), skip it silently
- **Always re-stage**: After any fix or format, `git add` the changed files before committing
- **Always show diff**: After all fixes, display the changes summary and diff so the user can review what was modified

## Example

```
$ linthis -i src/handler.go

src/handler.go:15:1: exported function HandleRequest should have comment (golint)
src/handler.go:23:4: error return value not checked (errcheck)

✗ Linthis check failed [lint, security, complexity]
  lint:       2 error(s)
  security:   ✓
  complexity: ✓
```

Fix line 15 by adding a doc comment, and line 23 by handling the error return value. Then re-run to confirm zero errors. If files were staged, re-stage: `git add src/handler.go`.
