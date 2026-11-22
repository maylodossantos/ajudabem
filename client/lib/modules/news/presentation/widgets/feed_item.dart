import 'package:flutter/material.dart';

import '../../../../core/formatters/date_input_formatter.dart';
import '../../../initiatives/domain/entities/campaign.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_category.dart';

class FeedItem {
  const FeedItem({
    required this.tag,
    required this.title,
    required this.placeholderIcon,
    this.coverImage,
    this.subtitle = '',
    this.author = '',
    this.when = '',
    this.meta = '',
  });

  factory FeedItem.article(NewsArticle article, DateTime now) {
    final createdAt = article.createdAt;
    final when = createdAt == null
        ? ''
        : DateInputFormatter.relative(createdAt, now);
    return FeedItem(
      tag: article.category.label,
      title: article.title,
      subtitle: article.subtitle,
      coverImage: article.coverImage,
      author: article.authorName,
      when: when,
      meta: _join([article.locationLabel, when]),
      placeholderIcon: Icons.newspaper,
    );
  }

  factory FeedItem.campaign(Campaign campaign, DateTime now) {
    final deadline = campaign.deadlineLabel(now).replaceAll(RegExp(r'\.$'), '');
    return FeedItem(
      tag: 'Campanha',
      title: campaign.title,
      subtitle: campaign.subtitle,
      coverImage: campaign.coverImage,
      author: campaign.organizationName,
      when: deadline,
      meta: _join([campaign.organizationName, deadline]),
      placeholderIcon: Icons.campaign_outlined,
    );
  }

  final String tag;
  final String title;
  final String subtitle;
  final String? coverImage;
  final String author;
  final String when;
  final String meta;
  final IconData placeholderIcon;

  static String _join(List<String> parts) =>
      parts.where((part) => part.isNotEmpty).join('  •  ');
}

class FeedEntry {
  FeedEntry.article(NewsArticle this.article, DateTime now)
    : campaign = null,
      item = FeedItem.article(article, now),
      date = article.createdAt;

  FeedEntry.campaign(Campaign this.campaign, DateTime now)
    : article = null,
      item = FeedItem.campaign(campaign, now),
      date = campaign.createdAt;

  final NewsArticle? article;
  final Campaign? campaign;
  final FeedItem item;
  final DateTime? date;

  String get _prefix => campaign == null ? 'news' : 'campaign';
  int get _id => article?.id ?? campaign!.id;
  String get cardKey => '${_prefix}_card_$_id';
  String get highlightKey => '${_prefix}_highlight_$_id';
  String get tileKey => campaign == null ? cardKey : 'home_campaign_$_id';

  static List<FeedEntry> build({
    required List<NewsArticle> articles,
    required List<Campaign> campaigns,
    required DateTime now,
    NewsCategory? category,
    bool campaignsOnly = false,
  }) {
    if (campaignsOnly) {
      return [for (final c in campaigns) FeedEntry.campaign(c, now)];
    }
    final news = [
      for (final a in articles)
        if (category == null || a.category == category)
          FeedEntry.article(a, now),
    ];
    if (category != null) return news;
    final all = [
      ...news,
      for (final c in campaigns) FeedEntry.campaign(c, now),
    ];
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return all..sort((a, b) => (b.date ?? epoch).compareTo(a.date ?? epoch));
  }
}
