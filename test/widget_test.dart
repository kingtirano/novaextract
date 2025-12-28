// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:nova_extract_app/main.dart';

class _LocaleTestApp extends StatefulWidget {
  const _LocaleTestApp();

  @override
  State<_LocaleTestApp> createState() => _LocaleTestAppState();
}

class _LocaleTestAppState extends State<_LocaleTestApp> {
  Locale? _locale;

  void _onLocaleChanged(Locale? locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('pt')],
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1400, 900)),
          child: MyHomePage(onLocaleChanged: _onLocaleChanged),
        ),
      ),
    );
  }
}

void main() {
  setUp(() {
    // Zera o TestWindow antes de cada teste
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1400, 900);
    binding.window.devicePixelRatioTestValue = 1.0;

    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
  });

  testWidgets('App renders main pieces', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('pt')],
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: const MyHomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NovaExtract'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Drop files here'), findsOneWidget);
    expect(find.text('No files selected'), findsOneWidget);
  });

  testWidgets('Language selector opens and changes locale', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(child: const _LocaleTestApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Select language'), findsOneWidget);

    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets('Extract button disabled with no files', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('pt')],
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: const MyHomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final extractButton = find.widgetWithText(ElevatedButton, 'Extract');
    expect(extractButton, findsOneWidget);

    final ElevatedButton btn = tester.widget<ElevatedButton>(extractButton);
    expect(btn.onPressed, isNull);
  });
}
