import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_cover_image.dart';
import '../../domain/entities/campaign.dart';

class CampaignCarousel extends StatefulWidget {
  const CampaignCarousel({
    required this.campaigns,
    required this.onOpen,
    super.key,
  });

  final List<Campaign> campaigns;
  final ValueChanged<Campaign> onOpen;

  @override
  State<CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<CampaignCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final campaigns = widget.campaigns;

    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: campaigns.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (_, index) {
                final campaign = campaigns[index];
                return InkWell(
                  key: Key('carousel_campaign_${campaign.id}'),
                  onTap: () => widget.onOpen(campaign),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: ColoredBox(
                                color: const Color(0xFFD9D9D9),
                                child: AppCoverImage(
                                  imageUrl: campaign.coverImage,
                                  aspectRatio: 3.2,
                                  placeholder: Center(
                                    child: Text(
                                      campaign.deadlineLabel(DateTime.now()),
                                      style: GoogleFonts.manrope(
                                        color: const Color(0xFF454545),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < campaigns.length; index++)
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _page
                          ? const Color(0xFFA2A2A2)
                          : const Color(0xFFE0E0E0),
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
