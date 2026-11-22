import 'news_category.dart';

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.coverImage,
    required this.authorName,
    this.city = '',
    this.state = '',
    this.createdAt,
    this.category = NewsCategory.other,
  });

  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? coverImage;
  final String authorName;
  final String city;
  final String state;
  final DateTime? createdAt;
  final NewsCategory category;

  String get locationLabel =>
      [city, state].where((part) => part.isNotEmpty).join(', ');
}
