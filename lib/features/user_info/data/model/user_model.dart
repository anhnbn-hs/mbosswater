import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? dob;
  final String? gender;
  final String? address;
  final String? role;
  final String? password;
  final String? agency;
  final Timestamp? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.dob,
    required this.email,
    required this.gender,
    required this.role,
    required this.createdAt,
    required this.address,
    required this.agency,
    required this.password,
  });

  // Factory constructor to create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      dob: json['dob'] as String,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      email: json["email"] as String,
      role: json['role'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
      password: json["password"] as String?,
      agency: json["agency"] as String?,
    );
  }

  // Method to convert UserModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address': address,
      'dob': dob,
      'gender': gender,
      'role': role,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'agency': agency,
    };
  }
}
