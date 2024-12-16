import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class Agency {
  final String id;
  String code;
  String name;
  Address? address;
  final Timestamp createdAt;
  bool isDelete;

  Agency(this.id, this.code, this.name, this.address, this.createdAt, this.isDelete);

  String getCodeFromAddress() {
    final List<String> addressParts = address!.province!.split(' ');
    return addressParts[0][0] + addressParts[1][0];
  }

  /// Generates the full agency code based on address and name.
  /// Example: "DL-HN-001"
  String generateAgencyCode(int uniqueCode) {
    final regionCode = getCodeFromAddress();
    return "DL-$regionCode-${uniqueCode.toString().padLeft(3, '0')}";
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address?.toJson(),
      'code': code,
      'createdAt': createdAt,
      'isDelete': isDelete,
    };
  }

  factory Agency.fromJson(Map<String, dynamic> json, String id) {
    return Agency(
      id,
      json['code'] as String,
      json['name'] as String,
      json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      json['createdAt'] as Timestamp,
      json['isDelete'] as bool,
    );
  }

}
