# Prompt: Week 13 Jobsheet — CI/CD Automation (improved)

Reusable prompt to generate the Week 13 deliverable, mirroring the Week 12 workflow.

---

## Prompt

Do the Week 13 jobsheet, create/complete the folder with this output:

```
├── 13-week-13-ci-cd-automation/
│   ├── README.md
│   ├── .github/workflows/       # flutter-ci.yml (copy, week deliverable)
│   ├── android/                 # needed so apk/aab build in CI
│   ├── lib/
│   ├── test/
│   ├── integration_test/
│   ├── coverage/
│   └── screenshots/
```

Also place the workflow GitHub actually runs at the **repository root**:
`.github/workflows/flutter-ci.yml` (GitHub Actions only reads root-level
`.github/workflows/`), with `defaults.run.working-directory:
13-week-13-ci-cd-automation`.

Base it on Week 12 (`12-week-12-testing-quality-assurance`): copy its project
so CI has something real to format, analyze, test, and build. Use English in
`README.md`, include **real** screenshots (not dummy) that match the codelab
sections, and adapt to the codelab below.

Source (English):
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#0
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#1
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#2
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#3
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#4
- https://jti-polinema.github.io/flutter-codelab/13-minggu-13-ci-cd-automation/index-en.html#5

Use only Week 13 screenshots; do not include Week 11 or Week 12 screenshots.

## Codelab content to cover

**#0 Welcome (November 13, 2026)**

Repeated manual checks are easy to miss and hard to reproduce. Set up a CI/CD
pipeline that consistently runs Flutter checks, tests, and builds with GitHub
Actions.

Learning objectives:
- explain the CI/CD flow from a commit to an application artifact;
- create a workflow for formatting, analysis, tests, and Android builds;
- store APK/AAB files as reviewable artifacts;
- use versioning and understand the limits of secret storage.

What you need: a Flutter project with at least one passing test; Git and a
GitHub account with the project pushed; Flutter SDK, Dart, basic YAML/Git.

Security: never put passwords, private tokens, or keystores in source code. A
value passed with `--dart-define` and compiled into an app is not a secret.

**#1 CI and CD**

Continuous integration (CI) runs automated checks when changes are proposed or
pushed. Continuous delivery/deployment (CD) automates release preparation or
delivery. The flow: commit/PR triggers the workflow → runner checks out source
and sets up Flutter → formatting, analysis, tests run → if checks pass, build
and store artifacts.

**#2 Events and permissions**

- `pull_request` checks changes before merging; `push` checks the main branch.
- Grant minimum permissions; a read-only CI job usually needs only
  `contents: read`.
- Pull requests from forks do not receive repository GitHub Secrets.

**#3 The workflow file (`.github/workflows/flutter-ci.yml`)**

Add the workflow with triggers, `permissions: contents: read`, a `concurrency`
group with `cancel-in-progress: true`, and a `test-and-build` job on
`ubuntu-latest` that runs:
`actions/checkout@v4` → `subosito/flutter-action@v2` (stable) →
`flutter pub get` → `dart format --output=none --set-exit-if-changed .` →
`flutter analyze --fatal-infos` → `flutter test --coverage`.

Check locally first: run the same commands on the project. If not formatted,
run `dart format .` and review before committing. Do not remove checks just to
make the workflow green.

**#4 Build steps and artifacts**

After tests pass, add: `flutter build apk --release`,
`flutter build appbundle --release`, and `actions/upload-artifact@v4` with
`name: android-builds`, both output paths, `if-no-files-found: error`, and
`retention-days: 7`. APKs are convenient for install/internal testing; AAB is
the Google Play distribution format. Download artifacts from the Actions tab.
A successful build is not publish-ready: signing, app configuration,
permissions, and target-device testing still need review. This workflow does
not upload to the Play Store.

Versioning: `1.2.0+15` means app version `1.2.0`, build number `15`. Follow
semantic versioning and increment the build number for each upload; tag
(`v1.2.0`) the commit that passed. Secrets: store tokens/passwords/signing
material in GitHub Actions Secrets, never print them, treat API URLs and env
names as public config, remember `--dart-define` values are extractable, and
keep the production keystore out of pull-request workflows.

**#5 Run the workflow, assignment, reflection**

Commit and push; open the Actions tab; review each step; confirm a test failure
fails the job; download the artifact and record the commit.

Assignment:
1. add a CI workflow with formatting, analysis, and tests;
2. build APK and AAB and store both as artifacts;
3. run on a PR or push to main, with evidence of the result and commit;
4. document the next version, checks performed, and remaining security risks.

Reflection: what was detected automatically before merge; what helps
investigate a failed build; what still needs approval/manual review before
release.

## Evidence requirements (real, not dummy)

- Run `flutter pub get`, `dart format --set-exit-if-changed .`,
  `flutter analyze --fatal-infos`, `flutter test --coverage`,
  `flutter test integration_test/app_test.dart -d windows` locally and capture
  the real terminal output (`screenshots/*.txt` and PNG terminals).
- Push the workflow and capture the **real** GitHub Actions run: green run
  summary, per-step durations, the `android-builds` artifact with the real APK
  and AAB sizes and digest (save `screenshots/github-actions-run.png` and
  `github-actions-run.txt`).
- If a step fails in CI (e.g. an SDK drift on the moving `stable` channel),
  fix it, re-run until green, and document the cause and fix in the README.

## Notes learned from doing this week

- GitHub Actions only reads workflows from `.github/workflows/` at the repo
  root; a workflow nested inside a week folder never runs. Keep the runnable
  copy at the root (with `working-directory`) and a copy in the week folder.
- Pin `flutter-version` in `subosito/flutter-action` so CI matches the dev SDK
  and `--fatal-infos` does not fail on newer-SDK deprecations.
- The project needs an `android/` platform folder, or
  `flutter build apk` fails with a missing `android/app/build.gradle`.
- Watch out: `flutter create --platforms=android .` also adds a default
  `test/widget_test.dart` and edits `analysis_options.yaml`; remove the stub
  test if the project already has its own tests.
