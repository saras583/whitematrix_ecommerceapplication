import 'package:flutter/material.dart';
import 'package:whitematrix_app/core/formate.dart';
import 'package:whitematrix_app/core/theme.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  const CategoryChips({super.key, required this.categories, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 58,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final slug = categories[index];
            final active = slug == selected;
            return ChoiceChip(
              label: Text(slug == 'all' ? 'All' : prettyCategory(slug)),
              selected: active,
              onSelected: (_) => onSelect(slug),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: active ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            );
          },
        ),
      );
}
