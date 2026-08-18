import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_search/views/ai_search_screen.dart';
import '../../features/albums/views/album_detail_screen.dart';
import '../../features/albums/views/albums_screen.dart';
import '../../features/editor/views/editor_screen.dart';
import '../../features/favorites/views/favorites_screen.dart';
import '../../features/gallery/views/gallery_screen.dart';
import '../../features/media_viewer/views/media_viewer_screen.dart';
import '../../features/search/views/search_screen.dart';
import '../../features/security/views/security_screen.dart';
import '../../features/security/views/unlock_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/trash/views/trash_screen.dart';
import '../localization/app_localizations.dart';
import 'app_router_notifier.dart';

/// Central GoRouter. The shell route hosts the bottom nav (Gallery / Albums /
/// Search / AI / Settings). A redirect to `/unlock` enforces the app lock when
/// the user has configured one.
GoRouter buildRouter(WidgetRef ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);
  return GoRouter(
    initialLocation: '/gallery',
    refreshListenable: notifier,
    redirect: (context, state) {
      final locked = notifier.shouldLock;
      final unlocking = state.matchedLocation == '/unlock';
      if (locked && !unlocking) return '/unlock';
      if (!locked && unlocking) return '/gallery';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/gallery',
            name: 'gallery',
            builder: (_, __) => const GalleryScreen(),
          ),
          GoRoute(
            path: '/albums',
            name: 'albums',
            builder: (_, __) => const AlbumsScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/ai-search',
            name: 'aiSearch',
            builder: (_, __) => const AiSearchScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/unlock',
        name: 'unlock',
        builder: (_, __) => const UnlockScreen(),
      ),
      GoRoute(
        path: '/album/:id',
        name: 'albumDetail',
        builder: (_, state) => AlbumDetailScreen(
          albumId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/viewer/:id',
        name: 'viewer',
        builder: (_, state) => MediaViewerScreen(
          mediaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/editor/:id',
        name: 'editor',
        builder: (_, state) => EditorScreen(
          mediaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/trash',
        name: 'trash',
        builder: (_, __) => const TrashScreen(),
      ),
      GoRoute(
        path: '/security',
        name: 'security',
        builder: (_, __) => const SecurityScreen(),
      ),
    ],
  );
}

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final location = GoRouterState.of(context).matchedLocation;
    final index = _navIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_navPath(i)),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.photo_outlined),
            selectedIcon: const Icon(Icons.photo),
            label: l.gallery,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l.albums,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: l.aiSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.settings,
          ),
        ],
      ),
    );
  }

  int _navIndex(String location) {
    if (location.startsWith('/albums')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/ai-search')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  String _navPath(int i) => const ['/gallery', '/albums', '/search', '/ai-search', '/settings'][i];
}
