# /lt-lint

Run linthis quality checks (lint + security + complexity) on the files you specify or on all recently modified files.

## Usage

```
/lt-lint [file1] [file2] ...
```

If no files are given, linthis runs on all files modified in the current session.

## Steps

1. Collect the target files (from arguments or session history)
2. Run `linthis -i <file1> -i <file2>` (runs lint, security, and complexity checks + formatting)
3. Read the per-check breakdown output and fix any issues by editing the code directly
4. Re-run to confirm clean results
