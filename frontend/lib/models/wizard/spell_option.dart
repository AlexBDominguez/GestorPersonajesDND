class SpellOption{
  final int id;
  final String name;
  final int level; // 0 = cantrip
  final String? school;
  final String? castingTime;
  final String? range;
  final String? duration;
  final String? components;
  final String? description;

  const SpellOption({
    required this.id,
    required this.name,
    required this.level,
    this.school,
    this.castingTime,
    this.range,
    this.duration,
    this.components,
    this.description,
  });

  factory SpellOption.fromJson(Map<String, dynamic> j) => SpellOption(
        id:          (j['id'] as num).toInt(),
        name:        j['name'] as String? ?? '',
        level:       (j['level'] as num?)?.toInt() ?? 0,
        school:      j['school'] as String?,
        castingTime: j['castingTime'] as String?,
        range:       j['range'] as String?,
        duration:    j['duration'] as String?,
        components:  j['components'] as String?,
        description: j['description'] as String?,
      );

  bool get isCantrip => level == 0;
}