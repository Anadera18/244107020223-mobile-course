# AI Review: Proposal vs Final Decision

## Prompt used

Review this Flutter PR as a senior Flutter dev. Context: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio. Focus: correctness, architecture, tests. Ignore style. Give the top findings + severity + rationale + proposed code fix.

## Raw AI review output

1. Suggestion: dispose dialog controllers. NotesPage creates title/body controllers but does not dispose them on Save or Cancel. Put the dialog lifecycle in try/finally, copy text before disposal, then dispose both.
2. Suggestion: guard the async gap. After showDialog completes the page may have been removed. Check context.mounted before using WidgetRef or showing a snackbar.
3. Suggestion: test dialog lifecycle. Existing tests cover domain and architecture but not cancel/blank-title UI behavior. Add widget coverage.
4. Suggestion: retain domain ownership of title validation. Do not remove the AddNote rule in favor of TextField validation alone.
5. Suggestion: keep PR scope narrow. Do not combine the lifecycle fix with broad refactors or unrelated package upgrades.

## Verification and decisions

| Finding/proposal | Evidence | Decision | Rationale |
| --- | --- | --- | --- |
| Controllers were not disposed | Inspected NotesPage: both controllers were created and no dispose call existed on Save or Cancel paths. | Accept and fix | A finally block disposes both regardless of dialog result. |
| Async continuation may outlive page | showDialog is awaited, then provider and messenger are used without a mounted check. | Accept and fix | context.mounted is checked before either is used. |
| Widget test gap | Existing suite had unit/architecture tests but no cancel or blank-title widget test. | Accept | Added focused tests; full suite passes. |
| Move title validation to TextField and remove use-case guard | AddNote trims/rejects an empty title; add_note_test proves rejection and repository is not called. | Reject | UI-only validation leaves alternate callers unprotected and weakens domain ownership. |
| Expand PR into broad refactor | The focused change and tests fit a small review. | Reject | Wider scope increases review risk without helping this lifecycle issue. |

## Evidence

- flutter analyze: passed, no issues found.
- flutter test: passed, 12 tests including dialog widget tests and architecture tests.
- dart format --set-exit-if-changed . initially formatted three copied Week 7 files; the final verification reported 0 changed.

Suggestions were checked against source and tests before applying or rejecting them.
