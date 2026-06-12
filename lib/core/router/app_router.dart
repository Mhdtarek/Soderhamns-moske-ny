import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

int _calculateSelectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  if (location == Routes.home) return 0;
  if (location.startsWith(Routes.prayerTimes)) return 1;
  if (location.startsWith(Routes.news)) return 2;
  if (location.startsWith(Routes.more)) return 3;
  return 0;
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final selectedIndex = _calculateSelectedIndex(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
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
        );
      },
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
          builder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return NewsDetailScreen(slug: slug);
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
      builder: (context, state) => const DonateScreen(),
    ),
    GoRoute(
      path: Routes.contact,
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.qibla,
      builder: (context, state) => const QiblaScreen(),
    ),
  ],
);
