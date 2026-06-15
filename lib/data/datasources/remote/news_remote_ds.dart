import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';
import 'package:soderhamns_moske_app/core/network/dio_client.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

class NewsRemoteDs {
  final Dio _dio;

  NewsRemoteDs({Dio? dio}) : _dio = dio ?? dioClient;

  Future<List<NewsPost>> getNewsPosts() async {
    try {
      final response = await _dio.get('/api/getNewsPosts');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => _itemFromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<NewsPost> getNewsPost(String slug) async {
    try {
      final response = await _dio.get('/api/getNewsPost/$slug');
      final data = response.data as Map<String, dynamic>;
      return _itemFromApi(data);
    } on DioException {
      throw const NetworkException();
    } catch (_) {
      throw const ParseException();
    }
  }

  NewsPost _itemFromApi(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final path = json['path'] as String? ?? '';
    return NewsPost(
      slug: path.split('/').last,
      title: meta['title'] as String? ?? '',
      date: DateTime.parse(meta['date'] as String),
      excerpt: json['excerpt'] as String? ?? '',
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
