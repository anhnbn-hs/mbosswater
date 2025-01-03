import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String? id;
  String? fullName;
  List<String>? searchTerms;
  Address? address;
  String? phoneNumber;
  String? email;
  String? agency;
  AdditionalInfo? additionalInfo;
  Timestamp? updatedAt;
  Timestamp? createdAt;
  int? totalProduct;

  Customer({
    this.id,
    this.fullName,
    this.searchTerms,
    this.address,
    this.phoneNumber,
    this.email,
    this.additionalInfo,
    this.agency,
    this.updatedAt,
    this.createdAt,
    this.totalProduct,
  });

  // Hàm tạo searchTerms
  static List<String> generateSearchTerms(String fullName) {
    String normalized = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    List<String> terms = [];
    List<String> parts = normalized.split(' ');
    int totalCombinations = 1 << parts.length; // 2^n
    for (int mask = 1; mask < totalCombinations; mask++) {
      String combination = '';
      for (int i = 0; i < parts.length; i++) {
        if ((mask & (1 << i)) != 0) { // Kiểm tra nếu bit thứ i trong mask là 1
          combination = combination.isEmpty ? parts[i] : '$combination ${parts[i]}';
        }
      }
      terms.add(combination);
    }

    terms = terms.toSet().toList();

    if (!terms.contains(normalized)) {
      terms.add(normalized);
    }

    return terms;
  }


  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        id: json['id'],
        updatedAt: json["updatedAt"],
        fullName: json['fullName'],
        searchTerms: List<String>.from(json['searchTerms'] ?? []),
        address:
            json['address'] != null ? Address.fromJson(json['address']) : null,
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        additionalInfo: json['additionalInfo'] != null
            ? AdditionalInfo.fromJson(json['additionalInfo'])
            : null,
        agency: json['agency'] as String?,
        createdAt: json["createdAt"],
        totalProduct: json['totalProduct']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'searchTerms': generateSearchTerms(fullName ?? ''),
      'address': address?.toJson(),
      'phoneNumber': phoneNumber,
      'email': email,
      'agency': agency,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'additionalInfo': additionalInfo?.toJson(),
      'totalProduct': totalProduct,
    };
  }
}

class Address {
  String? province;
  String? district;
  String? commune;
  String? detail;

  Address({
    this.province,
    this.district,
    this.commune,
    this.detail,
  });

  String displayAddress() {
    String pdc = "${commune!}, ${district!}, $province";
    if (detail != null) {
      return "${detail!}, $pdc";
    }
    return pdc;
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      province: json['province'],
      district: json['district'],
      commune: json['commune'],
      detail: json['detail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'district': district,
      'commune': commune,
      'detail': detail,
    };
  }
}

class AdditionalInfo {
  int? childNumber;
  int? adultNumber;
  int? waterQuantity;
  double? pH;

  AdditionalInfo({
    this.childNumber,
    this.adultNumber,
    this.waterQuantity,
    this.pH,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      childNumber: json['childNumber'],
      adultNumber: json['adultNumber'],
      waterQuantity: json['waterQuantity'],
      pH: (json['pH'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childNumber': childNumber,
      'adultNumber': adultNumber,
      'waterQuantity': waterQuantity,
      'pH': pH,
    };
  }
}
