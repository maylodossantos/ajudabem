import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../domain/entities/news_article.dart';
import '../../domain/entities/news_category.dart';
import 'feed_item.dart';

Widget _placeholder(IconData icon) => ColoredBox(
  color: AppColors.border,
  child: Center(child: Icon(icon, color: Colors.white, size: 36)),
);

class FeedTagPill extends StatelessWidget {
  const FeedTagPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: AppTextSize.caption,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class FeedByline extends StatelessWidget {
  const FeedByline({required this.author, super.key, this.when = ''});

  final String author;
  final String when;

  @override
  Widget build(BuildContext context) {
    final muted = GoogleFonts.manrope(
      color: AppColors.textMuted,
      fontSize: AppTextSize.caption,
      letterSpacing: 0,
    );

    return Text.rich(
      TextSpan(
        style: muted,
        children: [
          if (author.isNotEmpty) ...[
            const TextSpan(text: 'Por '),
            TextSpan(
              text: author,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (author.isNotEmpty && when.isNotEmpty)
            const TextSpan(text: '  •  '),
          if (when.isNotEmpty) TextSpan(text: when),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({required this.onTap, required this.child, this.color});

  final VoidCallback onTap;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(AppRadius.xl);

    return Material(
      color: color ?? Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: primary.withValues(alpha: 0.04),
        splashColor: primary.withValues(alpha: 0.08),
        highlightColor: primary.withValues(alpha: 0.06),
        child: child,
      ),
    );
  }
}

class FeedFeaturedCard extends StatelessWidget {
  const FeedFeaturedCard({required this.item, required this.onTap, super.key});

  final FeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Tappable(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppCoverImage(
                imageUrl: item.coverImage,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                placeholder: _placeholder(item.placeholderIcon),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: FeedTagPill(label: item.tag),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: AppColors.textStrong,
              fontSize: AppTextSize.display,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          if (item.subtitle.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: AppColors.textSecondary,
                fontSize: AppTextSize.body,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          FeedByline(author: item.author, when: item.when),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class FeedTileCard extends StatelessWidget {
  const FeedTileCard({required this.item, required this.onTap, super.key});

  final FeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return _Tappable(
      onTap: onTap,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCoverImage(
            imageUrl: item.coverImage,
            aspectRatio: 16 / 10,
            placeholder: _placeholder(item.placeholderIcon),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: primary,
                          fontSize: AppTextSize.caption,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    if (item.when.isNotEmpty)
                      Text(
                        item.when,
                        style: GoogleFonts.manrope(
                          color: AppColors.textMuted,
                          fontSize: AppTextSize.caption,
                          letterSpacing: 0,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: AppColors.textStrong,
                    fontSize: AppTextSize.body,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FeedByline(author: item.author),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeedHighlightCard extends StatelessWidget {
  const FeedHighlightCard({required this.item, required this.onTap, super.key});

  final FeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Tappable(
      onTap: onTap,
      color: AppColors.coverDark,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCoverImage(
            imageUrl: item.coverImage,
            placeholder: _placeholder(item.placeholderIcon),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xCC000000)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppSpacing.sm,
                  children: [
                    Flexible(child: FeedTagPill(label: item.tag)),
                    if (item.when.isNotEmpty)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                item.when,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: AppTextSize.caption,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: AppTextSize.title,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCategoryChips extends StatelessWidget {
  const NewsCategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
    super.key,
    this.campaignsSelected = false,
    this.onCampaigns,
  });

  final List<NewsCategory> categories;
  final NewsCategory? selected;
  final ValueChanged<NewsCategory?> onSelected;
  final bool campaignsSelected;
  final VoidCallback? onCampaigns;

  @override
  Widget build(BuildContext context) {
    final onCampaigns = this.onCampaigns;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          AppChoiceChip(
            key: const Key('news_category_all'),
            label: 'Todas',
            selected: selected == null && !campaignsSelected,
            onTap: () => onSelected(null),
          ),
          if (onCampaigns != null)
            AppChoiceChip(
              key: const Key('news_category_campaigns'),
              label: 'Campanhas',
              selected: campaignsSelected,
              onTap: onCampaigns,
            ),
          for (final category in categories)
            AppChoiceChip(
              key: Key('news_category_${category.apiValue}'),
              label: category.label,
              selected: !campaignsSelected && selected == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

List<NewsCategory> newsCategoriesIn(List<NewsArticle> articles) {
  final present = {for (final article in articles) article.category};
  return [
    for (final category in NewsCategory.values)
      if (present.contains(category)) category,
  ];
}
