import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../data/models/script.dart';

/// Current dashboard search text. Empty string = no filter.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Recent scripts filtered by [searchQueryProvider]. When the query is empty
/// this is just the live recent list; otherwise it matches title + content
/// (case-insensitive).
final filteredRecentScriptsProvider = Provider<List<Script>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final recent = ref.watch(recentScriptsProvider).valueOrNull ?? const [];
  if (query.isEmpty) return recent;
  return recent
      .where((s) =>
          s.title.toLowerCase().contains(query) ||
          s.content.toLowerCase().contains(query))
      .toList();
});
