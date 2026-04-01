class CharacterSkill {
  final String skillName;
  final String abilityScore; // lowercase key, e.g. "dex", "wis"
  final bool proficient;
  final bool expertise;
  final int bonus;

  const CharacterSkill({
    required this.skillName,
    required this.abilityScore,
    required this.proficient,
    required this.expertise,
    required this.bonus,
  });

  factory CharacterSkill.fromJson(Map<String, dynamic> j) => CharacterSkill(
        skillName:    j['skillName']    as String? ?? '',
        abilityScore: j['abilityScore'] as String? ?? '',
        proficient:   j['proficient']   as bool?   ?? false,
        expertise:    j['expertise']    as bool?   ?? false,
        bonus:        (j['bonus'] as num?)?.toInt() ?? 0,
      );
}
