import 'package:flutter/foundation.dart';

class FavouritesStore {
  /// Stores Place IDs
  static final ValueNotifier<Set<String>> favIds =
      ValueNotifier<Set<String>>(<String>{});

  /// Backwards compatible (older code might call favouriteIds)
  static Set<String> get favouriteIds => favIds.value;

  /// Backwards compatible (some code might call listenable)
  static ValueListenable<Set<String>> get listenable => favIds;

  static bool isFavourite(String id) => favIds.value.contains(id);

  static void toggle(String id) {
    final next = {...favIds.value};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    favIds.value = next;
  }

  static void clear() {
    favIds.value = <String>{};
  }
}
