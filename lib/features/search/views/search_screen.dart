import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/media_thumbnail.dart';
import '../controllers/search_controller.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchControllerProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: ref.read(searchControllerProvider.notifier).setQuery,
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.results.isEmpty
              ? _Empty(l: l, hasQuery: state.query.isNotEmpty)
              : GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final item = state.results[index];
                    return MediaThumbnail(
                      item: item,
                      onTap: () => context.go('/viewer/${item.id}'),
                    );
                  },
                ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l, required this.hasQuery});
  final AppLocalizations l;
  final bool hasQuery;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(hasQuery ? l.noResults : l.search, style: Theme.of(context).textTheme.titleMedium),
          if (hasQuery) ...[
            const SizedBox(height: 4),
            Text(l.tryDifferentSearch, style: const TextStyle(color: AppColors.neutral600)),
          ],
        ],
      ),
    );
  }
}
