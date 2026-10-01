import 'package:dio/dio.dart';
import '../models/post.dart';

/// Remote source (Minggu 4): GET /posts JSONPlaceholder.
class PostRepository {
  PostRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final res = await _dio.get<List<dynamic>>('/posts');
    return (res.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}
