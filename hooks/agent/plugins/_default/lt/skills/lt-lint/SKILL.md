---
name: lt-lint
description: >
  对暂存/修改的代码文件运行 linthis 代码检查，提交前修复所有问题。
  使用 `linthis -i <file>` 按项目编码规范检查并格式化文件。
  必须手动编辑修复问题（不能用 linthis --fix）。
  所有 lint 错误修复后才允许提交。
  由 linthis 的 pre-commit git hook 触发。
  Run linthis lint checks on staged/modified code files and fix all issues before committing.
  Uses `linthis -i <file>` against project coding standards.
  Issues must be fixed by editing code directly.
  If the lt-cmsg skill also exists, both should be invoked together when committing.
---

# Linthis Lint Skill

## Companion Skills

When the user asks to commit, if the **lt-cmsg** skill is also available, both lt-lint and lt-cmsg should be invoked together. Run lt-lint first (to fix code issues), then lt-cmsg (to validate the commit message).

## Goal

Catch and fix code quality issues before they enter the repository. Running lint at pre-commit ensures every committed file meets project coding standards, preventing style debt from accumulating over time.

## When to Skip

If no code files were modified in this session, approve immediately.

## Key Commands

| Scope | Command | Description |
|-------|---------|-------------|
| Staged files | `linthis -s` | Check & format all files in the git staging area (`git add`ed) |
| Modified files | `linthis -m` | Check & format all locally modified files (staged + unstaged) |
| Specific files | `linthis -i <f1> -i <f2>` | Check & format listed files — one `-i` per file |
| Check only | append `-c` | Lint only, no formatting (e.g. `linthis -s -c`) |

## Steps

1. Identify modified code files in this session (files written or edited via Write/Edit tools, or via Bash)
2. Run lint + format on those files:
   - `linthis -m` to cover all modified files at once, or
   - `linthis -i <file1> -i <file2>` to target specific files
   - **Note**: linthis may auto-format files (whitespace, trailing newlines, etc.) in addition to reporting lint errors
3. Read the lint output carefully — each issue includes file path, line number, and rule name
4. If issues are found, fix them by editing the code directly
   - Do **NOT** use `linthis --fix` or `linthis fix` — fixing manually ensures you understand the issue and don't introduce regressions from blind automated transforms
5. Re-run linthis to confirm all issues are resolved
6. **Re-stage**: if any files were already staged before step 2, linting/formatting may have changed them on disk. You must re-stage those files so the index matches the working tree:
   ```
   git add <formatted or fixed files>
   ```
7. Final check: run `linthis -s -c` (check-only on staged files) to verify the staging area is clean
8. Only approve the commit once lint passes with zero errors

## Key Rules

- **One `-i` per file**: `linthis -i src/foo.go -i src/bar.go` (not glob patterns)
- **Fix manually**: Read the error, understand the root cause, then edit. Automated fixes can mask deeper problems or introduce new issues
- **Unsupported languages**: If a file can't be linted (not a recognized language), skip it silently
- **Always re-stage**: After any fix or format, `git add` the changed files before committing

## Example

```
$ linthis -i src/handler.go

src/handler.go:15:1: exported function HandleRequest should have comment (golint)
src/handler.go:23:4: error return value not checked (errcheck)

2 issues found
```

Fix line 15 by adding a doc comment, and line 23 by handling the error return value. Then re-run to confirm zero errors. If files were staged, re-stage: `git add src/handler.go`.
