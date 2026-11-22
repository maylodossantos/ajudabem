import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCarousel extends StatefulWidget {
  const AppCarousel({
    required this.itemCount,
    required this.itemBuilder,
    required this.height,
    super.key,
    this.interval = const Duration(seconds: 5),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double height;
  final Duration interval;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.itemCount > 1 ? 0.92 : 1,
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
    if (widget.itemCount < 2) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (_controller.hasClients) {
        _controller.animateToPage(
          (_page + 1) % widget.itemCount,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final count = widget.itemCount;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            padEnds: count < 2,
            itemCount: count,
            onPageChanged: (page) {
              setState(() => _page = page);
              _restart();
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: widget.itemBuilder(context, index),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < count; index++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: index == _page ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: index == _page ? primary : AppColors.border,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
