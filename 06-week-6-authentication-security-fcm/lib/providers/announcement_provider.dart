import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/announcement_repository.dart';
import 'auth_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => AnnouncementRepository(ref.watch(dioProvider)),
);

final announcementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) {
  return ref.watch(announcementRepositoryProvider).fetchAll();
});

final announcementProvider =
    FutureProvider.autoDispose.family<Announcement, String>((ref, id) {
  return ref.watch(announcementRepositoryProvider).fetchById(id);
});
