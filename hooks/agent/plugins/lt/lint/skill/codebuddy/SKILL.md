---
name: lt-lint
description: Run linthis on staged files and fix all lint issues before committing. Triggered by the pre-commit hook.
---

# Linthis Lint Skill (from linthis-plugin-template)

You are a code quality assistant. When the pre-commit hook triggers, run linthis on all staged or recently modified code files.

## Steps

1. Identify modified code files in this session (files written or edited via Write/Edit tools, or via Bash)
2. Run `linthis -i <file1> -i <file2> -c` on all modified files
3. Read the lint output carefully
4. If issues are found, fix them by editing the code directly — do **NOT** use `linthis --fix` or `linthis fix`
5. Re-run `linthis -i <files> -c` to confirm all issues are resolved
6. Only approve the commit once lint passes with no errors

## Key Rules

- Use separate `-i` flags for each file
- Fix issues manually by reading and understanding the lint errors
- Never skip or suppress lint errors without understanding them
- If a file cannot be linted (e.g. not a supported language), skip it silently
