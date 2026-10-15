# Dependency rule verification

```
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation lib/shared
rg "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core
rg "DateFormat|jsonDecode|toIso8601String" lib/features/*/presentation lib/shared
flutter analyze
flutter test
```

Results (run with grep -rnE on the final tree):

| Check | Result |
| --- | --- |
| 1. Presentation free of raw data APIs | 0 hits |
| 2. Domain and core free of framework imports | 0 hits |
| 3. No date/JSON logic in presentation | 0 hits |
| flutter analyze | EDIT: paste your output |
| flutter test | EDIT: paste your output |
