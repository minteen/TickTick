import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/today/today_page.dart';
import 'presentation/lists/lists_page.dart';
import 'presentation/lists/list_detail_page.dart';
import 'presentation/search/search_page.dart';
import 'presentation/settings/settings_page.dart';
import 'presentation/task_detail/task_detail_page.dart';
import 'presentation/task_form/task_form_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/today',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/today', builder: (_, __) => const TodayPage()),
        GoRoute(path: '/lists', builder: (_, __) => const ListsPage()),
        GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/lists/:id',
      builder: (_, state) => ListDetailPage(listId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/task/:id',
      builder: (_, state) => TaskDetailPage(taskId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/task/new',
      builder: (_, state) {
        final listId = state.uri.queryParameters['listId'];
        return TaskFormPage(listId: listId != null ? int.parse(listId) : null);
      },
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/today')) return 0;
    if (location.startsWith('/lists')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          final routes = ['/today', '/lists', '/search', '/settings'];
          context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Lists'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
