import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_post.freezed.dart';
part 'news_post.g.dart';

@freezed
class NewsPost with _$NewsPost {
  const factory NewsPost({
    required String slug,
    required String title,
    required DateTime date,
    @Default('') String excerpt,
    String? body,
    String? imageUrl,
  }) = _NewsPost;

  factory NewsPost.fromJson(Map<String, dynamic> json) =>
      _$NewsPostFromJson(json);
}
