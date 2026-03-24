class ClassOption {
  final int id;
  final String name;
  final int hitDie; //ej: 8 -> d8

  const ClassOption({
    required this.id,
    required this.name,
    required this.hitDie,
  });

  factory ClassOption.fromJson(Map<String, dynamic> json) => ClassOption(
    id:     (json['id'] as num).toInt(),
    name:   json['name'] as String,
    hitDie: (json['hitDie'] as num?)?.toInt() ?? 6, 
  );

  String get hitDieLabel => 'd$hitDie';
}