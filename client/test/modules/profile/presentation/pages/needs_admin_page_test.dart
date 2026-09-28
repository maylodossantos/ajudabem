import 'dart:convert';

import 'package:ajuda_bem/core/tags/tags_repository.dart';
import 'package:ajuda_bem/core/tags/tags_store.dart';
import 'package:ajuda_bem/core/theme/app_theme.dart';
import 'package:ajuda_bem/modules/profile/presentation/pages/needs_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('an admin adds a need and sees the duplicate message', (
    tester,
  ) async {
    const json = {'content-type': 'application/json; charset=utf-8'};
    var created = false;
    final store = TagsStore(
      TagsRepository(
        MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode([
                {'id': 1, 'name': 'Alimentação'},
              ]),
              200,
              headers: json,
            );
          }
          if (created) {
            return http.Response(
              jsonEncode({'message': 'Tag already exists', 'status': 409}),
              409,
              headers: json,
            );
          }
          created = true;
          return http.Response(
            jsonEncode({'id': 7, 'name': 'Higiene'}),
            200,
            headers: json,
          );
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: NeedsAdminPage(store: store, token: 'jwt'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Alimentação'), findsOneWidget);

    Future<void> add(String name) async {
      await tester.tap(find.byKey(const Key('needs_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('need_name_field')), name);
      await tester.tap(find.byKey(const Key('need_name_save')));
      await tester.pumpAndSettle();
    }

    await add('Higiene');
    expect(find.text('Higiene'), findsOneWidget);
    expect(find.text('Necessidade criada.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await add('higiene');
    expect(
      find.text('Já existe uma necessidade com esse nome.'),
      findsOneWidget,
    );
  });
}
