import '../../domain/entities/news_article.dart';

class NewsArticleModel {
  const NewsArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.coverImage,
    required this.authorName,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'];

    return NewsArticleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      content: json['content'] as String? ?? '',
      coverImage: json['cover_image'] as String?,
      authorName: author is Map<String, dynamic>
          ? author['name'] as String? ?? ''
          : '',
    );
  }

  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? coverImage;
  final String authorName;

  NewsArticle toEntity() {
    return NewsArticle(
      id: id,
      title: title,
      subtitle: subtitle,
      content: content,
      coverImage: coverImage,
      authorName: authorName,
    );
  }
}
