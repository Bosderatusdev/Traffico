import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);
  runApp(const TrafficoApp());
}

class TrafficoApp extends StatefulWidget {
  const TrafficoApp({super.key});

  static _TrafficoAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_TrafficoAppState>();

  @override
  State<TrafficoApp> createState() => _TrafficoAppState();
}

class _TrafficoAppState extends State<TrafficoApp> {
  Locale _locale = const Locale('fr');

  @override
  void initState() {
    super.initState();
    _chargerLocale();
  }

  Future<void> _chargerLocale() async {
    final code = await LocaleService.getSavedLocale();
    if (code != null && mounted) {
      setState(() => _locale = Locale(code));
    }
  }

  void changerLangue(String code) {
    setState(() => _locale = Locale(code));
    LocaleService.saveLocale(code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffico',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: _locale,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomeScreen(),
    );
  }
}