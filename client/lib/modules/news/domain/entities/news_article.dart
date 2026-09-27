class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.coverImage,
    required this.authorName,
  });

  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String? coverImage;
  final String authorName;
}
