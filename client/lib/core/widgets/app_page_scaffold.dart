import 'package:flutter/material.dart';

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
    this.isLoading = false,
  });

  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final Key? primaryKey;
  final Key? secondaryKey;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppOutlinedButton(
            key: secondaryKey,
            label: secondaryLabel,
            onPressed: onSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppPrimaryButton(
            key: primaryKey,
            label: primaryLabel,
            isLoading: isLoading,
            onPressed: onPrimary,
          ),
        ),
      ],
    );
  }
}
