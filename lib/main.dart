import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/models/source.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/providers/navigation.dart';
import 'package:newsapp/core/providers/search.dart';
import 'package:newsapp/core/providers/timer.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLIC_ANON_KEY']!,
  );
  Article.registerAdapter();
  Source.registerAdapter();
  await Hive.initFlutter();
  final settingsService = SettingsService();
  await settingsService.openBox();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShellProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider(settingsService)),
        ChangeNotifierProvider(create: (_) => HomeFeedsProvider()),
        ChangeNotifierProvider(create: (_) => FromSourceFeedsProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider(context)),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const NewsApp(),
    ),
  );
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NixNews',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: context.watch<SettingsProvider>().darkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
