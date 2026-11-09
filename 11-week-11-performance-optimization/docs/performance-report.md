# Performance Report — Week 11

## Summary

This Week 11 scaffold did not include an existing Week 7–10 app. A focused 120-row catalog was created to demonstrate and test performance techniques without claiming device metrics that were not captured. The app can switch between an intentionally eager baseline and an optimized lazy list.

## Baseline profile

| Metric | Baseline | Optimized | Evidence / status |
| --- | --- | --- | --- |
| List strategy | Eager `ListView(children: ...)` | `ListView.builder` | Source and widget tests |
| Items in dataset | 120 | 120 | Fixed identical workload |
| Initial row creation | All rows supplied to list | Viewport-driven | Test verifies final row is absent initially |
| Average frame time | Not measured | Not measured | Requires device/emulator profile run |
| Janky frames | Not measured | Not measured | Requires DevTools Performance recording |
| Heap / external memory | Not measured | Not measured | Requires DevTools Memory snapshots |

## Findings and changes

1. **Lazy loading:** switched the optimized mode to `ListView.builder` so rows are created as the user scrolls.
2. **Widget reuse:** extracted a small row widget and used constant constructors for static icons and decorations.
3. **Paint isolation:** added a `RepaintBoundary` around each optimized row. This is a targeted demonstration; profile whether the extra layers help the actual target UI.

Networking cache, image resizing, pagination, and Riverpod `select` were not added because this standalone workload contains no API, image, repository, or Riverpod state. Adding those without a corresponding bottleneck would obscure the comparison.

## Verification

`flutter test --reporter expanded` passes three widget tests: default optimized mode, switching to baseline, and lazy initial rendering. `flutter analyze` reports no issues. Captured output is in `../screenshots/flutter-test-passed.txt`.

For a device-backed follow-up, run `flutter run --profile` on the same device for both modes. Record the same repeated fast-scroll scenario in DevTools Performance; compare frame bars, UI/raster durations, and jank count. Take Memory snapshots after initial load, then after five scroll-away/back cycles. Save those real DevTools captures as `before-profile.png` and `after-profile.png` before recording numerical metrics here.

## Screenshot evidence

- Current optimized interface: `../screenshots/performance-lab.png`
- Test output: `../screenshots/flutter-test-passed.txt`
- Device DevTools before/after screenshots: not captured because no mobile device or emulator was connected.

## Reflection

Lazy row creation is the clearest optimization for this long list because its work follows the visible viewport instead of the full dataset. Widget tests verify the structural behavior but cannot prove frame-time improvements. The added `RepaintBoundary` can reduce paint propagation while increasing layer count and memory use, so its value should be measured in a profile build. Avoid optimizing beyond measured bottlenecks.
