class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? brand;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'],
    );
  }
}
