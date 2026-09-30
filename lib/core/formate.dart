String prettyCategory(String slug) {
  if (slug == 'all') return 'All';
  return slug
      .split('-')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

String money(double v) => '\$${v.toStringAsFixed(2)}';