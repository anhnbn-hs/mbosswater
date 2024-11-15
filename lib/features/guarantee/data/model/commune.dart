class Commune {
  Commune({
    required this.id,
    required this.name,
    required this.districtId,
    required this.type,
    required this.typeText,
  });

  final String? id;
  final String? name;
  final String? districtId;
  final int? type;
  final String? typeText;

  factory Commune.fromJson(Map<String, dynamic> json){
    return Commune(
      id: json["id"],
      name: json["name"],
      districtId: json["districtId"],
      type: json["type"],
      typeText: json["typeText"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "districtId": districtId,
    "type": type,
    "typeText": typeText,
  };

}