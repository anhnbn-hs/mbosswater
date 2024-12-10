import 'package:cloud_firestore/cloud_firestore.dart';

class Agency {
  final String id;
  String code;
  String name;
  String address;
  final Timestamp createdAt;
  bool isDelete;

  Agency(this.id, this.code, this.name, this.address, this.createdAt, this.isDelete);

  String getCodeFromAddress() {
    // Assuming the region is the last part of the address
    final List<String> addressParts = address.split(',').map((e) => e.trim()).toList();
    if (addressParts.isNotEmpty) {
      final region = addressParts.last; // Get the last part of the address
      return _convertRegionToCode(region);
    }
    return "UNKNOWN";
  }

  /// Generates the full agency code based on address and name.
  /// Example: "DL-HN-001"
  String generateAgencyCode(int uniqueCode) {
    final regionCode = getCodeFromAddress();
    return "DL-$regionCode-${uniqueCode.toString().padLeft(3, '0')}";
  }

  /// Helper function to convert a region name to its code
  /// Add mappings for additional regions as needed.
  String _convertRegionToCode(String region) {
    const regionCodes = {
      "Hà Nội": "HN",
      "Hồ Chí Minh": "HCM",
      "Đà Nẵng": "DN",
      "Hải Phòng": "HP",
      "Cần Thơ": "CT",
      "Quảng Ninh": "QN",
      "Bắc Ninh": "BN",
      "Thái Nguyên": "TN",
      "Thanh Hóa": "TH",
      "Nghệ An": "NA",
      "Huế": "HUE",
      "Khánh Hòa": "KH",
      "Bình Dương": "BD",
      "Đồng Nai": "DN",
      "Vũng Tàu": "VT",
      "An Giang": "AG",
      "Bình Thuận": "BT",
      "Quảng Nam": "QNAM",
      "Gia Lai": "GL",
      "Lâm Đồng": "LD",
      "Kiên Giang": "KG",
      "Long An": "LA",
      "Bến Tre": "BTRE",
      "Quảng Trị": "QT",
      "Phú Yên": "PY",
      "Hậu Giang": "HG",
      "Sơn La": "SL",
      "Điện Biên": "DB",
      "Lào Cai": "LC",
      "Hà Giang": "HG",
      "Tuyên Quang": "TQ",
      "Cao Bằng": "CB",
      "Bắc Kạn": "BK",
      "Yên Bái": "YB",
      "Lạng Sơn": "LS",
      "Quảng Bình": "QB",
      "Hà Tĩnh": "HT",
      "Đắk Lắk": "DLK",
      "Đắk Nông": "DN",
      "Ninh Thuận": "NT",
      "Bình Phước": "BP",
      "Tây Ninh": "TN",
      "Sóc Trăng": "ST",
      "Trà Vinh": "TV",
      "Bạc Liêu": "BL",
      "Cà Mau": "CM",
    };

    return regionCodes[region] ?? region.substring(0, 2).toUpperCase();
  }

  // Converts an Agency instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'code': code,
      'createdAt': createdAt,
      'isDelete': isDelete,
    };
  }

  // Creates an Agency instance from a JSON map
  factory Agency.fromJson(Map<String, dynamic> json, String id) {
    return Agency(
      id,
      json['code'] as String,
      json['name'] as String,
      json['address'] as String,
      json['createdAt'] as Timestamp,
      json["isDelete"] as bool,
    );
  }
}
