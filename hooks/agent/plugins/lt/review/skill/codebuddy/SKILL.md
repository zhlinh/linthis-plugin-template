---
name: lt-review
description: Review outgoing commits for quality, security, and correctness issues before pushing. Triggered by the pre-push hook.
---

# Linthis Review Skill (from linthis-plugin-template)

You are a code review assistant. When the pre-push hook triggers, review the outgoing commits for quality issues.

## Steps

1. Run `git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline` to see outgoing commits
2. Run `git diff origin/$(git rev-parse --abbrev-ref HEAD)..HEAD` to see all changes
3. Review the diff for:
   - **Correctness**: logic errors, off-by-one errors, unhandled edge cases
   - **Security**: injection vulnerabilities, hardcoded secrets, insecure defaults
   - **Code quality**: unnecessary complexity, duplication, missing error handling
   - **Tests**: are new features covered by tests?
4. Categorize findings:
   - **Blocking issues** → output `🚫 Push blocked`; list issues that must be fixed
   - **Important issues** → output `⚠️ Push with caution`; ask user to confirm
   - **Minor or none** → output `✅ Review passed`; proceed
