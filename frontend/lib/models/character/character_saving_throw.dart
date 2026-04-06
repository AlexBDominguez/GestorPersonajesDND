class CharacterSavingThrow {
  final String abilityScore; //lowercase: "str", "dex", "con", "int", "wis", "cha"
  final bool proficient;
  final int bonus;

  const CharacterSavingThrow({
    required this.abilityScore,
    required this.proficient,
    required this.bonus,
  });

  factory CharacterSavingThrow.fromJson(Map<String, dynamic> j) => CharacterSavingThrow(
        abilityScore: j['abilityScore'] as String? ?? '',
        proficient:   j['proficient']   as bool?   ?? false,
        bonus:        (j['bonus'] as num?)?.toInt() ?? 0,
      );
}