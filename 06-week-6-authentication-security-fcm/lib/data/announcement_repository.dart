import 'package:dio/dio.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: '${json['id']}',
        title: (json['title'] as String?) ?? '(no title)',
        body: (json['body'] as String?) ?? '',
        date: (json['date'] as String?) ?? '',
      );

  final String id;
  final String title;
  final String body;
  final String date;
}

class AnnouncementRepository {
  AnnouncementRepository(this._dio);
  final Dio _dio;

  Future<List<Announcement>> fetchAll() async {
    final res = await _dio.get<Map<String, dynamic>>('/announcements');
    final items = (res.data?['data'] as List<dynamic>?) ?? const [];
    return items
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Announcement> fetchById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/announcements/$id');
    return Announcement.fromJson(res.data ?? const {});
  }
}
