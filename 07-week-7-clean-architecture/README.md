# Flutter Week 7 - Clean Architecture

| **Information** | **Detail** |
| --- | --- |
| Subject | Mobile Development |
| Name | Andhika Daffa Athaaillah |
| Absen | 02 |
| NIM | 244107020223 |

Offline Notes app refactored into feature-first Clean Architecture: presentation, domain, and data layers
with the dependency rule (dependencies only point inward), repository interfaces, use cases, failures, and
Riverpod dependency injection. The domain is tested with fake repositories, with no database or network.

## Features

- Notes CRUD split into domain, data, and presentation (SQLite via sqflite)
- Announcements list from an API (Dio) built with the same pattern as a second feature
- Pure entities, models with mapping only in the data layer, and `Failure` objects instead of raw exceptions
- Use cases with real business rules (`AddNote` validates the title)
- Dependency injection with Riverpod providers only
- Loading, error (+ Retry), empty, and success states everywhere

## Tech Stack

Flutter, flutter_riverpod, sqflite, path, dio, go_router

## How to Run

```bash
flutter create --project-name campus_notes_clean .
flutter pub get
flutter run
flutter analyze
flutter test
```

## Project Structure

```
lib/
├── main.dart
├── routes.dart
├── core/ (failures.dart, format.dart)
├── shared/widgets/error_view.dart
└── features/
    ├── notes/
    │   ├── domain/ (entities/note.dart, repositories/note_repository.dart,
    │   │            usecases/get_notes.dart, usecases/add_note.dart)
    │   ├── data/ (datasources/notes_database.dart, models/note_model.dart,
    │   │          repositories/note_repository_impl.dart)
    │   └── presentation/ (providers/notes_providers.dart, pages/notes_page.dart,
    │                      widgets/notes_list.dart)
    └── announcements/ (same three layers)
test/ (fakes.dart, get_notes_test.dart, add_note_test.dart, get_announcements_test.dart,
       format_test.dart, architecture_test.dart)
docs/ (ai-challenge.md, verification.md)
screenshots/
```

---

## 1. Lab 1: Map Files to Layers and Find Violations

Files: Week 5 project (`week5_offline_notes`), `docs/verification.md`

The Week 5 pages already only read providers, so most problems were in `data/`. Each row below became one refactor item.

| Week 5 file | Layer before | Problem | Week 7 destination |
| --- | --- | --- | --- |
| `pages/notes_page.dart`, `note_detail.dart` | presentation | OK, only reads providers | `features/notes/presentation/pages/` |
| `widgets/note_tile.dart`, `note_dialog.dart` | presentation | OK | `features/notes/presentation/widgets/` |
| `data/local/note.dart` | data (mixed) | Entity and `toMap/fromMap` in one class | `domain/entities/note.dart` + `data/models/note_model.dart` |
| `data/local/db.dart` | data | Only reachable through a concrete class | `notes/data/datasources/notes_database.dart` |
| `data/repositories/note_repository.dart` | data (mixed contract) | Interface and implementation in one class | `domain/repositories/note_repository.dart` + `data/repositories/note_repository_impl.dart` |
| `data/providers.dart` | data | All providers in one file inside `data/` | one providers file per feature in `presentation/providers/` |
| `data/sync.dart` | data | `resolveConflict` is a business rule next to caching code | candidate for a domain use case (see Reflection) |
| `data/repositories/post_repository.dart`, `models/post.dart` | data | Same mixed contract problem | `features/announcements/` |
| `data/network_errors.dart` | data | Error text built far from the failure source | mapped to `NetworkFailure` inside the data layer |

### Violation Searches (after the refactor)

| Check | Result |
| --- | --- |
| Presentation uses raw data APIs (`Dio(`, `openDatabase`, `getDatabasesPath`, `FlutterSecureStorage`, `SharedPreferences.getInstance`, `jsonDecode`) | 0 hits |
| Domain and core import frameworks (`flutter`, `dio`, `sqflite`, `firebase`) | 0 hits |
| Business logic in `build()` (`DateFormat`, `jsonDecode`, `toIso8601String`) | 0 hits |

Commands are in [`docs/verification.md`](docs/verification.md).

### Result Output

![Before structure](screenshots/before/structure.png)
![After structure](screenshots/after/structure.png)

---

## 2. Lab 2: Domain and Data Layers

Files: `lib/features/notes/domain/**`, `lib/features/notes/data/**`, `lib/core/failures.dart`

1. **Pure entity:** `Note` has no Flutter import and no mapping code.
2. **Failures:** a sealed `Failure` with `LocalFailure`, `NetworkFailure`, and `ValidationFailure`.
3. **Repository contract:** `NoteRepository` lives in domain and returns Dart records
   `({value, Failure? failure})`, so errors are explicit and no exception reaches the UI.
4. **Model and implementation:** `NoteModel` owns `toMap`, `fromMap`, and `toEntity`.
   `NoteRepositoryImpl` takes an `openDb` function (injectable for tests) and converts every exception
   into a `LocalFailure`.
5. **Use cases:** `GetNotes` forwards to the repository. `AddNote` trims the input and returns a
   `ValidationFailure` for an empty title without touching the repository.

### Result Output

![Lab 2 Notes list](screenshots/lab2-list.png)
![Lab 2 Empty title error](screenshots/lab2-validation.png)

---

## 3. Lab 3: Dependency Injection and Presentation

Files: `lib/features/notes/presentation/**`, `lib/features/announcements/**`, `lib/routes.dart`

`notes_providers.dart` is the single wiring point: `noteRepositoryProvider` (data), `getNotesProvider` and
`addNoteProvider` (domain use cases receive the abstraction), and `notesProvider` (UI state as an
`AsyncValue`). Pages only call `ref.watch` and render loading, error with Retry, empty, and data states.
The announcements feature repeats the pattern with Dio. `AnnouncementRepositoryImpl.create()` builds Dio
inside the data layer so providers and widgets never call `Dio(` themselves.

### Dependency Rule Evidence

| Rule | How it is checked |
| --- | --- |
| Presentation does not touch raw data APIs | grep (0 hits) + `architecture_test.dart` |
| Domain and core import no framework or data package | grep (0 hits) + `architecture_test.dart` |
| Widgets never create repositories | providers are the only place that call the `Impl` constructors |

### Result Output

![Lab 3 Notes](screenshots/lab3-notes.png)
![Lab 3 Announcements](screenshots/lab3-announcements.png)
![Lab 3 Error and Retry](screenshots/lab3-error.png)

---

## 4. AI Challenge

Full prompt, initial AI output, comparison table, and final decision are in [`docs/ai-challenge.md`](docs/ai-challenge.md).

### Final Decision

| Need | Choice | Reason |
| --- | --- | --- |
| Folder structure | feature-first | Several features, each can be understood or removed alone |
| Business rule operation | use case (`AddNote`) | Owns validation, not just forwarding |
| Plain reads | thin use cases (`GetNotes`, `GetAnnouncements`) | Kept for a consistent call style; accepted as a small cost |
| Error handling | records with `Failure` | No exceptions reach the UI |
| DI | Riverpod providers only | No extra package needed |

### AI Verification Findings

- **Interface in domain, implementation in data?** Yes. I would reject any proposal that puts both in one folder.
- **Domain free of Flutter, Dio, SQLite, and Firebase imports?** Yes, checked with grep and a test, not by skimming.
- **Use case for every one-line CRUD?** Rejected as over-engineering. A use case only makes sense when a rule exists.
- **Entity mapping-free?** Yes. `toMap`, `fromMap`, and `toEntity` are only in models.
- **DI centralized?** Yes, in the providers files.

---

## 5. Refactoring & Testing

### Refactoring Challenge

- **Second feature (`lib/features/announcements`):** entity, repository interface, Dio implementation,
  `GetAnnouncements`, and provider wiring, so no feature is left dirty.
- **Pure functions (`lib/core/format.dart`):** `formatDate` and `parseRouteId` can be tested without widgets.
- **Failures:** Dio errors become a `NetworkFailure` with a friendly message (timeout, no connection, generic)
  in the data layer. The UI only ever receives a message.

### Unit Tests with Fake Repository (`test/`)

1. **GetNotes success:** forwards the list from `FakeNoteRepository`.
2. **GetNotes failure:** forwards a `LocalFailure` without throwing.
3. **AddNote validation:** a blank title returns `ValidationFailure` and the repository is never called.
4. **AddNote trimming:** title and body are trimmed before saving.
5. **GetAnnouncements:** success and `NetworkFailure` through a fake repository.
6. **Pure functions:** `formatDate` and `parseRouteId`.
7. **Architecture test:** domain, core, and presentation stay free of forbidden imports.

### Verification Evidence (Test & Analyze)

![flutter analyze & test](screenshots/flutteranalyzetest.png)

---

## 6. Self-Verification Checklist

- [v] **Sterility greps:** presentation, domain, and core return zero hits.
- [v] **Layers:** interfaces in domain, implementations in data, mapping only in models.
- [v] **No direct instantiation:** widgets never create repositories; everything goes through providers.
- [ ] **Same behavior before and after:** compare the screenshots in `screenshots/`.
- [ ] **Clean analysis & tests:** run `flutter analyze` and `flutter test`, then attach the screenshot.

## 7. Reflection

- **Why must the repository interface live in domain, not in data? What breaks if reversed?**
  The domain decides what it needs, and the data layer fulfils that contract. If the interface lived in
  data, the domain would have to import data code to use it, so business logic would depend on SQLite or
  Dio. That breaks the dependency rule and makes the use cases impossible to test without a real database.

- **When is a use case truly needed, and when is repository straight to notifier enough?**
  A use case is needed when an operation owns a business rule or combines more than one repository, like
  `AddNote` validating the title. For a plain read that only forwards the repository result, going straight
  from repository to notifier is enough. I kept `GetNotes` thin only for a consistent call style.

- **What does over-engineering cost a small team? When is the cost worth it?**
  It adds files and indirection for little benefit, so onboarding is slower and one small change touches
  more places. The cost is worth it when logic is growing, several people work in parallel, or tests need
  to isolate the domain from the database and network.

- **Which part of the AI proposal did you reject or simplify, and why?**
  I rejected the idea of one use case for every operation. Only `AddNote` has a real rule, so the other
  use cases stay minimal. I also moved the Dio creation into a factory in the data layer so that no
  provider or widget calls `Dio(` directly, which the first grep would have flagged.
