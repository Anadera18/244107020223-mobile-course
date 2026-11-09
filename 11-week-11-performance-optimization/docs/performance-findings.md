# Performance Findings — Week 11

## Environment and scope

- Project: standalone Flutter `Performance Lab` in this Week 11 scaffold.
- Device: Flutter widget-test viewport, 430 × 900 logical pixels. No Android emulator or physical Android device was connected.
- Workload: render and scroll a fixed 120-row study list with six repeated data records.
- Modes: baseline eager `ListView(children: ...)` and optimized `ListView.builder`.
- Evidence: Flutter widget tests prove which list mode is active and that the last item is not initially built by the lazy list. UI screenshot is in `../screenshots/performance-lab.png`.

The codelab recommends profile-mode DevTools data for frame and heap measurements. No device profile was available in this run, so actual frame time, jank count, and heap delta are marked **not measured**. The workload structure and widget-build observation are reproducible, but they are not substitutes for a device profile.

## Findings

| # | Finding | Baseline evidence | Change / expected impact |
| --- | --- | --- | --- |
| 1 | Eager construction scales work with total item count. | Baseline uses `ListView` with a generated 120-widget child list. | `ListView.builder` creates visible rows on demand, reducing initial build/layout work for long lists. |
| 2 | Static row content is recreated in the baseline build path. | The baseline row subtree is constructed as part of the generated child list. | Extract a row widget and use constant constructors where values are static, making immutable subtrees reusable. |
| 3 | A row repaint can share a larger paint region. | Baseline has no row paint isolation. | Wrap optimized rows in `RepaintBoundary`; this can reduce unrelated repaint work but adds layers and must be profiled on the target device. |

## Known non-findings

- This demo has no image payloads, remote API, persistent repository, or navigation stack, so it cannot support valid claims about image decode cost, network cache hit rate, or navigation leaks.
- `const` and `RepaintBoundary` are implemented within the optimized row subtree. The measured, testable distinction in this small demo is lazy versus eager item creation.
