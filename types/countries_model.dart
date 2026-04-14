class Country {
  final String name;
  final String native;
  final String capital;
  final String emoji;
  final String currency;
  final List<String> languages;

  Country({
    required this.name,
    required this.native,
    required this.capital,
    required this.emoji,
    required this.currency,
    required this.languages,
  });

  // Factory para procesar el JSON que pusiste
  factory Country.fromJson(Map<String, dynamic> json) {
    var countryData = json['data']['country'];
    var langs = (countryData['languages'] as List)
        .map((l) => l['name'] as String)
        .toList();

    return Country(
      name: countryData['name'],
      native: countryData['native'],
      capital: countryData['capital'],
      emoji: countryData['emoji'],
      currency: countryData['currency'],
      languages: langs,
    );
  }
}
