import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:whitematrix_app/models/product.dart';
import 'package:whitematrix_app/service/product_service.dart';

/// Available sorting options for products
class SortOption {
  final String label;
  final String sortBy;
  final String order;
  const SortOption(this.label, this.sortBy, this.order);
}

const sortOptions = [
  SortOption('Recommended', 'id', 'asc'),
  SortOption('Price: Low to High', 'price', 'asc'),
  SortOption('Price: High to Low', 'price', 'desc'),
  SortOption('Top Rated', 'rating', 'desc'),
];

/// Controller managing product catalog, search, categories, sorting, and infinite scroll pagination
class ProductController extends ChangeNotifier {
  ProductController({ProductService? service})
      : _service = service ?? ProductService();

  static const _pageSize = 20;
  final ProductService _service;

  // Internal list of loaded products
  final List<Product> _items = [];
  List<Product> get items => List.unmodifiable(_items);

  List<String> categories = const ['all'];
  String selectedCategory = 'all';
  String searchQuery = '';
  SortOption sortOption = sortOptions.first;

  int total = 0;
  bool isLoading = false;       // True during first load or reload (category/search change)
  bool isLoadingMore = false;   // True when loading next page on scroll
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  String? errorMessage;

  Timer? _searchDebounce;
  int _requestVersion = 0; // Protects against race conditions from rapid input

  /// Called on startup: loads category list then loads the first page of products
  Future<void> init() => loadInitial();

  Future<void> loadInitial() async {
    try {
      final loadedCategories = await _service.fetchCategories();
      categories = ['all', ...loadedCategories];
      notifyListeners();
    } catch (_) {
      // Continue even if categories fail to load
    }
    await _reload();
  }

  /// Pull-to-refresh action on the Home screen
  Future<void> refresh() => _reload();

  /// Change selected category and reload from page 0
  void selectCategory(String slug) {
    if (selectedCategory == slug) return;
    selectedCategory = slug;
    searchQuery = '';
    _searchDebounce?.cancel();
    _reload();
  }

  /// Search with a 350ms debounce to prevent firing an API call on every keystroke
  void search(String query) {
    searchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _reload);
  }

  /// Change sorting and reload from page 0
  void setSort(SortOption option) {
    if (sortOption == option) return;
    sortOption = option;
    _reload();
  }

  /// Reloads products from offset 0 (e.g. after search, filter, or refresh)
  Future<void> _reload() async {
    final version = ++_requestVersion;
    isLoading = true;
    isLoadingMore = false;
    errorMessage = null;
    _items.clear();
    total = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final page = await _fetchPage(0);
      // Discard results if another request was triggered in the meantime
      if (version != _requestVersion) return;

      _items.addAll(page.items);
      total = page.total;
      _hasMore = _items.length < total && page.items.isNotEmpty;
    } catch (_) {
      if (version == _requestVersion) {
        errorMessage = 'Could not load products. Please check your internet connection.';
      }
    } finally {
      if (version == _requestVersion) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Loads the next page of products when the user scrolls near the bottom (Infinite Scrolling)
  Future<void> loadMore() async {
    // Prevent duplicate calls if already loading, finished, or list is empty
    if (isLoading || isLoadingMore || !_hasMore || _items.isEmpty) return;

    final version = _requestVersion;
    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();

    try {
      final page = await _fetchPage(_items.length);
      if (version != _requestVersion) return;

      // Avoid duplicates if API returns any already present items
      final existingIds = _items.map((p) => p.id).toSet();
      final newItems = page.items.where((p) => !existingIds.contains(p.id)).toList();

      _items.addAll(newItems);
      total = page.total;
      _hasMore = _items.length < total && newItems.isNotEmpty;
    } catch (_) {
      if (version == _requestVersion) {
        errorMessage = 'Failed to load more products. Tap to retry.';
      }
    } finally {
      if (version == _requestVersion) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  /// Helper to fetch a page of products with the active search, category, and sort filters
  Future<PagedProducts> _fetchPage(int skip) => _service.fetchProducts(
        limit: _pageSize,
        skip: skip,
        category: selectedCategory,
        query: searchQuery,
        sortBy: sortOption.sortBy,
        order: sortOption.order,
      );

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
