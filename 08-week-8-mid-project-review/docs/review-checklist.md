# Week 8 Review Checklist

## Repository audit

Before starting, ran git log --oneline -15, git branch -a, and git status in the portfolio repo.

- Clean main at e52ed82 (Jobsheet 7), tracking origin/main.
- Only main and origin/main existed; no develop branch.
- Week 8 folder initially held an empty README. Week 7 screenshot folders were empty.
- Created develop from main, then feat/week8-mid-review from develop.

## Finding and fix

The add-note dialog created two TextEditingControllers without disposing them on Save or Cancel. Its async continuation also used the page provider/messenger without checking whether the page remained mounted.

In 07-week-7-clean-architecture/lib/features/notes/presentation/pages/notes_page.dart:

1. Dispose both controllers in finally.
2. Copy field values before disposal.
3. Return if context.mounted is false or the dialog was cancelled.
4. Keep blank-title validation in the AddNote domain use case.

The new notes_page_test.dart covers Cancel and blank-title behavior. The screenshot is a browser capture of NotesPage with a temporary empty-list provider; it does not exercise SQLite.

## Machine checks

Executed from 07-week-7-clean-architecture:

| Command | Result |
| --- | --- |
| flutter pub get | Passed |
| dart format --set-exit-if-changed . | Three app files formatted; final run reported 0 changed |
| flutter analyze | Passed, no issues |
| flutter test | Passed, 12 tests including architecture tests |


## Review readiness

- [x] Focused lifecycle fix and widget tests.
- [x] README, run guide, screenshot, AI decision evidence, and PR body prepared.
- [x] Issue #1 created with reproduction steps.
- [x] PR #2 opened against pushed develop with the screenshot in the body.
- [x] Asked tiara082 for review in a PR comment; formal request blocked because they are not a repository collaborator.
- [ ] Reviewer comments addressed and approved.
- [ ] PR merged into develop; feature branch deleted afterward.

**Status: ready for peer review; not complete until real review and merge.**

## Reflection

Responsible approval checks correctness, error/lifecycle paths, and test evidence. Blind LGTM risks shipping an unverified bug. Request changes for correctness, architecture, or required-test gaps; use a suggestion for optional readability changes.

Rejected the AI suggestion to move blank-title validation into the dialog. AddNote owns the rule and its unit test proves the repository is not called for a blank title; presentation-only validation would leave other callers unprotected.

