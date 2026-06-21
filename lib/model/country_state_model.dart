class CountryModel {
  int? id;
  String? name;
  String? code;
  String? image;

  CountryModel({this.id, this.name, this.code, this.image});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      image: json['image'],
    );
  }
}

class StateModel {
  int? id;
  int? countryId;
  String? name;

  StateModel({this.id, this.countryId, this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      countryId: json['country_id'], // JSON e country_id ache
      name: json['name'],
    );
  }
}
