import 'package:ajuda_bem/modules/initiatives/domain/entities/campaign.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_article.dart';
import 'package:ajuda_bem/modules/news/domain/entities/news_category.dart';
import 'package:ajuda_bem/modules/news/presentation/widgets/feed_item.dart';
import 'package:flutter_test/flutter_test.dart';

NewsArticle _article(int id, DateTime createdAt, NewsCategory category) =>
    NewsArticle(
      id: id,
      title: 'Notícia $id',
      subtitle: '',
      content: '',
      coverImage: null,
      authorName: 'Admin',
      createdAt: createdAt,
      category: category,
    );

Campaign _campaign(int id, DateTime createdAt) => Campaign(
  id: id,
  title: 'Campanha $id',
  description: '',
  category: CampaignCategory.food,
  status: InitiativeStatus.active,
  createdAt: createdAt,
);

void main() {
  final now = DateTime(2026, 11, 18);
  final articles = [
    _article(1, DateTime(2026, 11, 10), NewsCategory.health),
    _article(2, DateTime(2026, 11, 1), NewsCategory.other),
  ];
  final campaigns = [_campaign(9, DateTime(2026, 11, 5))];

  List<String> keys(List<FeedEntry> entries) =>
      entries.map((entry) => entry.cardKey).toList();

  test('"Todas" mixes news and campaigns, newest first', () {
    final feed = FeedEntry.build(
      articles: articles,
      campaigns: campaigns,
      now: now,
    );

    expect(keys(feed), ['news_card_1', 'campaign_card_9', 'news_card_2']);
    expect(feed[1].item.tag, 'Campanha');
  });

  test('a news category shows only that category', () {
    final feed = FeedEntry.build(
      articles: articles,
      campaigns: campaigns,
      now: now,
      category: NewsCategory.health,
    );

    expect(keys(feed), ['news_card_1']);
  });

  test('"Campanhas" shows only campaigns', () {
    final feed = FeedEntry.build(
      articles: articles,
      campaigns: campaigns,
      now: now,
      campaignsOnly: true,
    );

    expect(keys(feed), ['campaign_card_9']);
  });
}
