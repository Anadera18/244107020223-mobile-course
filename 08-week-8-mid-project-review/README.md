# Week 8 — Mid Project Review & Code Review

| Information | Detail |
| --- | --- |
| Subject | Mobile Development |
| Name | Andhika Daffa Athaaillah |
| Absen | 02 |
| NIM | 244107020223 |
| Base project | Week 7 Clean Architecture notes app |
| Working branch | feat/week8-mid-review |
| PR | [#2, target: develop](https://github.com/Anadera18/244107020223-mobile-course/pull/2) |

This continues the Week 7 Offline Notes project. The focused review fix disposes the add-note dialog controllers and checks that the page remains mounted after the dialog closes. Blank-title validation remains in the domain use case.

## Features and stack

- Offline notes in SQLite and Dio announcements follow feature-first Clean Architecture.
- Announcements fetched through Dio.
- Riverpod dependency injection, GoRouter, domain failures, and fake-repository tests.
- Flutter, Dart, flutter_riverpod, sqflite, path, dio, and go_router.

## Run

The app remains in the Week 7 project. Run from that folder:

    cd ..\07-week-7-clean-architecture; flutter pub get; flutter run
    flutter analyze; dart format --set-exit-if-changed .; flutter test

## Machine evidence

| Check | Result |
| --- | --- |
| flutter analyze | Passed: no issues found |
| dart format --set-exit-if-changed . | Formatted 3 Week 7 app files; final verification reported 0 changed |
| flutter test | Passed: 12 tests including widget and architecture tests |

## Issue and PR map

See docs/issue-pr-map.md and [Issue #1](https://github.com/Anadera18/244107020223-mobile-course/issues/1). PR #2 is open for review; it is not merged.

## Review documents

- docs/review-checklist.md: audit, branch plan, evidence, readiness, and reflection.
- docs/ai-review-vs-decision.md: prompt, findings, evidence, accepted and rejected suggestions.
- screenshots/notes-empty-state.jpg: screenshot of the actual NotesPage using a screenshot-only provider override; SQLite is not exercised by this capture.

## Status

Local code review and machine checks are complete. PR #2 is open against develop. GitHub would not accept a formal reviewer request because tiara082 is not a repository collaborator; a review request was posted as a PR comment instead. Merge remains pending.
