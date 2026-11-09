# AI Development Log — Week 9

## Feature and context

Feature: search the sample notes by title, case-insensitively, with clear empty states.

Project context: a small Flutter app using Material 3. `Note` and the pure `filterNotes` function live in `lib/features/notes/domain/`; `NotesPage` in `presentation/` owns the query and renders results. There is no database or network dependency in this starter folder, so this implementation uses an in-memory sample list and keeps data access out of the widget.

No secrets, tokens, or credentials were used.

## Five-slot prompt

```text
Role: Senior Flutter developer and reviewer.
Context: Flutter app; keep note data and title filtering in a pure domain layer; UI belongs in presentation. The starter folder has no repository, database, or network setup.
Task: Add one small feature: case-insensitive notes title search and useful empty states.
Limits: Do not add packages beyond Flutter test/lints. Keep widgets free of persistence code. Keep filter logic pure and independently testable. Do not search note bodies.
Output: Working Flutter code, unit and widget tests for match/no-match/empty inputs, analysis and test commands, plus a concise explanation of decisions.
```

## Initial AI proposal / output summary

The first implementation proposal used `title.toLowerCase().contains(query.toLowerCase())`, with a `TextField` to update the query and a list filtered in the UI. It proposed a generic empty message and a case-insensitive unit test. This summary records the initial proposal; the shipped implementation below was reviewed and adjusted rather than accepted blindly.

## Verification and decisions

| File / proposal | Decision | Reason and evidence |
| --- | --- | --- |
| `domain/filter_notes.dart`: normalize query/title and filter titles | Accept + refactor | Kept framework-free, trimmed whitespace, returned an unmodifiable result, and added tests for case-insensitive match, no match, and blank query. |
| Search note body as well as title | Reject | The assignment asks for title search. Keeping search limited to titles makes behavior predictable and matches the prompt. |
| Put filtering directly in the widget | Reject + implement manually | That couples business rules to Flutter UI and makes direct unit tests harder. `grep -R "package:flutter" lib/features/notes/domain` returns no matches; the pure domain test exercises the filter without widgets. |
| One generic empty message | Accept + refactor | The UI distinguishes no stored notes from a query with no matches. Widget tests assert both states. |
| Case-sensitive title comparison (hallucination/bug pattern) | Reject; fixed before final | A red test using mixed-case `gRoC` caught the bug: lowercasing the query without lowercasing each title would miss `Grocery list`. The corrected implementation lowercases both values, and the test now passes. The initial fixture also used the invalid expected substring `groceries` for `Grocery`; fixing it to `gRoC` aligned the test with substring semantics. |
| Riverpod/repository/database setup from generic codelab context | Reject | The supplied Week 9 directory contained only empty `lib`, `docs`, and `screenshots` folders, with no Week 5–8 app, `pubspec`, repository contract, or persistence package. A local in-memory demo is the smallest honest, runnable scope for this folder. |

## Test and analysis evidence

Commands run from this directory:

```text
flutter pub get                 completed
dart format .                   completed
flutter test --reporter expanded  All tests passed (6 tests)
flutter analyze                 No issues found
```

The test screenshot is [`../screenshots/flutter-test-passed.png`](../screenshots/flutter-test-passed.png). The image captures the successful final test run.

## Explain the implementation

`filterNotes` trims and lowercases the query. Blank input returns all notes. Otherwise it checks whether each lowercased title contains the query, so capitalization does not affect matching. The function imports only the `Note` model and does not depend on Flutter, SQLite, or Dio. `NotesPage` stores only the current query and renders the list or an empty-state message. Tests cover pure filtering and visible UI states.

## Reflection

- **Hallucination/bug found:** a case-sensitive comparison can look correct with lowercase sample data but fail for user capitalization. The mixed-case unit test proved the miss before the fix.
- **Most useful prompt change:** explicitly stating “title only,” “pure domain function,” and the absence of a repository stopped the implementation from adding unrelated persistence architecture.
- **Refactor made:** filtering moved out of the widget into a pure domain function; the UI gained separate no-notes and no-match states.
- **Hardest decision:** rejecting a database/repository layer from the generic codelab example because this assignment folder has no existing data source to integrate with.
