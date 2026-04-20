class ClassFeature{
  final int id;
  final String indexName;
  final String name;
  final int level;
  final String description;

  const ClassFeature({
    required this.id,
    required this.indexName,
    required this.name,
    required this.level,
    required this.description
  });

  factory ClassFeature.fromJson(Map<String, dynamic> j) => ClassFeature(
    id:           j['id'] as int,
    indexName:    j['indexName'] as String? ?? '',
    name:         j['name'] as String,
    level:        j['level'] as int,
    description:  j['description'] as String? ?? '',
  );
}

class SubclassOption{
  final int id;
  final String indexName;
  final String name;
  final String flavor;
  final String description;
  final String? spellCastingAbility;

  const SubclassOption({
    required this.id,
    required this.indexName,
    required this.name,
    required this.flavor,
    required this.description,
    this.spellCastingAbility,
  });


  factory SubclassOption.fromJson(Map<String, dynamic> j) => SubclassOption(
    id: j['id'] as int,
    indexName: j['indexName'] as String,
    name: j['name'] as String,
    flavor: j['subclassFlavor'] as String? ?? '',
    description: j['description'] as String? ?? '',
    spellCastingAbility: j['spellcastingAbility'] as String?,
  );
}

class ClassOption {
  final int id;
  final String indexName;
  final String name;
  final int hitDie;
  final String description;
  final List<String> proficiencies;
  final String? spellCastingAbility;

  const ClassOption({
    required this.id,
    required this.indexName,
    required this.name,
    required this.hitDie,
    required this.description,
    required this.proficiencies,
    this.spellCastingAbility,
  });

  factory ClassOption.fromJson(Map<String, dynamic> j) => ClassOption(
    id: j['id'] as int,
    indexName: j['indexName'] as String,
    name: j['name'] as String,
    hitDie: j['hitDie'] as int? ?? 6,
    description: j['description'] as String? ?? '',
    proficiencies: List<String>.from(j['proficiencies'] as List? ?? []),
    spellCastingAbility: j['spellcastingAbility'] as String?,
  );

  // HP al nivel 1: hitDie + CON modifier (se calcula en el ViewModel)
  int hpAtLevel1(int conModifier)=> hitDie + conModifier;
}
