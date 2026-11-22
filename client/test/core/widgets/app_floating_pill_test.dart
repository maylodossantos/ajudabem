import 'package:ajuda_bem/core/widgets/app_floating_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('both labels get the same width and do not stretch', (
    tester,
  ) async {
    Future<Size> sizeOf(String label) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppFloatingPill(
                key: const Key('pill'),
                icon: Icons.map_outlined,
                label: label,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byKey(const Key('pill')));
    }

    final list = await sizeOf('Lista');
    final map = await sizeOf('Mapa');

    expect(list, map);
    expect(list.width, lessThan(400));
  });
}
