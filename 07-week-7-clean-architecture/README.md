# Week 7: Clean Architecture (Campus Notes)

Refactor of the Week 5 offline notes app into a **feature-first Clean Architecture** layout (presentation / domain / data). Behavior is meant to stay the same; only the structure and dependency direction change. A second feature (`announcements`) is added in the same pattern for the Refactoring Challenge.

## Objective
Separate business logic from framework code so that the domain can be unit-tested with a fake repository, with no SQLite, Dio, or Firebase.

## Layer diagram and dependency direction
```
presentation (pages, widgets, providers)
      |  depends on
      v
domain (entities, repository interfaces, use cases, failures)   <- pure Dart
      ^
      |  implemented by
data (models, repository impls, SQLite / Dio datasources)
```
Dependencies only point inward. `domain` and `core` import no Flutter, Dio, sqflite, or Firebase.

## Project structure
```
lib/
  core/            failures.dart, format.dart (pure Dart)
  shared/widgets/  error_view.dart
  features/
    notes/         domain/{entities,repositories,usecases}  data/{datasources,models,repositories}  presentation/{providers,pages,widgets}
    announcements/ same shape
  routes.dart  main.dart
test/              use case tests with fakes + architecture_test.dart
docs/              ai-challenge.md, verification.md
screenshots/       before/ and after/ (add your own)
```

## Lab 1: file-to-layer mapping (Week 5 project)
| Old file (Week 5) | Old layer | Problem | New location |
| --- | --- | --- | --- |
| EDIT: your old `pages/notes_page.dart` | presentation | EDIT: e.g. opened the DB / formatted dates in the widget | `features/notes/presentation/pages/notes_page.dart` + `widgets/notes_list.dart` |
| EDIT: your old DB helper | data | EDIT: used directly by notifier | `features/notes/data/datasources/notes_database.dart` |
| EDIT: your old note class with `toMap/fromMap` | mixed | entity and mapping in one class | `domain/entities/note.dart` + `data/models/note_model.dart` |
| EDIT: your old repository class | data (+mixed contract) | interface and impl in one class | `domain/repositories/note_repository.dart` + `data/repositories/note_repository_impl.dart` |
| EDIT: your old providers | presentation | built repository manually | `presentation/providers/notes_providers.dart` |

Fill the EDIT cells from your real Week 5 code before submitting.

## Lab 2 and 3: what was done
- Pure `Note` entity; `NoteModel` holds `toMap/fromMap/toEntity`.
- `NoteRepository` interface in domain, `NoteRepositoryImpl` in data, returning Dart records `(value, Failure?)`.
- Use cases: `GetNotes` (forwarding only) and `AddNote` (owns the title validation rule).
- DI wired only in `notes_providers.dart` with Riverpod; widgets never construct repositories.

## Refactoring Challenge
1. Second feature `announcements`: entity, repository interface, impl (Dio), `GetAnnouncements`, provider wiring. Uses jsonplaceholder as a stand-in API; replace the base URL with your Campus Notify backend.
2. `lib/core/format.dart`: `formatDate` and `parseRouteId` as pure functions with tests.
3. Exceptions become `Failure` objects in the data layer; the UI only receives a message.

## Dependency rule proof (grep results)
```
# 1. presentation free of raw data APIs        -> 0 hits
# 2. domain and core free of frameworks        -> 0 hits
# 3. business logic in build() (date/json)     -> 0 hits
```
Commands are in `docs/verification.md`. The same checks run automatically in `test/architecture_test.dart`.

## Tech stack
Flutter, flutter_riverpod, go_router, sqflite, dio, flutter_test.

## How to run
```
flutter create . --project-name campus_notes_clean   # generates android/ios folders, keeps lib/
flutter pub get
flutter analyze
flutter test
flutter run
```

## Result
EDIT after you run it: confirm the app behaves like before, `flutter analyze` is clean, and all tests pass. Add before/after screenshots to `screenshots/`.

## Reflection
EDIT: answer the four reflection questions from the codelab in your own words (why the interface lives in domain, when a use case is needed, cost of over-engineering, what you rejected from the AI proposal).
