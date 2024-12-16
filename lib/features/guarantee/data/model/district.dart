class District {
  District({
    this.id,
    this.name,
    this.provinceId,
    this.type,
    this.typeText,
  });

  final String? id;
  String? name;
  String? provinceId;
  int? type;
  String? typeText;

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json["id"],
      name: json["name"],
      provinceId: json["provinceId"],
      type: json["type"],
      typeText: json["typeText"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "provinceId": provinceId,
        "type": type,
        "typeText": typeText,
      };
}
