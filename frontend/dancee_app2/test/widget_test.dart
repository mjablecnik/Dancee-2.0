import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/main.dart';

void main() {
  testWidgets('App smoke test - renders without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);

    await tester.pumpWidget(TranslationProvider(child: const DanceeApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
