import 'package:campus_notes_clean/core/failures.dart';
import 'package:campus_notes_clean/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notes_clean/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notes_clean/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AnnouncementRepository {
  _FakeRepo({this.fail = false});
  final bool fail;

  @override
  Future<({List<Announcement> items, Failure? failure})>
      fetchAnnouncements() async {
    if (fail) {
      return (
        items: const <Announcement>[],
        failure: const NetworkFailure('No internet connection.'),
      );
    }
    return (
      items: const [Announcement(id: 1, title: 'Exam', body: 'Mon 08:00')],
      failure: null,
    );
  }
}

void main() {
  test('success', () async {
    final r = await GetAnnouncements(_FakeRepo())();
    expect(r.failure, isNull);
    expect(r.items.single.title, 'Exam');
  });

  test('network failure becomes a Failure, not an exception', () async {
    final r = await GetAnnouncements(_FakeRepo(fail: true))();
    expect(r.failure, isA<NetworkFailure>());
    expect(r.items, isEmpty);
  });
}
