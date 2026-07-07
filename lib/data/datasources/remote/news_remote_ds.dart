import 'package:dio/dio.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart'
    show AppException, NetworkException, ParseException;
import 'package:soderhamns_moske_app/core/network/dio_client.dart';
import 'package:soderhamns_moske_app/data/models/news_post.dart';

class NewsRemoteDs {
  final Dio _dio;

  NewsRemoteDs({Dio? dio}) : _dio = dio ?? dioClient;

  Future<List<NewsPost>> getNewsPosts() async {
    try {
      final response = await _dio.get('/api/getNewsPosts');
      final data = response.data;
      if (data is! List) throw const ParseException('Expected List for getNewsPosts');
      return data
          .map((e) {
            if (e is! Map<String, dynamic>) {
              throw const ParseException('Expected Map in getNewsPosts list');
            }
            return _itemFromApi(e);
          })
          .toList();
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  Future<NewsPost> getNewsPost(String slug) async {
    try {
      final response = await _dio.get('/api/getNewsPost/$slug');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ParseException('Expected Map for getNewsPost');
      }
      return _itemFromApi(data);
    } on DioException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const ParseException();
    }
  }

  NewsPost _itemFromApi(Map<String, dynamic> json) {
    final metaRaw = json['meta'];
    var meta = <String, dynamic>{};
    if (metaRaw is Map<String, dynamic>) {
      meta = metaRaw;
    }
    final pathRaw = json['path'];
    final path = pathRaw is String ? pathRaw : '';
    var date = DateTime.now();
    final dateRaw = meta['date'];
    if (dateRaw is String) {
      date = DateTime.parse(dateRaw);
    }
    final titleRaw = meta['title'];
    final title = titleRaw is String ? titleRaw : '';
    final excerptRaw = json['excerpt'];
    final excerpt = excerptRaw is String ? excerptRaw : '';
    final bodyRaw = json['body'];
    final body = bodyRaw is String ? bodyRaw : null;
    final imageUrlRaw = json['imageUrl'];
    final imageUrl = imageUrlRaw is String ? imageUrlRaw : null;
    return NewsPost(
      slug: path.split('/').last,
      title: title,
      date: date,
      excerpt: excerpt,
      body: body,
      imageUrl: imageUrl,
    );
  }
}
