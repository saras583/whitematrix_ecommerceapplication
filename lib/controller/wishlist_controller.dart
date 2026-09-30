import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller responsible for managing user's wishlist / favorite items.
/// Persists product IDs locally using SharedPreferences.
class WishlistController extends ChangeNotifier {
  static const _key = 'wishlist_ids';
  final Set<int> _ids = {};

  /// Returns sorted list of favorited product IDs
  List<int> get ids => _ids.toList()..sort();

  /// Check if a specific product is marked as favorite
  bool isFavorite(int id) => _ids.contains(id);

  /// Load saved wishlist IDs from local storage on app startup
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_key) ?? [];
    _ids.clear();
    for (final str in savedList) {
      final parsed = int.tryParse(str);
      if (parsed != null) {
        _ids.add(parsed);
      }
    }
    notifyListeners();
  }

  /// Toggles favorite status for a given product ID and saves to storage
  Future<void> toggle(int id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.map((e) => e.toString()).toList());
  }
}
