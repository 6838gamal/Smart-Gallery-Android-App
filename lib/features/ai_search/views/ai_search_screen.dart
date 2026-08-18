import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/media_thumbnail.dart';
import '../controllers/ai_search_controller.dart';

class AiSearchScreen extends ConsumerWidget {
  const AiSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiSearchControllerProvider);
    final suggestions = ref.watch(aiSuggestionProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.aiSearchHint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.auto_awesome),
          ),
          onSubmitted: ref.read(aiSearchControllerProvider.notifier).search,
        ),
      ),
      body: state.loading
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(l.aiSearching),
            ]))
          : state.error != null
              ? Center(child: Text(l.aiNotAvailable, style: const TextStyle(color: AppColors.error)))
              : state.results.isEmpty && state.query.isNotEmpty
                  ? _Empty(l: l)
                  : state.results.isEmpty
                      ? _Suggestions(suggestions: suggestions, ref: ref)
                      : _Results(state: state),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions, required this.ref});
  final List<String> suggestions;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final s in suggestions)
              ActionChip(
                label: Text(s),
                avatar: const Icon(Icons.auto_awesome, size: 18),
                onPressed: () => ref.read(aiSearchControllerProvider.notifier).search(s),
              ),
            Text(l.aiSearchHint, style: const TextStyle(color: AppColors.neutral600)),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});
  final AiSearchState state;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final r = state.results[index];
        return MediaThumbnail(
          item: r.item,
          onTap: () => context.go('/viewer/${r.item.id}'),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 72, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(l.noResults, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l.tryDifferentSearch, style: const TextStyle(color: AppColors.neutral600)),
        ],
      ),
    );
  }
}
