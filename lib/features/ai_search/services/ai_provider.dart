import '../../../data/models/media_item.dart';
import '../models/ai_result.dart';

/// Abstraction so the AI backend can evolve (local → cloud → embeddings)
/// without touching the UI. Implementations must be safe to call from the
/// UI thread; long work should be offloaded internally.
abstract class AIProvider {
  Future<List<AiResult>> search(String query, List<MediaItem> candidates);
}

/// MVP local provider. Matches the query against precomputed `aiTags` on each
/// media item using simple token overlap. Works fully offline. When no items
/// have tags yet, it falls back to filename keywords so the feature is never
/// a dead end.
class LocalAIProvider implements AIProvider {
  LocalAIProvider();

  static const Map<String, List<String>> _synonyms = {
    'car': ['car', 'cars', 'vehicle', 'auto'],
    'cars': ['car', 'cars', 'vehicle', 'auto'],
    'sea': ['sea', 'beach', 'ocean', 'water', 'بحر'],
    'beach': ['sea', 'beach', 'ocean', 'water', 'بحر'],
    'cat': ['cat', 'cats', 'kitten', 'قط', 'قطط'],
    'cats': ['cat', 'cats', 'kitten', 'قط', 'قطط'],
    'food': ['food', 'meal', 'dish', 'طعام', 'أكل'],
    'person': ['person', 'people', 'face', 'human', 'شخص', 'أشخاص'],
    'people': ['person', 'people', 'face', 'human', 'شخص', 'أشخاص'],
  };

  @override
  Future<List<AiResult>> search(String query, List<MediaItem> candidates) async {
    final tokens = _tokenize(query);
    if (tokens.isEmpty) return [];
    final expanded = <String>{};
    for (final t in tokens) {
      expanded.add(t);
      expanded.addAll(_synonyms[t] ?? const []);
    }

    final scored = <AiResult>[];
    for (final m in candidates) {
      double score = 0;
      final matched = <String>[];
      for (final tag in m.aiTags) {
        if (expanded.contains(tag.toLowerCase())) {
          score += 1;
          matched.add(tag);
        }
      }
      // Fallback: filename keyword match.
      if (score == 0) {
        final name = m.displayName.toLowerCase();
        for (final t in expanded) {
          if (name.contains(t)) {
            score += 0.5;
            matched.add(t);
          }
        }
      }
      if (score > 0) scored.add(AiResult(item: m, score: score, matchedTags: matched));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  List<String> _tokenize(String q) {
    return q
        .toLowerCase()
        .split(RegExp(r'[\s,]+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

/// Placeholder for a future cloud provider (e.g. embeddings API). Kept here
/// so the abstraction is concrete and the UI can swap providers via config.
class CloudAIProvider implements AIProvider {
  CloudAIProvider();
  @override
  Future<List<AiResult>> search(String query, List<MediaItem> candidates) async {
    throw UnimplementedError('CloudAIProvider not configured yet');
  }
}
