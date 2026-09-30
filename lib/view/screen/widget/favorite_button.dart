import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whitematrix_app/controller/wishlist_controller.dart';
import 'package:whitematrix_app/core/theme.dart';

class FavoriteButton extends StatelessWidget {
  final int productId;
  final double size;

  const FavoriteButton({super.key, required this.productId, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<WishlistController, bool>(
      (w) => w.isFavorite(productId),
    );

    return GestureDetector(
      onTap: () => context.read<WishlistController>().toggle(productId),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey<bool>(isFav),
            size: size,
            color: isFav ? AppColors.accent : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
