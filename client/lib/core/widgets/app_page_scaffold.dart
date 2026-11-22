import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_bottom_navigation.dart';
import 'app_button.dart';
import 'app_main_navigation.dart';
import 'auth_app_bar.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.currentItem,
    required this.body,
    super.key,
    this.bottomBar,
    this.floatingActionButton,
    this.maxWidth = 520,
    this.showBackButton = true,
  });

  final AppNavigationItem currentItem;
  final Widget body;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final double maxWidth;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final bar = bottomBar;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AuthAppBar(showBackButton: showBackButton),
      bottomNavigationBar: AppMainNavigation(currentItem: currentItem),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: bar == null
                ? body
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: body),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 10, 28, 14),
                        child: bar,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AppBottomActions extends StatelessWidget {
  const AppBottomActions({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
    this.primaryKey,
    this.secondaryKey,
    this.secondaryColor,
    this.secondaryBorderColor,
    this.primaryColor,
    this.isLoading = false,
  });

  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final Color? secondaryColor;
  final Color? secondaryBorderColor;
  final Color? primaryColor;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final Key? primaryKey;
  final Key? secondaryKey;
  final bool isLoading;

  static const _height = 44.0;
  static const _gap = AppSpacing.md;
  static const _padding = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = (constraints.maxWidth - _gap) / 2 - 2 * _padding - 4;
        final fontSize = AppButtonLabel.fitSize([
          secondaryLabel,
          primaryLabel,
        ], labelWidth);

        return Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                key: secondaryKey,
                label: secondaryLabel,
                onPressed: onSecondary,
                color: secondaryColor,
                borderColor: secondaryBorderColor,
                dense: true,
                fontSize: fontSize,
                height: _height,
                radius: AppRadius.md,
              ),
            ),
            const SizedBox(width: _gap),
            Expanded(
              child: AppPrimaryButton(
                key: primaryKey,
                label: primaryLabel,
                isLoading: isLoading,
                onPressed: onPrimary,
                color: primaryColor,
                fontSize: fontSize,
                height: _height,
                radius: AppRadius.md,
                horizontalPadding: _padding,
              ),
            ),
          ],
        );
      },
    );
  }
}
