import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_cover_image.dart';
import '../../domain/entities/campaign.dart';

class CampaignCarousel extends StatefulWidget {
  const CampaignCarousel({
    required this.campaigns,
    required this.onOpen,
    super.key,
    this.interval = const Duration(seconds: 4),
  });

  final List<Campaign> campaigns;
  final ValueChanged<Campaign> onOpen;
  final Duration interval;

  @override
  State<CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<CampaignCarousel> {
  static const _loops = 1000;

  late final PageController _controller = PageController(
    initialPage: widget.campaigns.length * _loops,
  );
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    if (widget.campaigns.length < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (_controller.hasClients) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final campaigns = widget.campaigns;
    final now = DateTime.now();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: campaigns.length * _loops * 2,
            onPageChanged: (page) {
              setState(() => _page = page % campaigns.length);
              _restart();
            },
            itemBuilder: (_, index) {
              final campaign = campaigns[index % campaigns.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Material(
                    color: const Color(0xFF8FA79F),
                    child: InkWell(
                      key: Key('carousel_campaign_${campaign.id}'),
                      onTap: () => widget.onOpen(campaign),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppCoverImage(
                            imageUrl: campaign.coverImage,
                            aspectRatio: 16 / 9,
                            placeholder: const Icon(
                              Icons.campaign_outlined,
                              size: 48,
                              color: Colors.white70,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                10,
                                16,
                                12,
                              ),
                              color: const Color(0xB80A2820),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1F5EE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      campaign
                                          .deadlineLabel(now)
                                          .replaceAll('.', ''),
                                      style: GoogleFonts.manrope(
                                        color: const Color(0xFF085041),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    campaign.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  Text(
                                    campaign.organizationName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      color: const Color(0xFF9FE1CB),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < campaigns.length; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: index == _page ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == _page ? primary : const Color(0xFFC9C9C9),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
