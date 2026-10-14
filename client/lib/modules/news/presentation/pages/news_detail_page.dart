import 'package:flutter/material.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_cover_detail.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../domain/entities/news_article.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({required this.article, super.key});

  final NewsArticle article;

  String get _caption {
    final createdAt = article.createdAt;
    return [
      article.authorName,
      if (createdAt != null) DateInputFormatter.stamp(createdAt.toLocal()),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      currentItem: AppNavigationItem.news,
      maxWidth: 560,
      body: AppCoverDetail(
        imageUrl: article.coverImage,
        caption: _caption,
        title: article.title,
        subtitle: article.subtitle,
        body: article.content,
        placeholderIcon: Icons.newspaper,
      ),
    );
  }
}
