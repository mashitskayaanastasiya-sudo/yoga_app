class Asana {
  final String id;
  final String nameSanskrit;
  final String nameRussian;
  final String imageUrl;
  final String level;
  final String skill;
  final List<dynamic> contraindications;
  final List<dynamic> modifications;
  final String fact;
  final String technique;

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
  });

  factory Asana.fromJson(Map<String, dynamic> json) {
    return Asana(
      id: json['id'] ?? '',
      nameSanskrit: json['name_sanskrit'] ?? '',
      nameRussian: json['name_russian'] ?? '',
      imageUrl: json['image_url'] ?? '',
      level: json['level'] ?? '',
      skill: json['skill'] ?? '',
      contraindications: List<String>.from(json['contraindications'] ?? []),
      modifications: List<String>.from(json['modifications'] ?? []),
      fact: json['fact'] ?? '',
      technique: json['technique'] ?? '',
    );
  }
}
