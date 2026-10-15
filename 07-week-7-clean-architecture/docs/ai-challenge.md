# AI Challenge

## Prompt used
```
My Flutter project: campus_notify (auth + FCM + announcement list).
Current state: lib/{data, providers, pages, messaging} folders,
repositories mixed with implementations, widgets calling Dio directly.
Tasks:
1. Propose a feature-first Clean Architecture structure (presentation/domain/data) for the auth + announcements features.
2. For each old file, state its new destination (move/split/delete).
3. Flag what would be over-engineering if applied to simple CRUD, and when a use case is truly needed vs repository straight to notifier.
4. Show the Riverpod DI wiring (no extra DI package).
Explain the trade-off of every decision.
```

## Proposal vs final decision (draft, review and change it)
| Topic | AI proposal | Final decision | Reason |
| --- | --- | --- | --- |
| Structure | feature-first, 3 layers per feature | Same | Two features; each can be understood alone |
| Use case for list/fetch | One per operation | Kept `GetNotes` and `GetAnnouncements` as thin forwarders | EDIT: argue this yourself; it is borderline over-engineering |
| Use case for add | `AddNote` | Kept | Owns a real rule (non-empty title) |
| Error handling | Records `(value, Failure?)` | Same | No exceptions leak to the UI |
| DI package | none | Riverpod providers only | Matches the codelab |

## Verification checklist
- [x] Repository interface in `domain`, implementation in `data`
- [x] `domain` has no Flutter/Dio/SQLite/Firebase imports (grep + `architecture_test.dart`)
- [ ] EDIT: record which AI suggestions you rejected as over-engineering
- [x] Mapping only in models
- [x] DI only in providers
