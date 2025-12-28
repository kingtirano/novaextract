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
  
}
