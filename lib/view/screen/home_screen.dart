import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whitematrix_app/controller/auth_controller.dart';
import 'package:whitematrix_app/controller/cart_controller.dart';
import 'package:whitematrix_app/controller/product_controller.dart';
import 'package:whitematrix_app/core/theme.dart';
import 'package:whitematrix_app/models/product.dart';
import 'package:whitematrix_app/view/screen/cart_screen.dart';
import 'package:whitematrix_app/view/screen/favorites_screen.dart';
import 'package:whitematrix_app/view/screen/product_detail_screen.dart';
import 'package:whitematrix_app/view/screen/widget/category_chips.dart';
import 'package:whitematrix_app/view/screen/widget/product_card.dart';
import 'package:whitematrix_app/view/screen/widget/promo_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.65,
  );

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 350) {
      context.read<ProductController>().loadMore();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _openDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _showSortSheet() {
    final controller = context.read<ProductController>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Sort Products By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const Divider(color: AppColors.border),
              for (final option in sortOptions)
                ListTile(
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: option.label == controller.sortOption.label
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: option.label == controller.sortOption.label
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: option.label == controller.sortOption.label
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accent,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.setSort(option);
                    _scrollToTop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    final cartController = context.watch<CartController>();

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildHomeContent(productController),
          const FavoritesScreen(),
          const CartScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Shop',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('${cartController.itemCount}'),
              isLabelVisible: cartController.itemCount > 0,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              label: Text('${cartController.itemCount}'),
              isLabelVisible: cartController.itemCount > 0,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  /// Main home tab content with search, promo carousel, category chips, and product grid
  Widget _buildHomeContent(ProductController controller) {
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Header with Brand and Logout
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Morrow Shop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Curated lifestyle & goods',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => context.read<AuthController>().logout(),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    controller.search(text);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products by title...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              controller.search('');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: PromoBanner(
                onSelect: (slug) {
                  _searchController.clear();
                  _scrollToTop();
                  controller.selectCategory(slug);
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: CategoryChips(
              categories: controller.categories,
              selected: controller.selectedCategory,
              onSelect: (slug) {
                _searchController.clear();
                _scrollToTop();
                controller.selectCategory(slug);
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    controller.isLoading
                        ? 'Loading products...'
                        : '${controller.total} items available',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _showSortSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swap_vert_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.sortOption.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ..._buildProductGrid(controller),
        ],
      ),
    );
  }

  List<Widget> _buildProductGrid(ProductController controller) {
    const padding = EdgeInsets.symmetric(horizontal: 20);

    if (controller.isLoading) {
      return [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid.builder(
            gridDelegate: _gridDelegate,
            itemCount: 6,
            itemBuilder: (_, _) => const ProductCardSkeleton(),
          ),
        ),
      ];
    }

    if (controller.items.isEmpty) {
      final isError = controller.errorMessage != null;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.wifi_off_rounded : Icons.search_off_rounded,
                    size: 56,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isError ? controller.errorMessage! : 'No products found',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.refresh,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: padding,
        sliver: SliverGrid.builder(
          gridDelegate: _gridDelegate,
          itemCount: controller.items.length,
          itemBuilder: (_, index) {
            final product = controller.items[index];
            return ProductCard(
              product: product,
              onTap: () => _openDetail(product),
            );
          },
        ),
      ),

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: _buildScrollFooter(controller)),
        ),
      ),
    ];
  }

  Widget _buildScrollFooter(ProductController controller) {
    if (controller.isLoadingMore) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Loading more products...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      );
    }

    if (controller.errorMessage != null && controller.items.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            controller.errorMessage!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: controller.loadMore,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Tap to retry'),
          ),
        ],
      );
    }

    if (!controller.hasMore) {
      return const Text(
        'You\'ve reached the end of the collection ✨',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
