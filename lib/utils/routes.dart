import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/models/source.dart';
import 'package:newsapp/ui/screens/account.dart';
import 'package:newsapp/ui/screens/article.dart';
import 'package:newsapp/ui/screens/auth/email.dart';
import 'package:newsapp/ui/screens/auth/otp.dart';
import 'package:newsapp/ui/screens/bookmarks.dart';
import 'package:newsapp/ui/screens/from_source.dart';
import 'package:newsapp/ui/screens/home.dart';
import 'package:newsapp/ui/screens/premium/entrances.dart';
import 'package:newsapp/ui/screens/premium/jobs.dart';
import 'package:newsapp/ui/screens/premium/scholarships.dart';
import 'package:newsapp/ui/screens/settings.dart';
import 'package:newsapp/ui/widgets/screens/shell.dart';

class ShellDestination {
  final String name;
  final String path;
  final Widget widget;

  const ShellDestination({
    required this.name,
    required this.path,
    required this.widget,
  });
}

class ShellRoutes {
  static const ShellDestination home = ShellDestination(
    name: "home",
    path: '/',
    widget: HomeScreen(),
  );
  static const ShellDestination bookmarks = ShellDestination(
    name: "bookmarks",
    path: '/bookmarks',
    widget: BookmarksScreen(),
  );
  static const ShellDestination settings = ShellDestination(
    name: "settings",
    path: '/settings',
    widget: SettingsScreen(),
  );

  static toList() {
    return [
      home,
      bookmarks,
      settings,
    ];
  }
}

class OtherRoutes {
  static const String article = "/article";
  static const String account = "/settings/account";
  static const signin = "/auth/signin";
  static const signup = "/auth/signup";
  static const otp = "/auth/challenge/otp";
  static const String fromSource = "/articles/from-source";
  static const String scholarships = "/scholarships";
  static const String jobs = "/jobs";
  static const String entrances = "/entrances";
}

GlobalKey<NavigatorState>? rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: OtherRoutes.article,
      name: OtherRoutes.article,
      builder: (context, state) {
        final article = state.extra as Article;
        return ArticleScreen(article: article);
      },
    ),
    GoRoute(
      path: OtherRoutes.account,
      name: OtherRoutes.account,
      builder: (context, state) {
        return const AccountScreen();
      },
    ),
    GoRoute(
      name: OtherRoutes.signin,
      path: OtherRoutes.signin,
      builder: (context, state) {
        return const EmailAuthScreen();
      },
    ),
    GoRoute(
      name: OtherRoutes.otp,
      path: OtherRoutes.otp,
      builder: (context, state) {
        return const OTPScreen();
      },
    ),
    GoRoute(
      path: OtherRoutes.fromSource,
      name: OtherRoutes.fromSource,
      builder: (context, state) {
        final source = state.extra as Source;
        return FromSourceScreen(source: source);
      },
    ),
    GoRoute(
      path: OtherRoutes.scholarships,
      name: OtherRoutes.scholarships,
      builder: (context, state) {
        return const ScholarshipsScreen();
      },
    ),
    GoRoute(
      path: OtherRoutes.jobs,
      name: OtherRoutes.jobs,
      builder: (context, state) {
        return const JobsScreen();
      },
    ),
    GoRoute(
      path: OtherRoutes.entrances,
      name: OtherRoutes.entrances,
      builder: (context, state) {
        return const EntrancesScreen();
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => Shell(body: child),
      routes: [
        GoRoute(
          path: '/',
          name: ShellRoutes.home.name,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/bookmarks',
          name: ShellRoutes.bookmarks.name,
          builder: (context, state) => const BookmarksScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: ShellRoutes.settings.name,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    )
  ],
);
