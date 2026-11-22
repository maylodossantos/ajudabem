import 'news_category.dart';

class NewsFormParams {
  const NewsFormParams({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.coverImage,
    this.city = '',
    this.state = '',
    this.category = NewsCategory.other,
  });

  final String title;
  final String subtitle;
  final String content;
  final String? coverImage;
  final String city;
  final String state;
  final NewsCategory category;
}
