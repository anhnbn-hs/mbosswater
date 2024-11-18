class Product {
  final String id;
  final String? name;
  final String? category;
  final String? guaranteeDuration;

  Product({
    required this.id,
    this.name,
    this.category,
    this.guaranteeDuration,
  });

  int? get duration {
    if (guaranteeDuration == null) return null;
    RegExp regex = RegExp(r'\d+');
    String? match = regex.firstMatch(guaranteeDuration!)?.group(0);
    return match != null ? int.parse(match) : null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String?,
      category: json['category'] as String?,
      guaranteeDuration: json['guaranteeDuration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'guaranteeDuration': guaranteeDuration,
    };
  }
}
