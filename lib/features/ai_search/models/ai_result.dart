import '../../../data/models/media_item.dart';

/// A scored result from an AI search.
class AiResult {
  const AiResult({required this.item, required this.score, required this.matchedTags});
  final MediaItem item;
  final double score;
  final List<String> matchedTags;
}
