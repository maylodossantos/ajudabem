import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cover_image.dart';
import '../../../initiatives/presentation/widgets/initiative_cards.dart';
import '../../domain/entities/news_article.dart';

class NewsManageCard extends StatelessWidget {
  const NewsManageCard({
    required this.article,
    required this.onOpen,
    super.key,
  });

  final NewsArticle article;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InitiativeCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: AppCoverImage(
                  imageUrl: article.coverImage,
                  aspectRatio: 1,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  placeholder: const ColoredBox(
                    color: AppColors.border,
                    child: Icon(Icons.newspaper, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: AppColors.textStrong,
                        fontSize: AppTextSize.title,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                    if (article.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: AppColors.textBody,
                          fontSize: AppTextSize.caption,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                    if (article.locationLabel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.locationLabel,
                        style: GoogleFonts.manrope(
                          color: AppColors.textBody,
                          fontSize: AppTextSize.caption,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 30,
            child: FilledButton(
              key: Key('news_manage_open_${article.id}'),
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'Ver detalhes',
                style: GoogleFonts.manrope(
                  color: primary,
                  fontSize: AppTextSize.small,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
