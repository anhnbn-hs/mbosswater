import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';

class UserModel {
  String id;
  String? cccd;
  String email;
  String? fullName;
  final String? dob;
  final String? gender;
  Address? address;
  String? phoneNumber;
  String? role;
  final String? password;
  final String? agency;
  final Timestamp? createdAt;
  final bool? isDelete;

  UserModel({
    required this.id,
    this.cccd,
    required this.fullName,
    required this.dob,
    required this.email,
    required this.gender,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    required this.address,
    required this.agency,
    required this.password,
    required this.isDelete,
  });

  // Factory constructor to create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      cccd: json['cccd'] as String?,
      fullName: json['fullName'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      email: json["email"] as String,
      role: json['role'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
      password: json["password"] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      agency: json["agency"] as String?,
      isDelete: json["isDelete"] as bool?,
    );
  }

  // Method to convert UserModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cccd': cccd,
      'fullName': fullName,
      'address': address?.toJson(),
      'dob': dob,
      'gender': gender,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'createdAt': createdAt,
      'agency': agency,
      'isDelete': isDelete,
    };
  }
}
