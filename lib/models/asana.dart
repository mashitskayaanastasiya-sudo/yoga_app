class Asana {
  final String id;
  final String nameSanskrit;
  final String nameRussian;
  final String imageUrl;
  final String level;
  final String skill;
  final List<String> contraindications;
  final List<String> modifications;
  final String fact;
  final String technique;
  final String? limitations;

  Asana({
    required this.id,
    required this.nameSanskrit,
    required this.nameRussian,
    required this.imageUrl,
    required this.level,
    required this.skill,
    required this.contraindications,
    required this.modifications,
    required this.fact,
    required this.technique,
    this.limitations,
  });

  factory Asana.fromJson(Map<String, dynamic> json) {
    return Asana(
      id: json['id'] ?? '',
      nameSanskrit: json['name_sanskrit'] ?? '',
      nameRussian: json['name_russian'] ?? '',
      imageUrl: json['image_url'] ?? '',
      level: json['level'] ?? '',
      skill: json['skill'] ?? '',
      contraindications: (json['contraindications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      modifications: (json['modifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fact: json['fact'] ?? '',
      technique: json['technique'] ?? '',
      limitations: json['limitations'], // может быть null
    );
  }
}
