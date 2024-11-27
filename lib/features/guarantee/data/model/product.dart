class Product {
  final String id;
  final String? name;
  final String? model;
  final String? seriDow;
  final String? guaranteeDuration;

  Product({
    required this.id,
    this.name,
    this.model,
    this.seriDow,
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
      model: json['model'] as String? ,
      seriDow: json['seriDow'] as String?,
      guaranteeDuration: json['guaranteeDuration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'seriDow': seriDow,
      'guaranteeDuration': guaranteeDuration,
    };
  }
}
