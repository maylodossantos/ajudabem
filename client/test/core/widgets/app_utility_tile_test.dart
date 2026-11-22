import 'package:ajuda_bem/core/widgets/app_shortcut_tile.dart';
import 'package:ajuda_bem/core/widgets/app_svg_icon.dart';
import 'package:ajuda_bem/core/widgets/app_utility_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _icons = [
  AppIcons.registeredPeople,
  AppIcons.validationRequest,
  AppIcons.validationReview,
  AppIcons.volunteer,
  AppIcons.news,
  AppIcons.needs,
  AppIcons.myOng,
  AppIcons.nominatedPeople,
  AppIcons.inCare,
  AppIcons.initiatives,
  AppIcons.indicatePerson,
  AppIcons.helpPoints,
  AppIcons.beVolunteer,
];

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final asset in _icons) {
    test('$asset is a bundled, parseable svg', () async {
      final svg = await rootBundle.loadString(asset);
      final loader = SvgStringLoader(svg);
      await expectLater(loader.loadBytes(null), completes);
    });
  }

  testWidgets('the tile shows its icon and label and reacts to taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: AppUtilityTile(
              iconAsset: AppIcons.news,
              label: 'Notícias',
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Notícias'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.tap(find.byType(AppUtilityTile));
    expect(taps, 1);
  });

  testWidgets('the shortcut tile shows its svg icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppShortcutTile(
            iconAsset: AppIcons.helpPoints,
            label: 'Pontos de ajuda',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(AppSvgIcon), findsOneWidget);
    expect(find.text('Pontos de ajuda'), findsOneWidget);
  });
}
