class Customer {
  String? id;
  String? fullName;
  Address? address;
  String? phoneNumber;
  String? email;
  String? agency;
  AdditionalInfo? additionalInfo;

  Customer({
    this.id,
    this.fullName,
    this.address,
    this.phoneNumber,
    this.email,
    this.additionalInfo,
    this.agency,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      fullName: json['fullName'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      additionalInfo: json['additionalInfo'] != null
          ? AdditionalInfo.fromJson(json['additionalInfo'])
          : null,
      agency: json['agency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address': address?.toJson(),
      'phoneNumber': phoneNumber,
      'email': email,
      'agency': agency,
      'additionalInfo': additionalInfo?.toJson(),
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
    return "${commune!}, ${district!}, $province";
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