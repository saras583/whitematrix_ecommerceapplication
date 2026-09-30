class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    brand: json['brand'] ?? 'Generic',
    price: (json['price'] as num).toDouble(),
    discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
    rating: (json['rating'] as num? ?? 0).toDouble(),
    thumbnail: json['thumbnail'] ?? '',
    images: List<String>.from(json['images'] ?? []),
  );

  double get discountedPrice => price * (1 - discountPercentage / 100);
}
