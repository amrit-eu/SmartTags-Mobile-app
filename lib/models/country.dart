/// A dataclass representing a country.
class Country {
  /// Creates a [Country].
  const Country({
    required this.id,
    required this.name,
    required this.code2,
    required this.nameShort,
  });

  /// Deserialises JSON response from API into a [Country] object.
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

  /// Serialises [Country] object to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code2': code2,
    'name_short': nameShort,
  };

  /// The country's unique identifier.
  final int id;
  /// The country's full name.
  final String name;
  /// The country's ISO 3166-1 alpha-2 code.
  final String code2;
  /// The country's short name.
  final String nameShort;
}
