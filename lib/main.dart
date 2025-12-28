import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Core
import 'core/localizations.dart';

// Views
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar AdMob apenas em Android e iOS (não suportado em macOS)
  if (Platform.isAndroid || Platform.isIOS) {
    await MobileAds.instance.initialize();
  }
  runApp(const ProviderScope(child: MyApp()));
}

/* =========================
   APP ROOT (Cupertino)
========================= */

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  Brightness _brightness = Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'dark';
    final localeCode = prefs.getString('locale') ?? 'en';
    
    setState(() {
      _brightness = themeMode == 'light' ? Brightness.light : Brightness.dark;
      _locale = Locale(localeCode);
    });
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    if (locale != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('locale', locale.languageCode);
      });
    }
  }

  void _setBrightness(Brightness brightness) {
    setState(() => _brightness = brightness);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('theme_mode', brightness == Brightness.light ? 'light' : 'dark');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _brightness == Brightness.dark;
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaExtract',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('pt')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        brightness: _brightness,
        scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFF1AA0A8),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 14,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ),
      home: MyHomePage(
        onLocaleChanged: _setLocale,
        onBrightnessChanged: _setBrightness,
        currentBrightness: _brightness,
      ),
    );
  }
}

/* =========================
   LOCALIZATION
========================= */
// Moved to core/localizations.dart

/* =========================
   HOME PAGE
========================= */
// Moved to views/home_page.dart

/* =========================
   COMPRESS VIEW
========================= */
// Moved to views/compress_view.dart

/* =========================
   SETTINGS VIEW
========================= */
// Moved to views/settings_view.dart

/* =========================
   SIDEBAR
========================= */
// Moved to widgets/sidebar.dart

/* =========================
   DROP ZONE
========================= */
// Moved to widgets/drop_zone.dart

/* =========================
   FILE DETAILS
========================= */
// Moved to widgets/file_details.dart

/* =========================
   ARCHIVE FILE MODEL
========================= */
// Moved to models/archive_file.dart

/* =========================
   HISTORY VIEW
========================= */
// Moved to views/history_view.dart

/* =========================
   AD BANNER
========================= */
// Moved to widgets/ad_banner.dart
