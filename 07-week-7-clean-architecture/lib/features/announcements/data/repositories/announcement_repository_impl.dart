import 'package:dio/dio.dart';
import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this._dio);

  /// Factory keeps the Dio construction inside the data layer.
  /// jsonplaceholder is a stand-in for the Campus Notify backend.
  factory AnnouncementRepositoryImpl.create({
    String baseUrl = 'https://jsonplaceholder.typicode.com',
  }) {
    return AnnouncementRepositoryImpl(Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));
  }

  final Dio _dio;

  @override
  Future<({List<Announcement> items, Failure? failure})>
      fetchAnnouncements() async {
    try {
      final res = await _dio
          .get<List<dynamic>>('/posts', queryParameters: {'_limit': 20});
      final items = (res.data ?? [])
          .cast<Map<String, dynamic>>()
          .map((j) => AnnouncementModel.fromJson(j).toEntity())
          .toList();
      return (items: items, failure: null);
    } on DioException catch (e) {
      return (
        items: const <Announcement>[],
        failure: NetworkFailure(_friendly(e)),
      );
    } catch (_) {
      return (
        items: const <Announcement>[],
        failure: const NetworkFailure('Unexpected error. Please try again.'),
      );
    }
  }

  String _friendly(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Could not load announcements.';
    }
  }
}
