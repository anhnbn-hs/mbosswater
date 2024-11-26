import 'package:cloud_firestore/cloud_firestore.dart';

class Agency {
  final String id;
  final String name;
  final String address;
  final Timestamp createdAt;

  Agency(this.id, this.name, this.address, this.createdAt);

  // Converts an Agency instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'createdAt': createdAt,
    };
  }

  // Creates an Agency instance from a JSON map
  factory Agency.fromJson(Map<String, dynamic> json, String id) {
    return Agency(
      id,
      json['name'] as String,
      json['address'] as String,
      json['createdAt'] as Timestamp,
    );
  }
}
