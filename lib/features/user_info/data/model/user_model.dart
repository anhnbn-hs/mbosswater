import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final DateTime dob;
  final String gender;
  final String role;
  final String password;
  final Timestamp createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.role,
    required this.createdAt,
    required this.password,
  });

  // Factory constructor to create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      dob: DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] as Timestamp,
      password: json["password"] as String,
    );
  }

  // Method to convert UserModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
