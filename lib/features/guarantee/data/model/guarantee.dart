import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';

class Guarantee {
  final String id;
  final Timestamp createdAt;
  final Product product;
  final String customerID;
  final String technicalID;
  final String? technicalSupportID;
  final DateTime endDate;

  Guarantee({
    required this.id,
    required this.createdAt,
    required this.product,
    required this.customerID,
    required this.technicalID,
    required this.endDate,
    this.technicalSupportID,
  });

  // Factory constructor to create a Guarantee from JSON
  factory Guarantee.fromJson(Map<String, dynamic> json) {
    return Guarantee(
      id: json['id'] as String,
      createdAt: json['createdAt'] as Timestamp,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      customerID: json['customerID'] as String,
      endDate: DateTime.parse(json['endDate'] as String),
      technicalID: json['technicalID'] as String,
      technicalSupportID: json['technicalSupportID'] as String?,
    );
  }

  // Converts the Guarantee to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'product': product.toJson(),
      'customerID': customerID,
      'endDate': endDate.toIso8601String(),
      'technicalID': technicalID,
      'technicalSupportID': technicalSupportID,
    };
  }
}
