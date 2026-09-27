import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_cover_image.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../domain/entities/news_article.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({required this.article, super.key});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AuthAppBar(showBackButton: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCoverImage(
                    imageUrl: article.coverImage,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  if (article.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.subtitle,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF454545),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  if (article.authorName.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Por ${article.authorName}',
                      style: GoogleFonts.manrope(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    article.content,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF232323),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
