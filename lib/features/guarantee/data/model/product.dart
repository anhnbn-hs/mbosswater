class Product {
  final String id;
  final String? name;
  final String? category;
  final String? description;

  Product({
    required this.id,
    this.name,
    this.category,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
    };
  }
}
