class Country {
  final String name;
  final String code;
  final String emoji;
  final String unicode;
  final String image;

  Country({
    required this.name,
    required this.code,
    required this.emoji,
    required this.unicode,
    required this.image,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      code: json['code'] as String,
      emoji: json['emoji'] as String,
      unicode: json['unicode'] as String,
      image: json['image'] as String,
    );
  }
}
