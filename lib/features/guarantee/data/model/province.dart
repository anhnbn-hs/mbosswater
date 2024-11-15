class Province {
  String? id;
  String? name;
  int? type;
  String? typeText;
  String? slug;

  Province({this.id, this.name, this.type, this.typeText, this.slug});

  Province.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    typeText = json['typeText'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['typeText'] = this.typeText;
    data['slug'] = this.slug;
    return data;
  }
}