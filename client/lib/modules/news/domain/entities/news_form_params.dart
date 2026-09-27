class NewsFormParams {
  const NewsFormParams({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.coverImage,
  });

  final String title;
  final String subtitle;
  final String content;
  final String? coverImage;
}
