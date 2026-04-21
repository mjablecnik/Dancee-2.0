import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dancee_app2/core/service_locator.dart';
import 'package:dancee_app2/i18n/strings.g.dart';
import 'package:dancee_app2/logic/cubits/settings_cubit.dart';
import 'package:dancee_app2/main.dart';

void main() {
  testWidgets('App smoke test - renders without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    LocaleSettings.setLocale(AppLocale.en);
    setupServiceLocator();
    final settingsCubit = sl<SettingsCubit>();

    await tester.pumpWidget(
      TranslationProvider(child: DanceeApp(settingsCubit: settingsCubit)),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
