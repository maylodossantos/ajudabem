import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_error_view.dart';

class AppAsyncList<T> extends StatelessWidget {
  const AppAsyncList({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.emptyMessage,
    required this.onRefresh,
    required this.itemBuilder,
    super.key,
    this.spacing = 12,
    this.columns = 1,
    this.gridItemHeight,
    this.padding,
  });

  final List<T> items;
  final bool isLoading;
  final String? errorMessage;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;

  final int columns;
  final double? gridItemHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = errorMessage;
    if (error != null && items.isEmpty) {
      return AppErrorView(message: error, onRetry: onRefresh);
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            color: const Color(0xFF454545),
            fontSize: 14,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: columns > 1
          ? GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                mainAxisExtent: gridItemHeight,
              ),
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index]),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: spacing),
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index]),
            ),
    );
  }
}
