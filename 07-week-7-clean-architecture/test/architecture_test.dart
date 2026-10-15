import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Automates the dependency-rule greps from Lab 3 so CI can enforce them.
List<File> _dartFiles(String dir) {
  final d = Directory(dir);
  if (!d.existsSync()) return [];
  return d
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

void main() {
  final features = Directory('lib/features').listSync().whereType<Directory>();
  final domainAndCore = [
    ..._dartFiles('lib/core'),
    for (final f in features) ..._dartFiles('${f.path}/domain'),
  ];
  final presentation = [
    ..._dartFiles('lib/shared'),
    for (final f in features) ..._dartFiles('${f.path}/presentation'),
  ];

  test('domain and core import no framework or data package', () {
    final bad = RegExp(r"import 'package:(flutter|dio|sqflite|firebase)");
    for (final f in domainAndCore) {
      expect(bad.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  test('presentation never touches raw data APIs', () {
    final bad = RegExp(
        r'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode');
    for (final f in presentation) {
      expect(bad.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });
}
