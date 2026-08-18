/// A dataclass representing a country.
class Country {
  const Country({
    required this.id,
    required this.name,
    required this.code2,
    required this.nameShort,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final int id,
        'name': final String name,
        'code2': final String code2,
        'name_short': final String nameShort,
      } =>
        Country(id: id, name: name, code2: code2, nameShort: nameShort),
      _ => throw FormatException('Failed to create country. JSON: $json'),
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code2': code2,
    'name_short': nameShort,
  };

  final int id;
  final String name;
  final String code2;
  final String nameShort;
}
