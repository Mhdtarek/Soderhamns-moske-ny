import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soderhamns_moske_app/shared/widgets/offline_banner.dart';
import 'routes.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/prayer_times/presentation/prayer_times_screen.dart';
import '../../features/news/presentation/news_list_screen.dart';
import '../../features/news/presentation/news_detail_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/donate/presentation/donate_screen.dart';
import '../../features/contact/presentation/contact_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/qibla/presentation/qibla_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

Page<void> _iosAwarePage({required Widget child, LocalKey? key}) {
  if (_isIOS) {
    return CupertinoPage<void>(key: key, child: child);
  }
  return MaterialPage<void>(key: key, child: child);
}

int _calculateSelectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  if (location == Routes.home) return 0;
  if (location.startsWith(Routes.prayerTimes)) return 1;
  if (location.startsWith(Routes.news)) return 2;
  if (location.startsWith(Routes.more)) return 3;
  return 0;
}

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIOS)
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(Routes.home);
                case 1:
                  context.go(Routes.prayerTimes);
                case 2:
                  context.go(Routes.news);
                case 3:
                  context.go(Routes.more);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Hem',
              ),
              NavigationDestination(
                icon: Icon(Icons.access_time_outlined),
                selectedIcon: Icon(Icons.access_time),
                label: 'Bönetider',
              ),
              NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: 'Nyheter',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz_outlined),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'Mer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.prayerTimes,
          builder: (context, state) => const PrayerTimesScreen(),
        ),
        GoRoute(
          path: Routes.news,
          builder: (context, state) => const NewsListScreen(),
        ),
        GoRoute(
          path: Routes.newsDetail,
          pageBuilder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return _iosAwarePage(
              key: state.pageKey,
              child: NewsDetailScreen(slug: slug),
            );
          },
        ),
        GoRoute(
          path: Routes.more,
          builder: (context, state) => const MoreScreen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.donate,
      pageBuilder: (context, state) => _iosAwarePage(
        key: state.pageKey,
        child: const DonateScreen(),
      ),
    ),
    GoRoute(
      path: Routes.contact,
      pageBuilder: (context, state) => _iosAwarePage(
        key: state.pageKey,
        child: const ContactScreen(),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      pageBuilder: (context, state) => _iosAwarePage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: Routes.qibla,
      pageBuilder: (context, state) => _iosAwarePage(
        key: state.pageKey,
        child: const QiblaScreen(),
      ),
    ),
  ],
);
